import SwiftUI

/// 首页：今日学习 + 路径进度 + 小游戏入口
struct HomeView: View {
    @EnvironmentObject var app: AppState
    var onStartPractice: () -> Void
    var onOpenGame: () -> Void

    @State private var presentedGame: GameType? = nil
    @State private var presentedSheet: KidSheet? = nil
    @State private var showLimitAlert: Bool = false

    enum GameType: String, Identifiable {
        case speedWriter, strokeCop, radicalPuzzle, zenWrite
        case kidListenTap, kidMemoryMatch, kidBubblePop
        var id: String { rawValue }
    }

    enum KidSheet: String, Identifiable {
        case composite, growthTree, weeklyMission, parentReport
        case virtualPet, certificate, story, colorChar, findChar
        case review, flashcard, evolution, library
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if app.isKidMode {
                        if app.hasGraduatedL1 && !app.hasIssuedL1Cert {
                            graduationBanner
                        }
                        if app.todayReviewCount > 0 {
                            reviewBanner
                        }
                        kidTodayCard
                        hugeLibraryCTA   // 1800 字库大入口，放在顶部最显眼位置
                        kidToolsRow
                        kidLearnRow
                        kidMissionCard
                        kidGamesSection
                        kidCharGrid
                    } else {
                        todayCard
                        pathSection
                        gamesSection
                    }
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $presentedGame) { game in
            switch game {
            case .speedWriter:     SpeedWriterView().environmentObject(app)
            case .strokeCop:       StrokeCopView().environmentObject(app)
            case .radicalPuzzle:   RadicalPuzzleView().environmentObject(app)
            case .zenWrite:        ZenWriteView().environmentObject(app)
            case .kidListenTap:    KidListenTapGame().environmentObject(app)
            case .kidMemoryMatch:  KidMemoryMatchGame().environmentObject(app)
            case .kidBubblePop:    KidBubblePopGame().environmentObject(app)
            }
        }
        .fullScreenCover(item: $presentedSheet) { sheet in
            switch sheet {
            case .composite:       CompositeLearnView().environmentObject(app)
            case .growthTree:      GrowthTreeView().environmentObject(app)
            case .weeklyMission:   WeeklyMissionView().environmentObject(app)
            case .parentReport:    ParentReportView().environmentObject(app)
            case .virtualPet:      VirtualPetView().environmentObject(app)
            case .certificate:     CertificateView().environmentObject(app)
            case .story:           StoryView().environmentObject(app)
            case .colorChar:       ColorCharView().environmentObject(app)
            case .findChar:        FindCharView().environmentObject(app)
            case .review:          ReviewView().environmentObject(app)
            case .flashcard:       FlashcardStudyView().environmentObject(app)
            case .evolution:       EvolutionView().environmentObject(app)
            case .library:         HanziLibraryView().environmentObject(app)
            }
        }
        .alert("今天练得够多啦~", isPresented: $showLimitAlert) {
            Button("好的") { }
            Button("让家长看看", role: .cancel) { presentedSheet = .parentReport }
        } message: {
            Text("已经练习 \(app.todayPracticeMinutes) 分钟了，注意保护眼睛，明天再来吧!")
        }
    }

    // ─── 学习入口行：认字 / 演变 / 复习 / 字库 ────────────────────
    private var kidLearnRow: some View {
        HStack(spacing: 8) {
            learnChip(emoji: "📚", title: "认字课",
                      subtitle: flashcardSubtitle(),
                      tint: Color(red: 0.40, green: 0.72, blue: 0.48)) {
                presentedSheet = .flashcard
            }
            learnChip(emoji: "📜", title: "字的一生",
                      subtitle: evolutionSubtitle(),
                      tint: Color(red: 0.60, green: 0.45, blue: 0.30)) {
                presentedSheet = .evolution
            }
            learnChip(emoji: "🔄", title: "今日复习",
                      subtitle: reviewSubtitle(),
                      tint: Color(red: 0.85, green: 0.35, blue: 0.35)) {
                presentedSheet = .review
            }
            learnChip(emoji: "🈶", title: "字库",
                      subtitle: librarySubtitle(),
                      tint: Color(red: 0.30, green: 0.50, blue: 0.80)) {
                presentedSheet = .library
            }
        }
    }

    private func librarySubtitle() -> String {
        let total = HanziPool.totalCount
        let learned = HanziPool.all.filter { app.doneStrokeIDs.contains("kid:" + $0.glyph) }.count
        return learned > 0 ? "\(learned)/\(total) 字" : "\(total) 字"
    }

    private func flashcardSubtitle() -> String {
        let today = AppState.dayKey(Date())
        let n = app.flashcardSessions[today] ?? 0
        return n > 0 ? "今日 \(n) 字" : "5 个字包"
    }
    private func evolutionSubtitle() -> String {
        let n = app.evolutionSeen.count
        return n > 0 ? "看过 \(n)/12" : "12 个字"
    }
    private func reviewSubtitle() -> String {
        let n = app.todayReviewCount
        return n > 0 ? "\(n) 个字等你" : "全部掌握 ✓"
    }

    private func learnChip(emoji: String, title: String, subtitle: String,
                           tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(emoji).font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [tint, tint.opacity(0.8)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: tint.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // ─── 今日复习横幅（有字到期时） ─────────────────────────
    private var reviewBanner: some View {
        Button {
            presentedSheet = .review
        } label: {
            HStack(spacing: 10) {
                Text("🔄").font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("今天有 \(app.todayReviewCount) 个字要复习")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("温故知新，记得更牢")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(12)
            .background(
                LinearGradient(colors: [
                    Color(red: 0.85, green: 0.35, blue: 0.35),
                    Color(red: 0.65, green: 0.25, blue: 0.40)
                ], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // ─── 毕业横幅 ──────────────────────────────────────────
    private var graduationBanner: some View {
        Button {
            presentedSheet = .certificate
        } label: {
            HStack(spacing: 12) {
                Text("🎓").font(.system(size: 40))
                VStack(alignment: .leading, spacing: 2) {
                    Text("恭喜毕业啦!")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                    Text("点我领取专属毕业证书")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(16)
            .background(
                LinearGradient(colors: [
                    Theme.gold,
                    Color(red: 0.85, green: 0.55, blue: 0.20)
                ], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Theme.gold.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    // ─── 幼儿模式：工具入口（两行 4x2） ────────────────────
    private var kidToolsRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                toolChip(emoji: petStageEmoji(),
                         title: petLabel(),
                         subtitle: petSubtitle(),
                         tint: Color(red: 0.95, green: 0.55, blue: 0.45)) {
                    presentedSheet = .virtualPet
                }
                toolChip(emoji: "🌳", title: "成长树",
                         subtitle: treeWord(),
                         tint: Color(red: 0.26, green: 0.66, blue: 0.48)) {
                    presentedSheet = .growthTree
                }
                toolChip(emoji: "🏅", title: "周挑战",
                         subtitle: weeklyWord(),
                         tint: Color(red: 0.95, green: 0.55, blue: 0.30)) {
                    presentedSheet = .weeklyMission
                }
                toolChip(emoji: "🎓", title: "证书",
                         subtitle: certSubtitle(),
                         tint: Theme.gold) {
                    presentedSheet = .certificate
                }
            }
            HStack(spacing: 8) {
                toolChip(emoji: "🧩", title: "组字",
                         subtitle: composWord(),
                         tint: Color(red: 0.56, green: 0.40, blue: 0.74)) {
                    presentedSheet = .composite
                }
                toolChip(emoji: "📖", title: "小故事",
                         subtitle: storySubtitle(),
                         tint: Color(red: 0.80, green: 0.45, blue: 0.35)) {
                    presentedSheet = .story
                }
                toolChip(emoji: "🎨", title: "填色",
                         subtitle: colorSubtitle(),
                         tint: Color(red: 0.42, green: 0.62, blue: 0.82)) {
                    presentedSheet = .colorChar
                }
                toolChip(emoji: "🔍", title: "找找看",
                         subtitle: findSubtitle(),
                         tint: Color(red: 0.32, green: 0.62, blue: 0.48)) {
                    presentedSheet = .findChar
                }
            }
            // 家长入口单独放最下（更小一点，避免小朋友误触）
            HStack {
                Spacer()
                Button {
                    presentedSheet = .parentReport
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("家长专区").font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Theme.muted)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(Color.white.opacity(0.6)))
                    .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func petStageEmoji() -> String { app.petStage.emoji }
    private func petLabel() -> String { app.petName }
    private func petSubtitle() -> String {
        if app.petFood < 30 { return "🍎 饿肚子啦" }
        return "Lv. \(app.petStageIndex + 1) \(app.petStage.title)"
    }
    private func certSubtitle() -> String {
        if app.hasIssuedL1Cert { return "✓ 已获得" }
        if app.hasGraduatedL1  { return "可领取!" }
        let n = KidsCharacters.all.filter { app.doneStrokeIDs.contains($0.id) }.count
        return "\(n)/\(KidsCharacters.all.count) 字"
    }
    private func storySubtitle() -> String {
        let n = app.storiesRead.count
        return n > 0 ? "已读 \(n)/6" : "6 个故事"
    }
    private func colorSubtitle() -> String {
        let n = app.coloredChars.count
        return n > 0 ? "已涂 \(n)" : "12 个字"
    }
    private func findSubtitle() -> String {
        let n = app.findCompleted.count
        return n > 0 ? "已通关 \(n)/5" : "5 关挑战"
    }

    private func composWord() -> String {
        let n = app.compositesLearned.count
        return n > 0 ? "已学会 \(n) 个" : "拼字游戏"
    }
    private func treeWord() -> String {
        let n = app.doneStrokeIDs.filter { $0.hasPrefix("kid:") }.count + app.compositesLearned.count
        if n >= 50 { return "🍎 果树" }
        if n >= 30 { return "🌲 大树" }
        if n >= 15 { return "🌳 小树" }
        if n >= 5  { return "🌿 小苗" }
        return "🌱 种子"
    }
    private func weeklyWord() -> String {
        let doneCount = app.weeklyClaimed.filter { $0 }.count
        return doneCount > 0 ? "已领 \(doneCount)/3" : "3 个任务"
    }

    private func toolChip(emoji: String, title: String, subtitle: String,
                          tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 26))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [tint, tint.opacity(0.8)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: tint.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    // ─── 幼儿模式：每日任务卡 ────────────────────────────────────
    private var kidMissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Text("📋").font(.system(size: 18))
                    Text("今日任务")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(Theme.ink)
                }
                Spacer()
                if app.allMissionsDone {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("全部完成!")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Theme.gold))
                    .transition(.scale)
                } else {
                    let doneCount = app.missionDone.filter { $0 }.count
                    Text("\(doneCount) / \(AppState.kidMissions.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.accent)
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Theme.accent.opacity(0.12)))
                }
            }

            VStack(spacing: 8) {
                ForEach(Array(AppState.kidMissions.enumerated()), id: \.offset) { idx, mission in
                    let done = app.missionDone.indices.contains(idx) && app.missionDone[idx]
                    HStack(spacing: 10) {
                        Text(mission.icon).font(.system(size: 20))
                        Text(mission.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(done ? Theme.muted : Theme.ink)
                            .strikethrough(done, color: Theme.muted)
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(done ? Theme.accent : Color.white)
                                .frame(width: 22, height: 22)
                            Circle()
                                .stroke(done ? Color.clear : Theme.line, lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            if done {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(done
                                  ? Color(red: 1.0, green: 0.96, blue: 0.88)
                                  : Color.white)
                    )
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.97, blue: 0.88),
                    Color.white
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.gold.opacity(0.35), lineWidth: 1.5)
        )
    }

    // ─── 幼儿模式：游戏区 ───────────────────────────────────────
    private var kidGamesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🎮 小游戏")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Theme.ink)
                Spacer()
                let totalMedals =
                    (app.medalFor(gameID: "listen_tap") > 0 ? 1 : 0) +
                    (app.medalFor(gameID: "memory_match") > 0 ? 1 : 0) +
                    (app.medalFor(gameID: "bubble_pop") > 0 ? 1 : 0)
                if totalMedals > 0 {
                    HStack(spacing: 2) {
                        Text("🏅").font(.system(size: 12))
                        Text("\(totalMedals)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.gold)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Theme.gold.opacity(0.15)))
                }
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                kidGameCard(
                    title: "听音找字",
                    subtitle: "听拼音找对应的字",
                    emoji: "🔊",
                    bg: LinearGradient(
                        colors: [Color(red: 0.30, green: 0.55, blue: 0.85),
                                 Color(red: 0.18, green: 0.35, blue: 0.68)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    gameID: "listen_tap"
                ) { presentedGame = .kidListenTap }

                kidGameCard(
                    title: "翻翻配对",
                    subtitle: "配对字和图画",
                    emoji: "🃏",
                    bg: LinearGradient(
                        colors: [Color(red: 0.56, green: 0.40, blue: 0.74),
                                 Color(red: 0.38, green: 0.22, blue: 0.58)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    gameID: "memory_match"
                ) { presentedGame = .kidMemoryMatch }

                kidGameCard(
                    title: "蹦字泡",
                    subtitle: "30 秒快点字泡",
                    emoji: "🫧",
                    bg: LinearGradient(
                        colors: [Color(red: 0.26, green: 0.66, blue: 0.48),
                                 Color(red: 0.12, green: 0.48, blue: 0.36)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    gameID: "bubble_pop"
                ) { presentedGame = .kidBubblePop }

                kidGameCard(
                    title: "敬请期待",
                    subtitle: "更多有趣游戏",
                    emoji: "✨",
                    bg: LinearGradient(
                        colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    gameID: nil,
                    disabled: true
                ) { }
            }
        }
    }

    private func kidGameCard(
        title: String,
        subtitle: String,
        emoji: String,
        bg: LinearGradient,
        gameID: String?,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(emoji).font(.system(size: 28))
                    Spacer()
                    if let id = gameID {
                        let medal = app.medalEmoji(for: id)
                        if !medal.isEmpty {
                            Text(medal)
                                .font(.system(size: 22))
                                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                        }
                    }
                }
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
                if let id = gameID, let best = app.gameBests[id], best > 0 {
                    Text("最佳 \(best)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.22)))
                        .padding(.top, 2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            .opacity(disabled ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    // ─── 幼儿模式：今日学习大卡片 ──────────────────────────────
    private var kidTodayCard: some View {
        let next = app.nextStage ?? KidsCharacters.all[0]
        let allDone = app.nextStage == nil
        let allKidChars = KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all
        let doneCount = allKidChars.filter { app.doneStrokeIDs.contains($0.id) }.count
        let limited = app.isTodayLimitReached

        return GatedNavLink(limited: limited, destination: {
            KidPracticeSessionView(startCharID: next.id)
                .environmentObject(app)
        }, onBlocked: { showLimitAlert = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(allDone ? "太棒了 · 20 字都掌握啦" : "今天来写：")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 20))
                }

                HStack(alignment: .center, spacing: 16) {
                    // 大字
                    Text(next.glyph)
                        .font(.system(size: 100, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .frame(width: 140, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(next.title)
                            .font(.system(size: 30, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        if let m = KidsCharacters.metaFor(next.id) {
                            HStack(spacing: 10) {
                                Text(m.emoji)
                                    .font(.system(size: 26))
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(m.pinyin)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.55))
                                        .tracking(1)
                                    Text(m.meaning)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        Text(next.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.85))
                        HStack(spacing: 4) {
                            Image(systemName: "pencil.and.scribble")
                            Text("\(next.strokes.count) 笔")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }

                    Spacer()
                }

                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    Text("已学会 \(doneCount) / \(allKidChars.count) 字")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text(allDone ? "再写一遍" : "开始写")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.ink)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(Capsule().fill(Color(red: 1.0, green: 0.85, blue: 0.45)))
                }
                .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.35, blue: 0.25),
                        Color(red: 0.95, green: 0.55, blue: 0.30)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
    }

    // ─── 幼儿模式：字网格（精选 79 字 + 1800 字库大入口 + 高频分级） ─
    private var kidCharGrid: some View {
        let curatedGroups = KidsCharacters.groups
            + KidsCharactersExtra.groups
            + KidsCharactersPack3.groups
        return VStack(alignment: .leading, spacing: 10) {
            // 1. 精选 79 字（带 emoji 贴纸 cheer，体验最佳）
            ForEach(curatedGroups.indices, id: \.self) { i in
                let group = curatedGroups[i]
                sectionTitle(group.title)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                          spacing: 10) {
                    ForEach(group.chars) { c in
                        let limited = app.isTodayLimitReached
                        GatedNavLink(limited: limited, destination: {
                            KidPracticeSessionView(startCharID: c.id)
                                .environmentObject(app)
                        }, onBlocked: { showLimitAlert = true }) {
                            kidCharCard(c)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 6)
            }

            // 2. HanziPool 按频率分段直接显示（字库大入口已在顶部，这里不再重复）
            hanziPoolTieredGroups
        }
    }

    // 显眼的字库入口卡
    private var hugeLibraryCTA: some View {
        Button {
            presentedSheet = .library
        } label: {
            HStack(spacing: 14) {
                Text("🈶").font(.system(size: 44))
                VStack(alignment: .leading, spacing: 3) {
                    Text("1800 字大字库")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                    Text("按频率分 6 级 · 启蒙/初级/中级/高级/进阶/补充")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.88))
                    let learned = HanziPool.all
                        .filter { app.doneStrokeIDs.contains("kid:" + $0.glyph) }.count
                    Text("已学会 \(learned) / \(HanziPool.totalCount) 字")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.88, blue: 0.50))
                        .padding(.top, 2)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(16)
            .background(
                LinearGradient(colors: [
                    Color(red: 0.22, green: 0.40, blue: 0.75),
                    Color(red: 0.35, green: 0.26, blue: 0.60)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.blue.opacity(0.18), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
    }

    // HanziPool 按频率分 3 段直接在首页展示（前 50 / 51-150 / 151-300）
    private var hanziPoolTieredGroups: some View {
        let total = HanziPool.totalCount
        let curatedIds = Set((KidsCharacters.all
                              + KidsCharactersExtra.all
                              + KidsCharactersPack3.all).map(\.glyph))
        // 从 HanziPool 里挑不在 curated 里的，按 Pool 原顺序
        let extras = HanziPool.all.filter { !curatedIds.contains($0.glyph) }
        let tiers: [(title: String, start: Int, end: Int)] = [
            ("🔥 最常用 · 前 50 字", 0, min(50, extras.count)),
            ("⭐ 常用 · 51-150 字", 50, min(150, extras.count)),
            ("📖 基础 · 151-300 字", 150, min(300, extras.count))
        ]
        _ = total
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(tiers.indices, id: \.self) { i in
                let t = tiers[i]
                if t.start < t.end {
                    sectionTitle(t.title)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                              spacing: 10) {
                        ForEach(Array(extras[t.start..<t.end]), id: \.glyph) { h in
                            let limited = app.isTodayLimitReached
                            GatedNavLink(limited: limited, destination: {
                                KidPracticeSessionView(startCharID: "kid:" + h.glyph)
                                    .environmentObject(app)
                            }, onBlocked: { showLimitAlert = true }) {
                                hanziPoolCard(h)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            // 底部再次强调去字库看完整的 1800
            Button {
                presentedSheet = .library
            } label: {
                HStack {
                    Spacer()
                    Text("查看全部 \(HanziPool.totalCount) 字 →")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.accent)
                    Spacer()
                }
                .padding(12)
                .background(Color.white.opacity(0.7))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private func hanziPoolCard(_ h: HanziChar) -> some View {
        let done = app.doneStrokeIDs.contains("kid:" + h.glyph)
        return VStack(spacing: 3) {
            Text(h.glyph)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(done ? .white : Theme.ink)
                .frame(width: 56, height: 56)
                .background(done
                            ? Color(red: 0.85, green: 0.35, blue: 0.25)
                            : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(done ? Color.clear : Theme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(done ? 0.15 : 0.05), radius: 3, y: 1)
            Text(h.pinyin)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(Theme.gold)
                .lineLimit(1)
        }
    }

    private func kidCharCard(_ c: CharacterDef) -> some View {
        let done = app.doneStrokeIDs.contains(c.id)
        return VStack(spacing: 4) {
            Text(c.glyph)
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundColor(done ? .white : Theme.ink)
                .frame(width: 70, height: 70)
                .background(
                    done
                    ? Color(red: 0.85, green: 0.35, blue: 0.25)
                    : Color.white
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(done ? Color.clear : Theme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(done ? 0.15 : 0.05), radius: 4, y: 2)

            if let m = KidsCharacters.metaFor(c.id) {
                HStack(spacing: 3) {
                    Text(m.emoji)
                        .font(.system(size: 13))
                    Text(m.pinyin)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.gold)
                }
            }

            HStack(spacing: 2) {
                if done {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.2))
                    Text("已学会")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.25))
                } else {
                    Text("\(c.strokes.count) 笔")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.muted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // ─── 今日学习大卡片 ──────────────────────────────────────────
    private var todayCard: some View {
        let next = app.nextStage ?? app.curriculum.last!
        let allDone = app.nextStage == nil
        let idxInCurriculum = app.curriculum.firstIndex(where: { $0.id == next.id }) ?? 0
        let sectionLabel: String = {
            if allDone { return "全部完成" }
            return next.level == 1 ? "今日学习 · L1 八画" : "今日学习 · L2 偏旁"
        }()
        let seqLabel: String = {
            if allDone { return "恭喜 · 已走完基础路径" }
            if next.level == 1 {
                let idx = StandardStrokes.all.firstIndex(where: { $0.id == next.id }) ?? 0
                return "第\(idx + 1)笔 · \(next.title)"
            } else {
                let idx = StandardRadicals.all.firstIndex(where: { $0.id == next.id }) ?? 0
                return "第\(idx + 1)偏旁 · \(next.title)"
            }
        }()
        _ = idxInCurriculum

        return NavigationLink {
            PracticeSessionView(startCharID: next.id)
                .environmentObject(app)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(sectionLabel)
                        .font(.system(size: 11))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.75))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.7))
                }
                Text(seqLabel)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .tracking(2)
                    .foregroundColor(.white)
                Text(allDone ? "下一段位即将解锁：L3 独体字" : next.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.top, 2)

                // L1 完成时给一个"解锁 L2"的小提示
                if app.isL1Complete && !app.isL2Complete && next.level == 2 {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.open.fill")
                        Text("已解锁 L2 偏旁部首")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.gold)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Theme.gold.opacity(0.2))
                    .clipShape(Capsule())
                    .padding(.top, 4)
                }

                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(allDone ? "继续练习" : "开始练习")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                }
                .padding(.top, 12)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Theme.ink, Color(red: 0.22, green: 0.22, blue: 0.22)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    Text("墨")
                        .font(.system(size: 200, weight: .black, design: .serif))
                        .foregroundColor(.white.opacity(0.04))
                        .offset(x: 80, y: 28)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func doneIndex(of c: CharacterDef) -> Int {
        StandardStrokes.all.firstIndex(where: { $0.id == c.id }) ?? 0
    }

    // ─── 六级路径 ────────────────────────────────────────────────
    private var pathSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("我的路径")
            HStack(spacing: 6) {
                pathLevel("L0", "开蒙", status: .done)
                pathLevel("L1", "八画",
                          status: app.isL1Complete ? .done : .current,
                          progress: l1Progress())
                pathLevel("L2", "偏旁",
                          status: l2Status(),
                          progress: l2Progress())
                pathLevel("L3", "独体", status: .locked)
                pathLevel("L4", "结构", status: .locked)
                pathLevel("L5", "成字", status: .locked)
            }
        }
    }

    private func l1Progress() -> Double {
        let done = StandardStrokes.all.filter { app.doneStrokeIDs.contains($0.id) }.count
        return Double(done) / Double(StandardStrokes.all.count)
    }
    private func l2Progress() -> Double {
        let done = StandardRadicals.all.filter { app.doneStrokeIDs.contains($0.id) }.count
        return Double(done) / Double(StandardRadicals.all.count)
    }
    private func l2Status() -> PathStatus {
        if app.isL2Complete { return .done }
        if app.isL1Complete { return .current }
        return .locked
    }

    enum PathStatus { case done, current, locked }

    private func pathLevel(_ id: String, _ title: String, status: PathStatus, progress: Double = 0) -> some View {
        VStack(spacing: 2) {
            Text(id)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(color(for: status).0)
            Text(title)
                .font(.system(size: 11))
                .tracking(1)
                .foregroundColor(color(for: status).1)
            if status == .current {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.25)).frame(height: 2)
                        Capsule().fill(Theme.accent).frame(width: geo.size.width * progress, height: 2)
                    }
                }.frame(height: 2).padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(bg(for: status))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func color(for s: PathStatus) -> (Color, Color) {
        switch s {
        case .done:    return (Theme.accent, Theme.ink)
        case .current: return (.white, .white.opacity(0.85))
        case .locked:  return (Theme.muted, Theme.muted)
        }
    }

    @ViewBuilder
    private func bg(for s: PathStatus) -> some View {
        switch s {
        case .done:    Theme.highlight
        case .current: Theme.ink
        case .locked:  Color.white
        }
    }

    // ─── 小游戏 ───────────────────────────────────────────────────
    private var gamesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("来玩一局")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                gameCard(title: "速写达人",
                         desc: "60 秒挑战",
                         badge: app.bestSpeedScore > 0 ? "最佳 \(app.bestSpeedScore)" : "NEW",
                         tint: Theme.accent) {
                    presentedGame = .speedWriter
                }
                gameCard(title: "笔顺警察",
                         desc: "找出顺序错误",
                         badge: "5 题",
                         tint: Theme.accent2) {
                    presentedGame = .strokeCop
                }
                gameCard(title: "部首拼图",
                         desc: "碎片拼成完整字",
                         badge: "L2 联动",
                         tint: Theme.gold) {
                    presentedGame = .radicalPuzzle
                }
                gameCard(title: "静心禅写",
                         desc: "千字文跟写 · 无评分",
                         badge: "禅 Zen",
                         tint: Theme.accent2) {
                    presentedGame = .zenWrite
                }
            }
        }
    }

    private func gameCard(title: String, desc: String, badge: String, tint: Color, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .tracking(1)
                        .foregroundColor(Theme.ink)
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .foregroundColor(.white)
                        .background(tint)
                        .clipShape(Capsule())
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding(14)
            .frame(height: 100)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(disabled ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 12))
            .tracking(2)
            .foregroundColor(Theme.muted)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - 带时长闸的导航链接
// ─────────────────────────────────────────────────────────────
//
// 用法：
//   GatedNavLink(limited: app.isTodayLimitReached,
//                destination: { KidPracticeSessionView(...) },
//                onBlocked: { showLimitAlert = true }) {
//       cardContent
//   }
//
// 当 limited=false 时等同于 NavigationLink
// 当 limited=true 时点击会触发 onBlocked 而不跳转

struct GatedNavLink<Destination: View, Label: View>: View {
    let limited: Bool
    let destination: () -> Destination
    let onBlocked: () -> Void
    let label: () -> Label

    init(limited: Bool,
         @ViewBuilder destination: @escaping () -> Destination,
         onBlocked: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.limited = limited
        self.destination = destination
        self.onBlocked = onBlocked
        self.label = label
    }

    var body: some View {
        if limited {
            Button(action: onBlocked) {
                label()
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(destination: destination(), label: label)
                .buttonStyle(.plain)
        }
    }
}
