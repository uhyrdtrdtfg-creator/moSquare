import SwiftUI

// ─────────────────────────────────────────────────────────────────
// MARK: - 练字 Tab（L1 八画总览，点击进入 Session）
// ─────────────────────────────────────────────────────────────────

struct PracticeView: View {
    @EnvironmentObject var app: AppState
    @State private var selectedLevel: Int = 1
    @State private var showLimitAlert: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if app.isKidMode {
                        kidPracticeContent
                    } else {
                        header
                        levelPicker
                        if selectedLevel == 1 {
                            strokeGrid(StandardStrokes.all)
                        } else {
                            if app.isL1Complete {
                                strokeGrid(StandardRadicals.all)
                            } else {
                                lockedL2Tip
                            }
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
        }
        .alert("今天练得够多啦~", isPresented: $showLimitAlert) {
            Button("好的") { }
        } message: {
            Text("已经练习 \(app.todayPracticeMinutes) 分钟了，注意保护眼睛，明天再来吧!")
        }
    }

    // ─── 幼儿模式：按状态分组 ────────────────────────────────
    private var kidPracticeContent: some View {
        let all = KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all
        let learned = all.filter { app.doneStrokeIDs.contains($0.id) }
        let notYet = all.filter { !app.doneStrokeIDs.contains($0.id) }

        return VStack(alignment: .leading, spacing: 16) {
            // 头部
            VStack(alignment: .leading, spacing: 4) {
                Text("我 的 字 库")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .tracking(4)
                HStack(spacing: 4) {
                    Text("已学会")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                    Text("\(learned.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.accent)
                    Text("/ \(all.count) 字")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                }
            }

            // 还没学的字（优先显示）
            if !notYet.isEmpty {
                kidCharSection(title: "👉 还没学会的字", chars: notYet)
            }

            // 已经学会的
            if !learned.isEmpty {
                kidCharSection(title: "⭐ 已经学会的字", chars: learned)
            }
        }
    }

    private func kidCharSection(title: String, chars: [CharacterDef]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.muted)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                      spacing: 10) {
                ForEach(chars) { c in
                    let limited = app.isTodayLimitReached
                    GatedNavLink(limited: limited, destination: {
                        KidPracticeSessionView(startCharID: c.id)
                            .environmentObject(app)
                    }, onBlocked: { showLimitAlert = true }) {
                        kidPracticeCell(c)
                    }
                }
            }
        }
    }

    private func kidPracticeCell(_ c: CharacterDef) -> some View {
        let done = app.doneStrokeIDs.contains(c.id)
        let meta = KidsCharacters.metaFor(c.id)
        return VStack(spacing: 4) {
            Text(c.glyph)
                .font(.system(size: 46, weight: .bold, design: .serif))
                .foregroundColor(done ? .white : Theme.ink)
                .frame(width: 64, height: 64)
                .background(done ? Color(red: 0.85, green: 0.35, blue: 0.25) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(done ? Color.clear : Theme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(done ? 0.15 : 0.05), radius: 4, y: 2)
            if let m = meta {
                Text(m.pinyin)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.gold)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedLevel == 1 ? "L1 · 八画" : "L2 · 偏旁部首")
                .font(.system(size: 12))
                .tracking(3)
                .foregroundColor(Theme.muted)
            Text(selectedLevel == 1 ? "汉字的地基" : "字的零件")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .tracking(2)
            Text(selectedLevel == 1
                 ? "掌握这八种笔画，你就拥有了写好所有汉字的钥匙。"
                 : "偏旁部首是汉字最常见的积木，学会它们才能拼出成千上万的字。")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
                .padding(.top, 2)
        }
    }

    private var levelPicker: some View {
        HStack(spacing: 8) {
            levelChip(level: 1, title: "L1 八画", unlocked: true)
            levelChip(level: 2, title: "L2 偏旁", unlocked: app.isL1Complete)
            Spacer()
        }
    }

    private func levelChip(level: Int, title: String, unlocked: Bool) -> some View {
        Button {
            if unlocked { selectedLevel = level }
        } label: {
            HStack(spacing: 4) {
                if !unlocked { Image(systemName: "lock.fill") }
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold, design: .serif))
            .tracking(2)
            .foregroundColor(selectedLevel == level ? .white : Theme.ink)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(selectedLevel == level ? Theme.ink : Color.white.opacity(0.6))
            .overlay(Capsule().stroke(Theme.line, lineWidth: selectedLevel == level ? 0 : 1))
            .clipShape(Capsule())
            .opacity(unlocked ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    private var lockedL2Tip: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(Theme.muted)
            Text("完成 L1 八画后解锁")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .tracking(2)
                .foregroundColor(Theme.ink)
            Text("先练完八种基本笔画，才能组合成偏旁")
                .font(.system(size: 12))
                .foregroundColor(Theme.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
    }

    private func strokeGrid(_ chars: [CharacterDef]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(chars) { c in
                NavigationLink {
                    PracticeSessionView(startCharID: c.id)
                        .environmentObject(app)
                } label: {
                    strokeCard(c)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func strokeCard(_ c: CharacterDef) -> some View {
        let done = app.doneStrokeIDs.contains(c.id)
        let best = app.bestScores[c.id] ?? 0
        return VStack(spacing: 8) {
            ZStack {
                RiceGrid()
                GuideStrokeView(strokes: c.strokes, opacity: 0.75, showArrow: false)
            }
            .frame(width: 88, height: 88)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line, lineWidth: 1))

            Text(c.title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .tracking(2)
                .foregroundColor(Theme.ink)
            Text(c.subtitle)
                .font(.system(size: 11))
                .foregroundColor(Theme.muted)

            HStack(spacing: 6) {
                if done {
                    Label("已掌握", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Theme.accent)
                        .clipShape(Capsule())
                }
                if best > 0 {
                    Text("最高 \(best)")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.muted)
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 练习会话（核心：观→描→临→背 四阶段）
// ─────────────────────────────────────────────────────────────────

struct PracticeSessionView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State var startCharID: String
    // 零基础用户默认"跟"模式 —— 写偏了立刻阻止，避免错练
    @State private var mode: PracticeMode = .guided
    @State private var strokes: [UserStroke] = []
    @State private var guidedCompletedCount: Int = 0
    @State private var guidedHint: String? = nil
    @State private var guidedShakeToken: Int = 0
    @State private var lastScore: ScoreResult? = nil
    @State private var isShowingCelebration = false
    @State private var sessionStart = Date()

    private var allCurriculum: [CharacterDef] {
        StandardStrokes.all + StandardRadicals.all
    }

    private var current: CharacterDef {
        allCurriculum.first { $0.id == startCharID } ?? StandardStrokes.all[0]
    }

    private var currentIndex: Int {
        allCurriculum.firstIndex { $0.id == startCharID } ?? 0
    }

    private var currentSectionLabel: String {
        if current.level == 1 {
            let idx = StandardStrokes.all.firstIndex { $0.id == startCharID } ?? 0
            return "L1-\(idx + 1)"
        } else {
            let idx = StandardRadicals.all.firstIndex { $0.id == startCharID } ?? 0
            return "L2-\(idx + 1)"
        }
    }

    private var totalInLevel: Int {
        current.level == 1 ? StandardStrokes.all.count : StandardRadicals.all.count
    }

    private var indexInLevel: Int {
        if current.level == 1 {
            return StandardStrokes.all.firstIndex { $0.id == startCharID } ?? 0
        } else {
            return StandardRadicals.all.firstIndex { $0.id == startCharID } ?? 0
        }
    }

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: 14) {
                topBar
                modePicker
                PracticeCanvas(
                    character: current,
                    mode: mode,
                    strokes: $strokes,
                    onStrokeEnd: { stroke in
                        if mode == .guided { handleGuidedStrokeEnd(stroke) }
                    },
                    guidedCompletedCount: guidedCompletedCount,
                    guidedShowStandardInk: true,
                    isKidMode: false
                )
                .modifier(ShakeEffect(shakes: guidedShakeToken))
                .padding(.horizontal, 20)
                .animation(.easeInOut, value: mode)

                // 跟模式下的提示条
                if mode == .guided {
                    guidedStatusBar
                }

                if let s = lastScore {
                    ScoreSheet(result: s, onNext: goNext)
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    HStack {
                        hint
                        Spacer()
                        controlButtons
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            .padding(.top, 12)

            if isShowingCelebration {
                CelebrationView(character: current) {
                    isShowingCelebration = false
                    goNext()
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .onAppear { sessionStart = Date() }
    }

    // ─── 顶栏 ────────────────────────────────────────────────────
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
            }
            .buttonStyle(GhostButtonStyle())

            Spacer()

            VStack(spacing: 2) {
                Text(currentSectionLabel)
                    .font(.system(size: 11))
                    .tracking(2)
                    .foregroundColor(Theme.muted)
                Text(current.title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .tracking(4)
            }

            Spacer()

            Text("\(indexInLevel + 1)/\(totalInLevel)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.muted)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }

    // ─── 跟模式的交互 ────────────────────────────────────────────
    private var guidedStatusBar: some View {
        VStack(spacing: 6) {
            if let hint = guidedHint {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(hint)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.ink)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.orange.opacity(0.15)))
                .overlay(Capsule().stroke(Color.orange.opacity(0.5), lineWidth: 1))
                .transition(.scale.combined(with: .opacity))
            } else if guidedCompletedCount < current.strokes.count {
                let target = current.strokes[guidedCompletedCount]
                HStack(spacing: 6) {
                    Image(systemName: "\(guidedCompletedCount + 1).circle.fill")
                        .foregroundColor(Theme.accent)
                    Text("第 \(guidedCompletedCount + 1) 笔 · \(target.name)")
                        .font(.system(size: 13, weight: .semibold))
                    if let tip = target.tips.first {
                        Text("· \(tip)")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.muted)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.white))
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("写完啦！")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func handleGuidedStrokeEnd(_ stroke: UserStroke) {
        guard guidedCompletedCount < current.strokes.count else { return }
        let target = current.strokes[guidedCompletedCount]
        let result = StrokeMatcher.match(user: stroke, target: target, config: .adult)
        switch result {
        case .matched:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                guidedCompletedCount += 1
                guidedHint = nil
            }
            if guidedCompletedCount >= current.strokes.count {
                // 整字完成：用 ScoringEngine 给一次详细评分
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    submit()
                }
            }
        case .failed(let reason):
            withAnimation { guidedHint = reason.kidTip }
            guidedShakeToken += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !strokes.isEmpty { strokes.removeLast() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { guidedHint = nil }
            }
        }
    }

    // ─── 模式选择 ────────────────────────────────────────────────
    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(PracticeMode.allCases) { m in
                Button {
                    mode = m
                    strokes.removeAll()
                    lastScore = nil
                    guidedCompletedCount = 0
                    guidedHint = nil
                } label: {
                    Text(m.label)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .tracking(4)
                        .foregroundColor(mode == m ? .white : Theme.ink)
                        .frame(minWidth: 54)
                        .padding(.vertical, 6)
                        .background(mode == m ? Theme.ink : Color.white.opacity(0.7))
                        .overlay(Capsule().stroke(Theme.line, lineWidth: mode == m ? 0 : 1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─── 提示 & 按钮 ─────────────────────────────────────────────
    private var hint: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill").foregroundColor(Theme.gold)
            Text(mode.hint + " · " + (current.strokes.first?.tips.first ?? ""))
                .font(.system(size: 12))
                .foregroundColor(Theme.ink.opacity(0.7))
                .lineLimit(2)
        }
        .padding(8)
        .background(Theme.highlight.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var controlButtons: some View {
        HStack(spacing: 8) {
            Button("清除") { strokes.removeAll() }
                .buttonStyle(GhostButtonStyle())
                .disabled(strokes.isEmpty)

            Button("撤销") {
                if !strokes.isEmpty { strokes.removeLast() }
            }
            .buttonStyle(GhostButtonStyle())
            .disabled(strokes.isEmpty)

            Button(action: submit) {
                Text("交作业")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(strokes.isEmpty || mode == .watch)
        }
    }

    // ─── 评分 ────────────────────────────────────────────────────
    private func submit() {
        guard let result = ScoringEngine.score(user: strokes, character: current) else { return }
        let seconds = Int(Date().timeIntervalSince(sessionStart))
        app.recordAttempt(charID: current.id, score: result.total, durationSeconds: seconds)
        withAnimation {
            lastScore = result
        }
        if result.total >= 85 {
            // 延迟一下让用户看到分数再庆祝
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation { isShowingCelebration = true }
            }
        }
    }

    private func goNext() {
        let next = allCurriculum.indices.contains(currentIndex + 1)
            ? allCurriculum[currentIndex + 1]
            : nil
        if let next = next {
            startCharID = next.id
            strokes.removeAll()
            lastScore = nil
            guidedCompletedCount = 0
            guidedHint = nil
            mode = .guided         // 下一字也默认进入"跟"模式
            sessionStart = Date()
        } else {
            dismiss()
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 通关庆祝层
// ─────────────────────────────────────────────────────────────────

struct CelebrationView: View {
    let character: CharacterDef
    let onContinue: () -> Void
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("🎊")
                    .font(.system(size: 60))
                Text("通关")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .tracking(6)
                    .foregroundColor(.white)
                Text("「\(character.title)」已掌握")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                Button("继续下一笔 →", action: onContinue)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 10)
            }
            .padding(40)
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
        }
    }
}
