import SwiftUI

// ─────────────────────────────────────────────────────────────────
// MARK: - 幼儿练字会话页（整合版）
// ─────────────────────────────────────────────────────────────────
//
// 四幕式体验：
//   phase = .preview   → 先看后写 · 大屏慢动作演示 + 朗读拼音
//   phase = .practice  → 逐笔描摹 · 失败 2 次自动演示
//   phase = .reward    → 整字完成 · 贴纸飞入 + 庆祝
//
// 设计要点：
//   - 大字大格（画布 aspect 1:1，顶满可视区）
//   - 逐笔描摹：写完一笔才出现下一笔
//   - 宽容匹配：起终点 28%、方向 cos ≥ 0.4
//   - 错了不惩罚：温和话术 + 自动擦除 + 无限重试
//   - 失败 ≥ 2 次：自动演示正确写法（Auto-Demo）
//   - 完成奖励：解锁贴纸 + 音效 + 新鲜的鼓励话
//   - 语音朗读：进入字时说拼音，完成时说祝贺
//   - 永不数字分数，只有 emoji 和贴纸

struct KidPracticeSessionView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State var startCharID: String

    // ─── 会话状态 ───────────────────────────────────────────────
    enum Phase { case preview, practice, reward }
    @State private var phase: Phase = .preview

    // 练习状态
    @State private var userStrokes: [UserStroke] = []
    @State private var completedCount: Int = 0
    @State private var failStreak: Int = 0            // 当前笔画连续失败次数
    @State private var successStreak: Int = 0         // 整体连续成功笔画
    @State private var hintMessage: String? = nil
    @State private var shakeToken: Int = 0
    @State private var flashText: String? = nil       // 屏幕中央闪烁的鼓励文字
    @State private var sessionStart = Date()

    // 预览动画
    @State private var previewProgress: Double = 0

    // 自动演示
    @State private var isAutoDemo: Bool = false
    @State private var autoDemoProgress: Double = 0

    // 贴纸飞入动画
    @State private var stickerFly: Bool = false

    /// 幼儿完整课程 = 老字库（有 tips/emoji）+ HanziPool（1800+ 字）
    private var allKidChars: [CharacterDef] {
        let base = KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all
        let baseGlyphs = Set(base.map(\.glyph))
        // HanziPool 里凡是老字库没有的，动态合成 CharacterDef
        let extra = HanziPool.all.compactMap { h -> CharacterDef? in
            baseGlyphs.contains(h.glyph) ? nil : h.asCharacterDef
        }
        return base + extra
    }

    private var current: CharacterDef {
        let glyph = startCharID.replacingOccurrences(of: "kid:", with: "")
        // ⚠ 数据源优先级：HanziPool（真实 SVG，笔数与渲染一致）> 老 curated 字库
        // 防止 Pack3 agent 生成的简化版（如 黄 7笔）和 HanziPool（黄 11笔）不一致导致错位
        if let hanzi = HanziPool.find(glyph) {
            return hanzi.asCharacterDef
        }
        if let found = allKidChars.first(where: { $0.id == startCharID }) {
            return found
        }
        return allKidChars[0]
    }

    private var currentIndex: Int {
        allKidChars.firstIndex { $0.id == startCharID } ?? 0
    }

    private var meta: KidsCharacters.Meta? {
        KidsCharacters.metaFor(current.id)
    }

    private var totalStrokes: Int { current.strokes.count }

    private var currentTargetTip: String? {
        guard completedCount < totalStrokes else { return nil }
        return current.strokes[completedCount].tips.first
    }

    var body: some View {
        ZStack {
            kidBackground

            switch phase {
            case .preview:  previewView
            case .practice: practiceView
            case .reward:   rewardView
            }

            if let text = flashText {
                Text(text)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Theme.accent, radius: 10)
                    .scaleEffect(1.2)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .onAppear { enterPreview() }
        .onDisappear { Speaker.shared.stop() }
    }

    // ─── 背景 ────────────────────────────────────────────────────
    private var kidBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.95, blue: 0.85),
                Color(red: 1.00, green: 0.98, blue: 0.92),
                Color(red: 0.98, green: 0.93, blue: 0.80)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Phase 1 - 预览页（先看后写）
    // ─────────────────────────────────────────────────────────────
    private var previewView: some View {
        VStack(spacing: 18) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 26))
                        Text("返回")
                    }
                    .foregroundColor(Theme.accent)
                }
                .buttonStyle(.plain)
                Spacer()
                Text("\(currentIndex + 1)/\(allKidChars.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.white))
                    .overlay(Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 1.5))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer(minLength: 6)

            Text("先 看 一 看 ~")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .tracking(4)
                .foregroundColor(Theme.muted)

            // 大字 + 拼音 + 含义
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 18) {
                    Text(meta?.emoji ?? "✨")
                        .font(.system(size: 64))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(current.glyph)
                            .font(.system(size: 64, weight: .black, design: .serif))
                            .foregroundColor(Theme.ink)
                        HStack(spacing: 8) {
                            Text(meta?.pinyin ?? "")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.accent)
                            Button {
                                speakCurrent()
                            } label: {
                                Image(systemName: "speaker.wave.2.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Theme.accent)
                            }
                            .buttonStyle(.plain)
                        }
                        if let m = meta?.meaning, !m.isEmpty {
                            Text(m)
                                .font(.system(size: 15))
                                .foregroundColor(Theme.muted)
                        }
                    }
                }
            }

            // 演示动画画布 · 优先用 SVG 真实字形，其次回落到系统字体
            ZStack {
                Color.white
                RiceGrid(
                    color: Theme.accent.opacity(0.55),
                    dashColor: Theme.accent.opacity(0.30)
                )
                if let hanzi = HanziPool.find(current.glyph) {
                    // 真实 SVG 笔画数据（102 字已覆盖）
                    HanziStrokeView(hanzi: hanzi, progress: previewProgress, fill: Theme.ink)
                        .padding(20)
                } else {
                    // 回落：用 iOS 系统字体做字形基底（永远正确）
                    Text(current.glyph)
                        .font(.system(size: 220, weight: .bold, design: .serif))
                        .foregroundColor(Theme.ink)
                        .scaleEffect(0.3 + previewProgress * 0.7)
                        .opacity(previewProgress)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 360, maxHeight: 360)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.accent.opacity(0.4), lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

            Spacer(minLength: 6)

            // "我来试试" 大按钮
            Button {
                phase = .practice
                sessionStart = Date()
            } label: {
                HStack(spacing: 10) {
                    Text("我 来 试 试")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .tracking(6)
                    Image(systemName: "hand.point.up.left.fill")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40).padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.35, blue: 0.25),
                                 Color(red: 0.95, green: 0.55, blue: 0.30)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            Button("再看一遍") {
                playPreviewAnimation()
                speakCurrent()
            }
            .font(.system(size: 13))
            .foregroundColor(Theme.muted)

            Spacer(minLength: 10)
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Phase 2 - 练习页
    // ─────────────────────────────────────────────────────────────
    private var practiceView: some View {
        VStack(spacing: 14) {
            topBar
            charMiniHeader
            canvasArea
            bottomTip
            Spacer(minLength: 10)
        }
        .padding(20)
    }

    private var topBar: some View {
        HStack {
            Button {
                phase = .preview
                resetPracticeState()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 26))
                    Text("再看看")
                }
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            // 笔画进度点
            HStack(spacing: 6) {
                ForEach(0..<totalStrokes, id: \.self) { i in
                    Circle()
                        .fill(i < completedCount
                              ? Theme.accent
                              : (i == completedCount ? Color.orange : Color.white))
                        .overlay(Circle().stroke(Theme.accent.opacity(0.5), lineWidth: 1.5))
                        .frame(width: 14, height: 14)
                }
            }

            Spacer()

            Text("\(currentIndex + 1)/\(allKidChars.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(Color.white))
                .overlay(Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 1.5))
        }
    }

    private var charMiniHeader: some View {
        HStack(spacing: 12) {
            Text(current.glyph)
                .font(.system(size: 36, weight: .black, design: .serif))
                .foregroundColor(Theme.ink)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(meta?.emoji ?? "")
                        .font(.system(size: 18))
                    Text(meta?.pinyin ?? "")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.accent)
                    Button {
                        speakCurrent()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.accent.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                let sub: String = {
                    if let m = meta?.meaning, !m.isEmpty { return m }
                    return current.subtitle
                }()
                if !sub.isEmpty {
                    Text(sub)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                }
            }
            Spacer()
        }
    }

    private var canvasArea: some View {
        ZStack {
            PracticeCanvas(
                character: current,
                mode: .guided,
                strokes: $userStrokes,
                onStrokeEnd: { stroke in
                    handleStrokeEnd(stroke)
                },
                guidedCompletedCount: completedCount,
                guidedShowStandardInk: true,
                isKidMode: true
            )
            .modifier(ShakeEffect(shakes: shakeToken))

            // 自动演示遮罩 · 优先用真实 SVG（hanzi-writer-data）
            if isAutoDemo, completedCount < totalStrokes {
                ZStack {
                    Color.white.opacity(0.55)

                    if let hanzi = HanziPool.find(current.glyph),
                       completedCount < hanzi.strokes.count {
                        // 真实 SVG 演示当前笔 · 带轻微缩放动画吸引注意
                        HanziStrokeView(
                            hanzi: HanziChar(
                                id: hanzi.id + ".demo",
                                glyph: hanzi.glyph,
                                pinyin: hanzi.pinyin,
                                meaning: hanzi.meaning,
                                strokes: [hanzi.strokes[completedCount]],
                                medians: nil
                            ),
                            progress: 1.0,
                            fill: Theme.accent
                        )
                        .padding(14)
                        .scaleEffect(0.9 + autoDemoProgress * 0.1)
                        .opacity(0.3 + autoDemoProgress * 0.7)
                    } else {
                        // 回落：用老数据（当 HanziPool 无此字）
                        Canvas { ctx, size in
                            let target = current.strokes[completedCount]
                            let pts = StrokePath.sample(target.points, count: 60).map {
                                CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                            }
                            let cut = Int(Double(pts.count) * autoDemoProgress)
                            for i in 1..<max(1, cut) {
                                let t = CGFloat(i) / CGFloat(pts.count - 1)
                                let minDim = min(size.width, size.height)
                                let w = (target.widthStart + (target.widthEnd - target.widthStart) * t) * minDim
                                var p = Path()
                                p.move(to: pts[i - 1])
                                p.addLine(to: pts[i])
                                ctx.stroke(p,
                                           with: .color(Theme.accent),
                                           style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
                            }
                        }
                    }

                    VStack {
                        Spacer()
                        Text("像 这 样 ~")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .tracking(4)
                            .foregroundColor(Theme.accent)
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Capsule().fill(Color.white))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                            .padding(.bottom, 16)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomTip: some View {
        VStack(spacing: 10) {
            if let hint = hintMessage {
                HStack(spacing: 8) {
                    Text("🤔")
                    Text(hint)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.orange.gradient)
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            } else if completedCount < totalStrokes {
                // HanziPool 的字没有 tips，就只显示进度"第 N 笔"
                let tip = currentTargetTip
                HStack(spacing: 8) {
                    Text("👉")
                    if let tip = tip {
                        Text("第 \(completedCount + 1) 笔 · \(tip)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.ink)
                    } else {
                        Text("第 \(completedCount + 1) 笔 / 共 \(totalStrokes) 笔")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.ink)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 2))
            }

            Button {
                userStrokes.removeAll()
                completedCount = 0
                hintMessage = nil
                failStreak = 0
            } label: {
                Label("重来", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.muted)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.7)))
                    .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Phase 3 - 奖励页（整字完成）
    // ─────────────────────────────────────────────────────────────
    private var rewardView: some View {
        let passes = app.passCount(for: current.id)
        let mastered = app.isMastered(current.id)
        return ZStack {
            kidBackground
            VStack(spacing: 18) {
                Spacer()

                Text(mastered
                     ? Encouragements.randomPerCharacter()
                     : "🌱 写得真棒! 再练一遍就掌握啦~")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Theme.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // 进度圆点（N/2 合格次数）
                HStack(spacing: 10) {
                    ForEach(0..<AppState.masterThreshold, id: \.self) { i in
                        ZStack {
                            Circle()
                                .fill(i < passes ? Theme.accent : Color.white)
                                .overlay(Circle().stroke(Theme.accent, lineWidth: 2))
                                .frame(width: 28, height: 28)
                            if i < passes {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)

                // 只在"掌握"时才展示大贴纸；第一遍只是鼓励
                if mastered {
                    Text(meta?.sticker ?? "⭐")
                        .font(.system(size: 120))
                        .scaleEffect(stickerFly ? 1.0 : 0.1)
                        .rotationEffect(stickerFly ? .degrees(0) : .degrees(-30))
                        .opacity(stickerFly ? 1 : 0)
                        .shadow(color: Theme.accent.opacity(0.4), radius: 30)
                } else {
                    // 第一遍完成：显示当前字本身作为成就
                    Text(current.glyph)
                        .font(.system(size: 100, weight: .black, design: .serif))
                        .foregroundColor(Theme.ink)
                        .scaleEffect(stickerFly ? 1.0 : 0.3)
                        .opacity(stickerFly ? 1 : 0)
                }

                VStack(spacing: 4) {
                    Text(mastered ? "恭喜你掌握了" : "写完一遍啦 (\(passes)/\(AppState.masterThreshold))")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.muted)
                    HStack(spacing: 8) {
                        Text(current.glyph)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(Theme.ink)
                        Text(meta?.pinyin ?? "")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.accent)
                        if let m = meta?.meaning, !m.isEmpty {
                            Text("·")
                                .foregroundColor(Theme.muted)
                            Text(m)
                                .font(.system(size: 16))
                                .foregroundColor(Theme.ink)
                        }
                    }
                    if let cheer = meta?.cheer {
                        Text(cheer)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Theme.accent2)
                            .padding(.top, 4)
                    }
                }

                Text("已收集 \(app.stickerCount) / \(allKidChars.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 12).padding(.vertical, 4)
                    .background(Capsule().fill(Theme.accent.opacity(0.12)))

                Spacer()

                let isLast = currentIndex + 1 >= allKidChars.count
                HStack(spacing: 12) {
                    // 第一遍：突出"再练一遍"；第二遍及以上：突出"下一字"
                    if !mastered {
                        // 未掌握时强调再练一遍（按钮变成主按钮样式）
                        Button {
                            enterPreview()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("再练一遍 (需 \(AppState.masterThreshold - passes) 遍)")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22).padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.35, blue: 0.25),
                                             Color(red: 0.95, green: 0.55, blue: 0.30)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }.buttonStyle(.plain)

                        Button {
                            goNext(isLast: isLast)
                        } label: {
                            Label("跳过", systemImage: "forward.fill")
                                .font(.system(size: 13))
                        }.buttonStyle(GhostButtonStyle())
                    } else {
                        // 已掌握：正常流程
                        Button {
                            enterPreview()
                        } label: {
                            Label("再写一次", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .semibold))
                        }.buttonStyle(GhostButtonStyle())

                        Button {
                            goNext(isLast: isLast)
                        } label: {
                            HStack(spacing: 6) {
                                Text(isLast ? "完 成" : "下 一 个")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .tracking(4)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24).padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.35, blue: 0.25),
                                             Color(red: 0.95, green: 0.55, blue: 0.30)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // 贴纸飞入动画
            stickerFly = false
            withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                stickerFly = true
            }
            Sound.sticker.play()
            // 朗读祝贺 + 字拼音
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // 只读汉字，zh-CN TTS 自会发出正确拼音；不要把拉丁字母拼音丢给合成器
                Speaker.shared.speak(current.glyph)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: 交互与状态
    // ─────────────────────────────────────────────────────────────

    private func enterPreview() {
        phase = .preview
        resetPracticeState()
        playPreviewAnimation()
        // 进入时先朗读字音
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            speakCurrent()
        }
    }

    private func playPreviewAnimation() {
        previewProgress = 0
        // 总时长：每笔 0.9s
        let totalSeconds: Double = 0.9 * Double(max(1, totalStrokes))
        withAnimation(.easeInOut(duration: totalSeconds)) {
            previewProgress = 1.0
        }
    }

    private func speakCurrent() {
        guard let m = meta else {
            Speaker.shared.speak(current.glyph)
            return
        }
        // 只念汉字 + 中文含义（m.meaning 是中文），跳过拼音字母
        // 只念单字 —— Speaker 会找 MP3 播放，晓晓神经网络音；
        // 不念 meaning 避免"大 大大的"这种重复感
        Speaker.shared.speak(current.glyph)
    }

    private func handleStrokeEnd(_ stroke: UserStroke) {
        guard completedCount < totalStrokes, !isAutoDemo else { return }
        let target = current.strokes[completedCount]
        let result = StrokeMatcher.match(
            user: stroke, target: target,
            config: failStreak >= 1 ? .kid : .kid // 保留扩展空间，目前都用 kid 宽容配置
        )

        switch result {
        case .matched:
            // 过关 ✨
            successStreak += 1
            failStreak = 0

            let msg = successStreak >= 3
                ? Encouragements.randomOnStreak()
                : Encouragements.randomPerStroke()
            flash(msg)
            Sound.success.play()

            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                completedCount += 1
                hintMessage = nil
            }
            if completedCount == totalStrokes {
                finishCharacter()
            }

        case .failed(let reason):
            failStreak += 1
            successStreak = 0
            Sound.fail.play()
            withAnimation(.easeInOut(duration: 0.2)) {
                hintMessage = reason.kidTip
            }
            shakeToken += 1
            // 擦除用户刚才那一笔
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !userStrokes.isEmpty { userStrokes.removeLast() }
            }
            // 失败 ≥ 2 次：触发自动演示
            if failStreak >= 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    runAutoDemo()
                }
            } else {
                // 2 秒后清理提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { hintMessage = nil }
                }
            }
        }
    }

    private func runAutoDemo() {
        guard completedCount < totalStrokes else { return }
        isAutoDemo = true
        autoDemoProgress = 0
        hintMessage = "看老师写一遍~"
        Speaker.shared.speak("看老师写一遍")
        withAnimation(.easeInOut(duration: 1.6)) {
            autoDemoProgress = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isAutoDemo = false
                hintMessage = nil
                failStreak = 0   // 演示后给一次"重新开始"的机会
            }
        }
    }

    private func flash(_ text: String) {
        flashText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation { flashText = nil }
        }
    }

    private func finishCharacter() {
        let seconds = Int(Date().timeIntervalSince(sessionStart))
        // 幼儿模式 · 完成即高分，同时触发贴纸解锁
        app.recordAttempt(charID: current.id, score: 90, durationSeconds: seconds)
        Sound.fanfare.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                phase = .reward
            }
        }
    }

    private func resetPracticeState() {
        userStrokes.removeAll()
        completedCount = 0
        failStreak = 0
        successStreak = 0
        hintMessage = nil
        isAutoDemo = false
        stickerFly = false
    }

    private func goNext(isLast: Bool) {
        if isLast {
            dismiss()
            return
        }
        let nextIdx = currentIndex + 1
        if allKidChars.indices.contains(nextIdx) {
            startCharID = allKidChars[nextIdx].id
            enterPreview()
        } else {
            dismiss()
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 预览页的笔顺演示动画层
// ─────────────────────────────────────────────────────────────────

private struct PreviewStrokeAnimator: View {
    let strokes: [StrokeSpec]
    let progress: Double

    var body: some View {
        Canvas { ctx, size in
            let totalPts = strokes.count * 60
            let cut = Int(Double(totalPts) * progress)
            var drawn = 0
            for spec in strokes {
                let pts = StrokePath.sample(spec.points, count: 60).map {
                    CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                }
                for i in 1..<pts.count {
                    drawn += 1
                    if drawn > cut { return }
                    let t = CGFloat(i) / CGFloat(pts.count - 1)
                    let minDim = min(size.width, size.height)
                    let w = (spec.widthStart + (spec.widthEnd - spec.widthStart) * t) * minDim
                    var p = Path()
                    p.move(to: pts[i - 1])
                    p.addLine(to: pts[i])
                    ctx.stroke(p,
                               with: .color(Theme.ink),
                               style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 抖动动画（其他页面也会用）
// ─────────────────────────────────────────────────────────────────

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let amount: CGFloat = 8
        let translation = amount * sin(CGFloat(shakes) * .pi * 5)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
