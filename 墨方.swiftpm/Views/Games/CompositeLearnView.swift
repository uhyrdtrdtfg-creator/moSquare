import SwiftUI

// ─────────────────────────────────────────────────────────────
// 组字学习 · 从已学过的字拼出新字
// ─────────────────────────────────────────────────────────────

/// 幼儿拼音 / 含义数据（局部定义，只给本文件使用）
struct CompositeMeta {
    let pinyin: String
    let meaning: String
}

let compositeMetadata: [String: CompositeMeta] = [
    "明": .init(pinyin: "míng", meaning: "明亮"),
    "林": .init(pinyin: "lín",  meaning: "树林"),
    "好": .init(pinyin: "hǎo",  meaning: "真好"),
    "休": .init(pinyin: "xiū",  meaning: "休息"),
    "江": .init(pinyin: "jiāng", meaning: "大江"),
    "安": .init(pinyin: "ān",   meaning: "平安"),
    "花": .init(pinyin: "huā",  meaning: "花朵"),
    "记": .init(pinyin: "jì",   meaning: "记住")
]

// Wrapper so Composite can be used with .fullScreenCover(item:)
private struct LessonItem: Identifiable {
    let id = UUID()
    let composite: Composite
}

// MARK: - 组字学习列表页（网格）
struct CompositeLearnView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var presented: LessonItem? = nil

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerText
                        cardGrid
                        Spacer(minLength: 30)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.muted)
                        .padding(20)
                }
            }
        }
        .fullScreenCover(item: $presented) { item in
            CompositeLesson(composite: item.composite)
                .environmentObject(app)
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🧩 组字学习")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(Theme.ink)
            Text("把学过的字拼起来，变出新字!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Theme.muted)
        }
    }

    private var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(CompositePool.all.enumerated()), id: \.offset) { _, composite in
                Button {
                    presented = LessonItem(composite: composite)
                } label: {
                    compositeCard(composite)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func compositeCard(_ composite: Composite) -> some View {
        let learned = app.compositesLearned.contains(composite.glyph)
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Text(composite.glyph)
                    .font(.system(size: 64, weight: .black, design: .serif))
                    .foregroundColor(Theme.ink)
                if composite.parts.count >= 2 {
                    HStack(spacing: 4) {
                        Text(composite.parts[0].glyph)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Theme.muted)
                        Text("+").font(.system(size: 14, weight: .bold)).foregroundColor(Theme.accent)
                        Text(composite.parts[1].glyph)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Theme.muted)
                    }
                }
                if let m = compositeMetadata[composite.glyph] {
                    Text(m.pinyin)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.accent)
                    Text(m.meaning).font(.system(size: 11)).foregroundColor(Theme.muted)
                }
                Spacer(minLength: 4)
                Text(learned ? "已学会" : "点我学")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(learned ? .white : Theme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(learned ? Theme.accent2 : Theme.highlight))
            }
            if learned {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 10, weight: .bold))
                    Text("已学会").font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Theme.accent2))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
    }
}

// MARK: - 单字课（拼字动画）
struct CompositeLesson: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let composite: Composite

    @State private var step: Int = 0   // 0=展示部件, 1=合体动画中, 2=展示完整字
    @State private var combineProgress: Double = 0
    @State private var revealScale: CGFloat = 0.3
    @State private var revealOpacity: Double = 0
    @State private var showSticker: Bool = false
    @State private var partsBounce: Bool = false

    private var part1: String { composite.parts.first?.glyph ?? "" }
    private var part2: String { composite.parts.count > 1 ? composite.parts[1].glyph : "" }

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: 20) {
                topBar
                Spacer()
                lessonStage
                Spacer()
                buttonRow
            }
            .padding(20)

            if showSticker {
                stickerOverlay
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .onAppear { runShowParts() }
    }

    // MARK: Top bar
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.muted)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white))
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
            }
            Spacer()
            Text("组字课 · \(composite.glyph)")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(Theme.ink)
            Spacer()
            // Balance spacer
            Color.clear.frame(width: 80, height: 1)
        }
    }

    // MARK: Lesson stage
    @ViewBuilder
    private var lessonStage: some View {
        if step == 2 {
            revealView
        } else {
            partsRow
        }
    }

    private var partsRow: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let midY = geo.size.height / 2
            let leftX  = w * 0.20
            let rightX = w * 0.80
            let centerX = w * 0.50
            // Slide both parts toward the center as combineProgress -> 1
            let p1X = leftX  + (centerX - leftX)  * CGFloat(combineProgress)
            let p2X = rightX + (centerX - rightX) * CGFloat(combineProgress)

            ZStack {
                // Part 1
                Text(part1)
                    .font(.system(size: 90, weight: .black, design: .serif))
                    .foregroundColor(Theme.ink)
                    .scaleEffect(partsBounce ? 1.0 : 0.7)
                    .opacity(1.0 - combineProgress * 0.2)
                    .position(x: p1X, y: midY)

                // Plus sign
                Text("+")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(Theme.accent)
                    .opacity(1.0 - combineProgress)
                    .position(x: w * 0.35, y: midY)

                // Part 2
                Text(part2)
                    .font(.system(size: 90, weight: .black, design: .serif))
                    .foregroundColor(Theme.ink)
                    .scaleEffect(partsBounce ? 1.0 : 0.7)
                    .opacity(1.0 - combineProgress * 0.2)
                    .position(x: p2X, y: midY)

                // Equals
                Text("=")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(Theme.accent2)
                    .opacity(1.0 - combineProgress * 0.6)
                    .position(x: w * 0.65, y: midY)

                // Result slot (? or composite appearing)
                Group {
                    if combineProgress < 0.5 {
                        Text("?")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(Theme.muted.opacity(0.5))
                    } else {
                        Text(composite.glyph)
                            .font(.system(size: 90, weight: .black, design: .serif))
                            .foregroundColor(Theme.ink)
                            .scaleEffect(0.4 + CGFloat(combineProgress) * 0.8)
                            .opacity(combineProgress)
                    }
                }
                .position(x: w * 0.85, y: midY)
            }
        }
        .frame(height: 260)
    }

    private var revealView: some View {
        VStack(spacing: 12) {
            Text(composite.glyph)
                .font(.system(size: 160, weight: .black, design: .serif))
                .foregroundColor(Theme.ink)
                .scaleEffect(revealScale)
                .opacity(revealOpacity)
            if let m = compositeMetadata[composite.glyph] {
                Text(m.pinyin)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.accent)
                Text(m.meaning)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.muted)
            }
            Text("= \(part1) + \(part2)")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(Theme.muted)
                .padding(.top, 6)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                revealScale = 1.0
                revealOpacity = 1.0
            }
        }
    }

    // MARK: Button row
    @ViewBuilder
    private var buttonRow: some View {
        HStack(spacing: 14) {
            if step < 2 {
                Button {
                    runCombine()
                } label: {
                    HStack(spacing: 8) {
                        Text("合 体!").tracking(6)
                        Image(systemName: "sparkles")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(step == 1)
            } else {
                Button {
                    runReplay()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("再看一次")
                    }
                }
                .buttonStyle(GhostButtonStyle())

                Button {
                    runLearned()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("我学会了")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: Sticker overlay
    private var stickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("🎁").font(.system(size: 80))
                Text("学会啦!")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white)
                Text("\(composite.glyph)")
                    .font(.system(size: 60, weight: .black, design: .serif))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
        }
    }

    // MARK: - Actions

    private func runShowParts() {
        step = 0
        combineProgress = 0
        partsBounce = false
        revealScale = 0.3
        revealOpacity = 0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
            partsBounce = true
        }
        Speaker.shared.speak("\(part1) 加 \(part2)")
    }

    private func runCombine() {
        step = 1
        Sound.success.play()
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
            combineProgress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            step = 2
            // 只念汉字，zh-CN TTS 自会发出拼音；不要把拉丁字母拼音传给合成器
            Speaker.shared.speak("等于 \(composite.glyph)")
        }
    }

    private func runReplay() {
        withAnimation(.easeInOut(duration: 0.25)) {
            step = 0
            combineProgress = 0
            revealScale = 0.3
            revealOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            runShowParts()
        }
    }

    private func runLearned() {
        app.recordComposite(composite.glyph)
        Sound.sticker.play()
        withAnimation(.easeInOut(duration: 0.3)) {
            showSticker = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            dismiss()
        }
    }
}
