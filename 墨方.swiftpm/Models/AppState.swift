import SwiftUI

/// 全局应用状态 · 只用 UserDefaults 持久化（无网络、无数据库）
@MainActor
final class AppState: ObservableObject {

    // ─── 持久化键 ───────────────────────────────────────────────────
    private enum Key {
        static let onboarded     = "ms.onboarded"
        static let streak        = "ms.streak"
        static let lastPractice  = "ms.lastPracticeDay"
        static let doneStrokes   = "ms.doneStrokes"        // Set<stroke_id> JSON
        static let passCounts    = "ms.passCounts"         // [charID: Int] 合格次数
        static let bestScores    = "ms.bestScores"         // [String:Int] JSON
        static let totalChars    = "ms.totalChars"
        static let totalMinutes  = "ms.totalMinutes"
        static let nickname      = "ms.nickname"
        static let bestSpeed     = "ms.bestSpeed"
        static let userMode      = "ms.userMode"           // "kid" | "adult"
        static let stickers      = "ms.stickers"           // Set<charID> JSON
        static let gameBests     = "ms.gameBests"          // [String:Int] JSON
        static let missionDate   = "ms.missionDate"        // YYYY-MM-DD
        static let missionDone   = "ms.missionDone"        // [Bool] JSON
        static let weeklyWeek    = "ms.weeklyWeek"         // "2026-W15"
        static let weeklyProgress = "ms.weeklyProgress"    // [Int] progress counters
        static let weeklyClaimed = "ms.weeklyClaimed"      // [Bool] claimed flags
        static let dailyMinutes  = "ms.dailyMinutes"       // [date_key: minutes] JSON
        static let dailyLimit    = "ms.dailyLimit"         // Int (minutes)
        static let todayUsed     = "ms.todayUsed"          // [dateKey: seconds]
        static let compositesLearned = "ms.compositesLearned" // Set<composite_glyph> JSON
        // 虚拟宠物
        static let petName       = "ms.petName"
        static let petFood       = "ms.petFood"            // 0-100 饱食度
        static let petExp        = "ms.petExp"             // 经验值（练字累加）
        static let petLastFed    = "ms.petLastFed"         // ISO date
        static let petOutfit     = "ms.petOutfit"          // 当前装扮 key
        static let petOutfitsOwned = "ms.petOutfitsOwned"  // Set<String>
        // 证书
        static let certL1Issued  = "ms.certL1Issued"       // 日期字符串
        // 故事阅读
        static let storiesRead   = "ms.storiesRead"        // Set<storyID>
        // 涂色完成
        static let coloredChars  = "ms.coloredChars"       // Set<charID>
        // 找字关卡通关
        static let findCompleted = "ms.findCompleted"      // Set<findLevelID>
        // 间隔重复（SM-2 简化版）
        static let reviewStates  = "ms.reviewStates"       // [charID: ReviewState] JSON
        // 认字闪卡
        static let flashcardSessions = "ms.flashcardSessions" // [dateKey: Int] JSON
        // 字形演变
        static let evolutionSeen = "ms.evolutionSeen"      // Set<charID>
    }

    /// 用户身份模式
    enum UserMode: String {
        case kid       // 4-5 岁幼儿，大格子 / 逐笔描摹 / 温和反馈
        case adult     // 标准模式
    }

    /// 单字复习状态（SM-2 简化版）
    struct ReviewState: Codable, Equatable {
        var box: Int                // Leitner box 0..5
        var ease: Double            // 难易度
        var nextReviewDay: String   // YYYY-MM-DD
        var lastScore: Int
        var reviewCount: Int        // 已复习次数
    }

    // ─── 状态 ───────────────────────────────────────────────────────
    @Published var onboarded: Bool {
        didSet { UserDefaults.standard.set(onboarded, forKey: Key.onboarded) }
    }
    @Published var streakDays: Int {
        didSet { UserDefaults.standard.set(streakDays, forKey: Key.streak) }
    }
    @Published var doneStrokeIDs: Set<String> {
        didSet { save(Array(doneStrokeIDs), forKey: Key.doneStrokes) }
    }
    @Published var bestScores: [String: Int] {
        didSet { save(bestScores, forKey: Key.bestScores) }
    }
    @Published var totalChars: Int {
        didSet { UserDefaults.standard.set(totalChars, forKey: Key.totalChars) }
    }
    @Published var totalMinutes: Int {
        didSet { UserDefaults.standard.set(totalMinutes, forKey: Key.totalMinutes) }
    }
    @Published var nickname: String {
        didSet { UserDefaults.standard.set(nickname, forKey: Key.nickname) }
    }
    @Published var bestSpeedScore: Int {
        didSet { UserDefaults.standard.set(bestSpeedScore, forKey: Key.bestSpeed) }
    }
    @Published var userMode: UserMode {
        didSet { UserDefaults.standard.set(userMode.rawValue, forKey: Key.userMode) }
    }
    @Published var stickers: Set<String> {
        didSet { save(Array(stickers), forKey: Key.stickers) }
    }
    /// 每个字累计合格次数（≥85 分算一次）· 练满 N 遍才算"掌握"
    @Published var passCounts: [String: Int] {
        didSet { save(passCounts, forKey: Key.passCounts) }
    }
    /// 至少多少次合格算"掌握" —— 初始 2 遍（练 + 再练）
    static let masterThreshold: Int = 2
    @Published var gameBests: [String: Int] {
        didSet { save(gameBests, forKey: Key.gameBests) }
    }
    @Published var missionDate: String {
        didSet { UserDefaults.standard.set(missionDate, forKey: Key.missionDate) }
    }
    @Published var missionDone: [Bool] {
        didSet { save(missionDone, forKey: Key.missionDone) }
    }
    @Published var weeklyWeek: String {
        didSet { UserDefaults.standard.set(weeklyWeek, forKey: Key.weeklyWeek) }
    }
    @Published var weeklyProgress: [Int] {
        didSet { save(weeklyProgress, forKey: Key.weeklyProgress) }
    }
    @Published var weeklyClaimed: [Bool] {
        didSet { save(weeklyClaimed, forKey: Key.weeklyClaimed) }
    }
    @Published var dailyMinutes: [String: Int] {
        didSet { save(dailyMinutes, forKey: Key.dailyMinutes) }
    }
    @Published var dailyLimitMinutes: Int {
        didSet { UserDefaults.standard.set(dailyLimitMinutes, forKey: Key.dailyLimit) }
    }
    @Published var todayUsedSeconds: [String: Int] {
        didSet { save(todayUsedSeconds, forKey: Key.todayUsed) }
    }
    @Published var compositesLearned: Set<String> {
        didSet { save(Array(compositesLearned), forKey: Key.compositesLearned) }
    }
    // 虚拟宠物
    @Published var petName: String {
        didSet { UserDefaults.standard.set(petName, forKey: Key.petName) }
    }
    @Published var petFood: Int {
        didSet { UserDefaults.standard.set(petFood, forKey: Key.petFood) }
    }
    @Published var petExp: Int {
        didSet { UserDefaults.standard.set(petExp, forKey: Key.petExp) }
    }
    @Published var petLastFed: String {
        didSet { UserDefaults.standard.set(petLastFed, forKey: Key.petLastFed) }
    }
    @Published var petOutfit: String {
        didSet { UserDefaults.standard.set(petOutfit, forKey: Key.petOutfit) }
    }
    @Published var petOutfitsOwned: Set<String> {
        didSet { save(Array(petOutfitsOwned), forKey: Key.petOutfitsOwned) }
    }
    // 证书
    @Published var certL1IssuedDate: String {
        didSet { UserDefaults.standard.set(certL1IssuedDate, forKey: Key.certL1Issued) }
    }
    // 故事 / 涂色 / 找字
    @Published var storiesRead: Set<String> {
        didSet { save(Array(storiesRead), forKey: Key.storiesRead) }
    }
    @Published var coloredChars: Set<String> {
        didSet { save(Array(coloredChars), forKey: Key.coloredChars) }
    }
    @Published var findCompleted: Set<String> {
        didSet { save(Array(findCompleted), forKey: Key.findCompleted) }
    }
    @Published var reviewStates: [String: ReviewState] {
        didSet { save(reviewStates, forKey: Key.reviewStates) }
    }
    @Published var flashcardSessions: [String: Int] {
        didSet { save(flashcardSessions, forKey: Key.flashcardSessions) }
    }
    @Published var evolutionSeen: Set<String> {
        didSet { save(Array(evolutionSeen), forKey: Key.evolutionSeen) }
    }

    // ─── 派生状态 ───────────────────────────────────────────────────
    /// 当前学习路径（根据用户模式返回）
    /// - 幼儿：幼学 20 字
    /// - 成人：L1 八画 + L2 偏旁 + L3...
    var curriculum: [CharacterDef] {
        switch userMode {
        case .kid:
            return KidsCharacters.all
        case .adult:
            return StandardStrokes.all + StandardRadicals.all
        }
    }

    /// 下一个未完成的学习项
    var nextStage: CharacterDef? {
        curriculum.first { !doneStrokeIDs.contains($0.id) }
    }

    /// 向后兼容：保留旧接口名
    var nextStroke: CharacterDef? { nextStage }

    /// 当前课程是否全部完成
    var isCurriculumComplete: Bool {
        curriculum.allSatisfy { doneStrokeIDs.contains($0.id) }
    }

    /// L1 八画是否全部完成
    var isL1Complete: Bool {
        StandardStrokes.all.allSatisfy { doneStrokeIDs.contains($0.id) }
    }

    /// L2 偏旁是否全部完成
    var isL2Complete: Bool {
        StandardRadicals.all.allSatisfy { doneStrokeIDs.contains($0.id) }
    }

    /// 幼学 20 字是否全部完成
    var isKidsComplete: Bool {
        KidsCharacters.all.allSatisfy { doneStrokeIDs.contains($0.id) }
    }

    /// 当前阶段标签
    var currentLevelLabel: String {
        switch userMode {
        case .kid:
            if isKidsComplete { return "幼学 · 已掌握 20 字" }
            return "幼学 · 识字入门"
        case .adult:
            if isL2Complete { return "L3 独体字（即将开启）" }
            if isL1Complete { return "L2 · 偏旁部首" }
            return "L1 · 八画"
        }
    }

    /// 是否是幼儿模式
    var isKidMode: Bool { userMode == .kid }

    /// 段位（结合 L1 + L2 进度）
    var rankLabel: String {
        let total = doneStrokeIDs.count
        switch total {
        case 0:       return "白丁"
        case 1...2:   return "童生"
        case 3...5:   return "秀才"
        case 6...8:   return "举人"
        case 9...12:  return "进士"
        default:      return "翰林"
        }
    }

    // ─── 初始化 ────────────────────────────────────────────────────
    init() {
        let d = UserDefaults.standard
        self.onboarded    = d.bool(forKey: Key.onboarded)
        self.streakDays   = d.integer(forKey: Key.streak)
        self.totalChars   = d.integer(forKey: Key.totalChars)
        self.totalMinutes = d.integer(forKey: Key.totalMinutes)
        self.nickname     = d.string(forKey: Key.nickname) ?? "新同学"
        self.bestSpeedScore = d.integer(forKey: Key.bestSpeed)
        self.userMode = UserMode(rawValue: d.string(forKey: Key.userMode) ?? "") ?? .adult

        // 集合/字典 JSON 反序列化
        if let data = d.data(forKey: Key.doneStrokes),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.doneStrokeIDs = Set(arr)
        } else {
            self.doneStrokeIDs = []
        }
        if let data = d.data(forKey: Key.bestScores),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.bestScores = dict
        } else {
            self.bestScores = [:]
        }
        if let data = d.data(forKey: Key.passCounts),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.passCounts = dict
        } else {
            self.passCounts = [:]
        }
        if let data = d.data(forKey: Key.stickers),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.stickers = Set(arr)
        } else {
            self.stickers = []
        }
        if let data = d.data(forKey: Key.gameBests),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.gameBests = dict
        } else {
            self.gameBests = [:]
        }
        self.missionDate = d.string(forKey: Key.missionDate) ?? ""
        if let data = d.data(forKey: Key.missionDone),
           let arr = try? JSONDecoder().decode([Bool].self, from: data),
           arr.count == 3 {
            self.missionDone = arr
        } else {
            self.missionDone = [false, false, false]
        }

        self.weeklyWeek = d.string(forKey: Key.weeklyWeek) ?? ""
        if let data = d.data(forKey: Key.weeklyProgress),
           let arr = try? JSONDecoder().decode([Int].self, from: data),
           arr.count == 3 {
            self.weeklyProgress = arr
        } else {
            self.weeklyProgress = [0, 0, 0]
        }
        if let data = d.data(forKey: Key.weeklyClaimed),
           let arr = try? JSONDecoder().decode([Bool].self, from: data),
           arr.count == 3 {
            self.weeklyClaimed = arr
        } else {
            self.weeklyClaimed = [false, false, false]
        }

        if let data = d.data(forKey: Key.dailyMinutes),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.dailyMinutes = dict
        } else {
            self.dailyMinutes = [:]
        }
        let rawLimit = d.integer(forKey: Key.dailyLimit)
        self.dailyLimitMinutes = rawLimit == 0 ? 20 : rawLimit   // 默认 20 分钟
        if let data = d.data(forKey: Key.todayUsed),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.todayUsedSeconds = dict
        } else {
            self.todayUsedSeconds = [:]
        }
        if let data = d.data(forKey: Key.compositesLearned),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.compositesLearned = Set(arr)
        } else {
            self.compositesLearned = []
        }

        // 宠物
        self.petName = d.string(forKey: Key.petName) ?? "墨墨"
        let rawFood = d.integer(forKey: Key.petFood)
        self.petFood = rawFood == 0 ? 60 : rawFood    // 默认中等饱食
        self.petExp = d.integer(forKey: Key.petExp)
        self.petLastFed = d.string(forKey: Key.petLastFed) ?? ""
        self.petOutfit = d.string(forKey: Key.petOutfit) ?? "default"
        if let data = d.data(forKey: Key.petOutfitsOwned),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.petOutfitsOwned = Set(arr)
        } else {
            self.petOutfitsOwned = ["default"]
        }

        // 证书
        self.certL1IssuedDate = d.string(forKey: Key.certL1Issued) ?? ""

        // 故事 / 涂色 / 找字
        if let data = d.data(forKey: Key.storiesRead),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.storiesRead = Set(arr)
        } else {
            self.storiesRead = []
        }
        if let data = d.data(forKey: Key.coloredChars),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.coloredChars = Set(arr)
        } else {
            self.coloredChars = []
        }
        if let data = d.data(forKey: Key.findCompleted),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.findCompleted = Set(arr)
        } else {
            self.findCompleted = []
        }

        if let data = d.data(forKey: Key.reviewStates),
           let dict = try? JSONDecoder().decode([String: ReviewState].self, from: data) {
            self.reviewStates = dict
        } else {
            self.reviewStates = [:]
        }
        if let data = d.data(forKey: Key.flashcardSessions),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.flashcardSessions = dict
        } else {
            self.flashcardSessions = [:]
        }
        if let data = d.data(forKey: Key.evolutionSeen),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            self.evolutionSeen = Set(arr)
        } else {
            self.evolutionSeen = []
        }

        Self.maybeUpdateStreak(state: self)
        Self.refreshMissionIfNeeded(state: self)
        Self.refreshWeeklyIfNeeded(state: self)
        Self.decayPetIfNeeded(state: self)
    }

    /// 已收集的贴纸数量
    var stickerCount: Int { stickers.count }
    func hasSticker(for charID: String) -> Bool { stickers.contains(charID) }

    // ─── 动作 ───────────────────────────────────────────────────────
    func recordAttempt(charID: String, score: Int, durationSeconds: Int) {
        Self.refreshMissionIfNeeded(state: self)
        Self.refreshWeeklyIfNeeded(state: self)
        let prev = bestScores[charID] ?? 0
        if score > prev { bestScores[charID] = score }
        totalChars += 1
        totalMinutes += max(1, durationSeconds / 60)
        let wasDone = doneStrokeIDs.contains(charID)
        // 累加每日和每天用时
        let today = Self.dayKey(Date())
        dailyMinutes[today, default: 0] += max(1, durationSeconds / 60)
        todayUsedSeconds[today, default: 0] += durationSeconds
        // ── "掌握"新机制：≥ 85 分合格 · 累计满 masterThreshold (=2) 次才标 done ──
        if score >= 85 {
            passCounts[charID, default: 0] += 1
        }
        let passes = passCounts[charID] ?? 0
        let justMastered = !wasDone && passes >= Self.masterThreshold
        if passes >= Self.masterThreshold {
            doneStrokeIDs.insert(charID)
        }

        // 幼儿字"达到掌握"瞬间触发一次性奖励
        if charID.hasPrefix("kid:"), justMastered {
            stickers.insert(charID)
            setMissionDone(0)
            setMissionDone(2)
            bumpWeekly(0)
            feedPet(byScore: score)
            unlockOutfitIfReached()
        } else if charID.hasPrefix("kid:"), score >= 85 {
            // 每次合格都给宠物一点吃的（但不给贴纸，贴纸要掌握才解锁）
            feedPet(byScore: score)
        }

        // 间隔重复：每次练字都更新复习状态
        if charID.hasPrefix("kid:") {
            updateReviewState(charID: charID, score: score)
        }
        Self.maybeUpdateStreak(state: self)
    }

    /// 已合格次数
    func passCount(for charID: String) -> Int { passCounts[charID] ?? 0 }
    /// 是否达到掌握阈值
    func isMastered(_ charID: String) -> Bool {
        (passCounts[charID] ?? 0) >= Self.masterThreshold
    }

    // ─── 🐣 虚拟宠物 ──────────────────────────────────────────
    struct PetStage {
        let minExp: Int
        let title: String
        let emoji: String
        let tagline: String
    }
    static let petStages: [PetStage] = [
        .init(minExp: 0,   title: "蛋",   emoji: "🥚", tagline: "还没孵化呢"),
        .init(minExp: 30,  title: "雏鸟", emoji: "🐣", tagline: "刚刚破壳"),
        .init(minExp: 90,  title: "小鸟", emoji: "🐥", tagline: "学会走路啦"),
        .init(minExp: 180, title: "鸟儿", emoji: "🐤", tagline: "会唱歌了"),
        .init(minExp: 300, title: "凤鸟", emoji: "🦅", tagline: "羽毛真漂亮"),
        .init(minExp: 500, title: "神鸟", emoji: "🦚", tagline: "传说中的神鸟")
    ]
    var petStage: PetStage {
        Self.petStages.reversed().first { petExp >= $0.minExp } ?? Self.petStages[0]
    }
    var petStageIndex: Int {
        Self.petStages.firstIndex { $0.minExp == petStage.minExp } ?? 0
    }
    var petNextStage: PetStage? {
        let i = petStageIndex
        return Self.petStages.indices.contains(i + 1) ? Self.petStages[i + 1] : nil
    }
    /// 心情：综合饱食度与最后喂养时间
    var petMood: String {
        if petFood >= 80 { return "😊" }
        if petFood >= 50 { return "🙂" }
        if petFood >= 25 { return "😕" }
        return "😢"
    }

    func feedPet(byScore score: Int) {
        let expGain = score >= 95 ? 20 : (score >= 85 ? 15 : 10)
        petExp += expGain
        petFood = min(100, petFood + 10)
        petLastFed = Self.dayKey(Date())
    }

    func manualFeedPet() {
        petFood = min(100, petFood + 5)
        petLastFed = Self.dayKey(Date())
    }

    func equipOutfit(_ key: String) {
        guard petOutfitsOwned.contains(key) else { return }
        petOutfit = key
    }

    func unlockOutfitIfReached() {
        // 根据阶段自动解锁装扮
        let unlockMap: [Int: String] = [
            1: "scarf",   // 雏鸟解锁围巾
            2: "hat",     // 小鸟解锁帽子
            3: "bow",     // 鸟儿解锁领结
            4: "crown",   // 凤鸟解锁皇冠
            5: "halo"     // 神鸟解锁光环
        ]
        if let key = unlockMap[petStageIndex] {
            petOutfitsOwned.insert(key)
        }
    }

    /// 每日自动扣饱食（隔天打开自动扣 15）
    private static func decayPetIfNeeded(state: AppState) {
        let today = dayKey(Date())
        if state.petLastFed != today && !state.petLastFed.isEmpty {
            state.petFood = max(0, state.petFood - 15)
        }
    }

    // ─── 📜 毕业证书 ──────────────────────────────────────────
    /// L1 (幼儿基础 19 字) 是否已毕业
    var hasGraduatedL1: Bool {
        KidsCharacters.all.allSatisfy { doneStrokeIDs.contains($0.id) }
    }
    var hasIssuedL1Cert: Bool { !certL1IssuedDate.isEmpty }
    func issueL1CertIfNeeded() {
        if hasGraduatedL1 && certL1IssuedDate.isEmpty {
            certL1IssuedDate = Self.dayKey(Date())
        }
    }

    // ─── 📖 识字小故事 ──────────────────────────────────────
    func markStoryRead(_ id: String) {
        storiesRead.insert(id)
    }

    // ─── 🎨 填色描字 ──────────────────────────────────────
    func markCharColored(_ charID: String) {
        coloredChars.insert(charID)
    }

    // ─── 🔍 字卡找找看 ──────────────────────────────────────
    func markFindCompleted(_ levelID: String) {
        findCompleted.insert(levelID)
    }

    /// 记录一次组字合成学习
    func recordComposite(_ glyph: String) {
        compositesLearned.insert(glyph)
        bumpWeekly(2)  // 周挑战：组字 +1
    }

    // ─── 间隔重复 SM-2 ──────────────────────────────────────
    private static let intervalDays: [Int] = [1, 2, 4, 7, 14, 30]

    /// 练字后更新复习状态
    func updateReviewState(charID: String, score: Int) {
        var state = reviewStates[charID] ?? ReviewState(
            box: 0, ease: 2.5, nextReviewDay: "",
            lastScore: 0, reviewCount: 0
        )
        // quality 0-5（score/20）
        let q = min(5, max(0, score / 20))
        if q < 3 {
            // 答差 → 重置到盒子 0
            state.box = 0
        } else {
            state.box = min(5, state.box + 1)
            let qd = Double(q)
            state.ease = max(1.3, state.ease + 0.1 - (5 - qd) * (0.08 + (5 - qd) * 0.02))
        }
        let interval = Self.intervalDays[min(state.box, Self.intervalDays.count - 1)]
        let cal = Calendar.current
        if let next = cal.date(byAdding: .day, value: interval, to: Date()) {
            state.nextReviewDay = Self.dayKey(next)
        }
        state.lastScore = score
        state.reviewCount += 1
        reviewStates[charID] = state
    }

    /// 今日需要复习的字（包括 nextReviewDay <= today 的所有已掌握字）
    func charsDueForReview() -> [String] {
        let today = Self.dayKey(Date())
        return reviewStates.compactMap { kv -> String? in
            kv.value.nextReviewDay <= today ? kv.key : nil
        }
        .sorted { ($0) < ($1) }
    }

    var todayReviewCount: Int { charsDueForReview().count }

    // ─── 认字闪卡 ──────────────────────────────────────────
    func recordFlashcardSession(count: Int) {
        let today = Self.dayKey(Date())
        flashcardSessions[today, default: 0] += count
    }

    // ─── 字形演变 ──────────────────────────────────────────
    func markEvolutionSeen(_ charID: String) {
        evolutionSeen.insert(charID)
    }

    // ─── 每周挑战 ──────────────────────────────────────────────
    struct WeeklyMission {
        let icon: String
        let title: String
        let target: Int       // 目标次数
        let rewardEmoji: String
        let rewardLabel: String
    }

    static let weeklyMissions: [WeeklyMission] = [
        .init(icon: "✏️", title: "本周学会 5 个新字",
              target: 5, rewardEmoji: "🏆", rewardLabel: "练字小达人徽章"),
        .init(icon: "🎮", title: "本周玩 6 次小游戏",
              target: 6, rewardEmoji: "🎖️", rewardLabel: "游戏王徽章"),
        .init(icon: "🧩", title: "本周学会 3 个组字",
              target: 3, rewardEmoji: "🎨", rewardLabel: "小小拼字家徽章")
    ]

    func weeklyClaim(_ index: Int) {
        guard weeklyClaimed.indices.contains(index),
              weeklyProgress.indices.contains(index) else { return }
        let m = Self.weeklyMissions[index]
        if weeklyProgress[index] >= m.target, !weeklyClaimed[index] {
            weeklyClaimed[index] = true
        }
    }

    private func bumpWeekly(_ index: Int) {
        Self.refreshWeeklyIfNeeded(state: self)
        guard weeklyProgress.indices.contains(index) else { return }
        weeklyProgress[index] += 1
    }

    private static func refreshWeeklyIfNeeded(state: AppState) {
        let current = weekKey(Date())
        if state.weeklyWeek != current {
            state.weeklyWeek = current
            state.weeklyProgress = [0, 0, 0]
            state.weeklyClaimed = [false, false, false]
        }
    }

    private static func weekKey(_ d: Date) -> String {
        let cal = Calendar(identifier: .iso8601)
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d)
        return String(format: "%d-W%02d", comps.yearForWeekOfYear ?? 0, comps.weekOfYear ?? 0)
    }

    // ─── 时长限制 ──────────────────────────────────────────────
    var todayPracticeSeconds: Int {
        todayUsedSeconds[Self.dayKey(Date())] ?? 0
    }
    var todayPracticeMinutes: Int { todayPracticeSeconds / 60 }
    var isTodayLimitReached: Bool {
        dailyLimitMinutes > 0 && todayPracticeMinutes >= dailyLimitMinutes
    }
    var todayRemainingMinutes: Int {
        max(0, dailyLimitMinutes - todayPracticeMinutes)
    }

    // ─── 家长周报数据 ─────────────────────────────────────────
    struct DailyStat {
        let dateKey: String
        let minutes: Int
    }

    /// 过去 7 天的练字分钟数（今天在最后）
    var last7DaysStats: [DailyStat] {
        var out: [DailyStat] = []
        let cal = Calendar.current
        for i in (0..<7).reversed() {
            if let day = cal.date(byAdding: .day, value: -i, to: Date()) {
                let key = Self.dayKey(day)
                out.append(.init(dateKey: key, minutes: dailyMinutes[key] ?? 0))
            }
        }
        return out
    }

    /// 本周练字分钟总数
    var thisWeekMinutes: Int {
        last7DaysStats.reduce(0) { $0 + $1.minutes }
    }

    /// 薄弱字：分数 < 70 的字的 ID 列表
    var weakCharIDs: [String] {
        bestScores.filter { $0.value < 70 && $0.key.hasPrefix("kid:") }
            .sorted { $0.value < $1.value }
            .map { $0.key }
    }

    /// 幼儿游戏成绩上报
    /// - Parameters:
    ///   - id: 游戏 ID，如 "listen_tap" / "memory_match" / "bubble_pop"
    ///   - score: 0-100
    func recordKidGame(id: String, score: Int) {
        Self.refreshMissionIfNeeded(state: self)
        Self.refreshWeeklyIfNeeded(state: self)
        let prev = gameBests[id] ?? 0
        if score > prev { gameBests[id] = score }
        // 每日任务：玩过一局游戏
        setMissionDone(1)
        // 周挑战：玩游戏 +1
        bumpWeekly(1)
    }

    /// 获取某游戏的奖牌等级：0 无 / 1 铜 / 2 银 / 3 金
    func medalFor(gameID id: String) -> Int {
        let best = gameBests[id] ?? 0
        if best >= 90 { return 3 }
        if best >= 70 { return 2 }
        if best > 0  { return 1 }
        return 0
    }

    func medalEmoji(for id: String) -> String {
        switch medalFor(gameID: id) {
        case 3: return "🥇"
        case 2: return "🥈"
        case 1: return "🥉"
        default: return ""
        }
    }

    func setMissionDone(_ index: Int) {
        Self.refreshMissionIfNeeded(state: self)
        guard missionDone.indices.contains(index) else { return }
        if !missionDone[index] {
            missionDone[index] = true
        }
    }

    /// 每日任务是否全部完成
    var allMissionsDone: Bool {
        missionDone.allSatisfy { $0 }
    }

    func markOnboarded() {
        onboarded = true
        Self.maybeUpdateStreak(state: self)
    }

    func resetAll() {
        doneStrokeIDs = []
        bestScores = [:]
        totalChars = 0
        totalMinutes = 0
        streakDays = 0
        bestSpeedScore = 0
        stickers = []
        passCounts = [:]
        gameBests = [:]
        missionDone = [false, false, false]
        missionDate = ""
        weeklyWeek = ""
        weeklyProgress = [0, 0, 0]
        weeklyClaimed = [false, false, false]
        dailyMinutes = [:]
        todayUsedSeconds = [:]
        compositesLearned = []
        petName = "墨墨"
        petFood = 60
        petExp = 0
        petLastFed = ""
        petOutfit = "default"
        petOutfitsOwned = ["default"]
        certL1IssuedDate = ""
        storiesRead = []
        coloredChars = []
        findCompleted = []
        reviewStates = [:]
        flashcardSessions = [:]
        evolutionSeen = []
        UserDefaults.standard.removeObject(forKey: Key.lastPractice)
    }

    // ─── 每日任务 ──────────────────────────────────────────────
    private static func refreshMissionIfNeeded(state: AppState) {
        let today = dayKey(Date())
        if state.missionDate != today {
            state.missionDate = today
            state.missionDone = [false, false, false]
        }
    }

    struct KidMission {
        let icon: String
        let title: String
    }

    static let kidMissions: [KidMission] = [
        .init(icon: "✏️", title: "学会一个新字"),
        .init(icon: "🎮", title: "玩一局小游戏"),
        .init(icon: "🌟", title: "收集一枚贴纸")
    ]

    func setMode(_ m: UserMode) {
        userMode = m
    }

    // ─── 打卡逻辑 ───────────────────────────────────────────────────
    private static func maybeUpdateStreak(state: AppState) {
        let today = dayKey(Date())
        let last = UserDefaults.standard.string(forKey: Key.lastPractice)
        if last == today { return }
        let yesterday = dayKey(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        if last == yesterday {
            state.streakDays += 1
        } else {
            state.streakDays = max(state.streakDays, 1)
        }
        UserDefaults.standard.set(today, forKey: Key.lastPractice)
    }

    static func dayKey(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    // ─── 辅助 ───────────────────────────────────────────────────────
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
