import SwiftUI

/// 部首拼图 · 用部件碎片拼出完整字
/// MVP 玩法（零基础友好）：
/// 1. 屏幕顶部显示目标字（半透明提示）
/// 2. 米字格里显示被划分的几个"槽位"（左/右 或 上/下）
/// 3. 底部展示 4 张部件卡片（2 张正确 + 2 张干扰）
/// 4. 用户点击卡片 → 如果位置正确则飞入对应槽位；错误则轻微抖动
/// 5. 填满所有槽位即过关，统计答对/失误数
struct RadicalPuzzleView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Composite] = []
    @State private var qIndex = 0
    @State private var placed: [Composite.Zone: String] = [:]   // zone -> part glyph
    @State private var mistakes = 0
    @State private var correct = 0
    @State private var shakingCard: String? = nil
    @State private var choiceCards: [String] = []
    @State private var usedCards: Set<String> = []
    @State private var isOver = false

    var body: some View {
        ZStack {
            PaperBackground()
            if isOver {
                resultView
            } else {
                VStack(spacing: 16) {
                    topBar
                    promptArea
                    puzzleBoard
                    cardRack
                    Spacer(minLength: 10)
                }
                .padding(20)
            }
        }
        .onAppear(perform: start)
    }

    private var current: Composite? {
        questions.indices.contains(qIndex) ? questions[qIndex] : nil
    }

    // ─── 顶栏 ────────────────────────────────────────────────────
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("退出", systemImage: "xmark")
            }
            .buttonStyle(GhostButtonStyle())
            Spacer()
            Text("🧩 部首拼图")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .tracking(3)
            Spacer()
            Text("\(min(qIndex + 1, questions.count))/\(questions.count)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.muted)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
        }
    }

    // ─── 提示区 ──────────────────────────────────────────────────
    private var promptArea: some View {
        VStack(spacing: 6) {
            Text(current?.description ?? "")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
            Text("把下面的部件放到正确位置，拼成目标字")
                .font(.system(size: 12))
                .foregroundColor(Theme.muted)
        }
    }

    // ─── 米字格 + 槽位 ───────────────────────────────────────────
    private var puzzleBoard: some View {
        ZStack {
            Color.white
            RiceGrid()
            // 半透明目标字
            if let c = current {
                Text(c.glyph)
                    .font(.system(size: 180, weight: .regular, design: .serif))
                    .foregroundColor(Theme.accent.opacity(0.08))
            }
            // 槽位
            if let c = current {
                GeometryReader { geo in
                    ForEach(c.parts.indices, id: \.self) { i in
                        let part = c.parts[i]
                        let rect = part.zone.rect
                        let x = rect.midX * geo.size.width
                        let y = rect.midY * geo.size.height
                        let w = rect.width * geo.size.width
                        let h = rect.height * geo.size.height

                        ZStack {
                            if placed[part.zone] == part.glyph {
                                // 已填入
                                Text(part.glyph)
                                    .font(.system(size: min(w, h) * 0.6,
                                                  weight: .bold, design: .serif))
                                    .foregroundColor(Theme.ink)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                // 空槽位
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                                    )
                                    .foregroundColor(Theme.accent.opacity(0.4))
                                    .frame(width: w * 0.82, height: h * 0.82)
                                Text(part.zone.label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.accent.opacity(0.6))
                            }
                        }
                        .frame(width: w, height: h)
                        .position(x: x, y: y)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 340)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
    }

    // ─── 底部部件卡片 ────────────────────────────────────────────
    private var cardRack: some View {
        HStack(spacing: 10) {
            ForEach(choiceCards, id: \.self) { card in
                let used = usedCards.contains(card)
                Button {
                    tapCard(card)
                } label: {
                    Text(card)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(used ? Theme.muted.opacity(0.3) : Theme.ink)
                        .frame(width: 64, height: 64)
                        .background(used ? Color.white.opacity(0.4) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(used ? Theme.line : Theme.accent.opacity(0.7),
                                        lineWidth: used ? 1 : 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(used ? 0 : 0.08), radius: 3, y: 2)
                        .rotationEffect(shakingCard == card ? .degrees(-3) : .zero)
                        .animation(
                            shakingCard == card
                                ? .default.repeatCount(3, autoreverses: true).speed(5)
                                : .default,
                            value: shakingCard
                        )
                }
                .disabled(used)
                .buttonStyle(.plain)
            }
        }
    }

    // ─── 交互 ────────────────────────────────────────────────────
    private func tapCard(_ card: String) {
        guard let c = current else { return }
        if let target = c.parts.first(where: { $0.glyph == card }) {
            // 正确 → 放入槽位
            if placed[target.zone] == nil {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    placed[target.zone] = card
                    usedCards.insert(card)
                }
                // 检查是否完成
                if placed.count == c.parts.count {
                    correct += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        nextQuestion()
                    }
                }
            }
        } else {
            // 干扰项 → 抖动提示
            mistakes += 1
            shakingCard = card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shakingCard = nil
            }
        }
    }

    // ─── 流程 ────────────────────────────────────────────────────
    private func start() {
        questions = Array(CompositePool.all.shuffled().prefix(5))
        qIndex = 0
        mistakes = 0
        correct = 0
        isOver = false
        prepareQuestion()
    }

    private func prepareQuestion() {
        placed = [:]
        usedCards = []
        guard let c = current else { return }
        let right = c.parts.map(\.glyph)
        let pool = CompositePool.distractors.filter { !right.contains($0) }.shuffled()
        let wrongs = Array(pool.prefix(max(2, 4 - right.count)))
        choiceCards = (right + wrongs).shuffled()
    }

    private func nextQuestion() {
        if qIndex + 1 >= questions.count {
            isOver = true
        } else {
            qIndex += 1
            prepareQuestion()
        }
    }

    // ─── 结算 ────────────────────────────────────────────────────
    private var resultView: some View {
        VStack(spacing: 16) {
            Text("🧩").font(.system(size: 60))
            Text("拼 图 完 成").font(.system(size: 14)).tracking(4).foregroundColor(Theme.muted)
            Text("\(correct) / \(questions.count)")
                .font(.system(size: 72, weight: .black, design: .serif))
                .foregroundColor(Theme.accent)
            Text("过关 · 失误 \(mistakes) 次")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)

            HStack(spacing: 10) {
                Button("再来一局", action: start)
                    .buttonStyle(PrimaryButtonStyle())
                Button("返回首页") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 20)
        }
        .padding(30)
    }
}
