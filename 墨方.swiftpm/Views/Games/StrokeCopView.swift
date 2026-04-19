import SwiftUI

/// 笔顺警察 · 5 题判断对错
/// MVP 实现：用 L1 八画组合成多笔组合，随机打乱顺序制造"错题"，让用户判断
struct StrokeCopView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Question] = []
    @State private var qIndex = 0
    @State private var userAnswer: Bool? = nil
    @State private var totalScore = 0
    @State private var animProgress: Double = 0
    @State private var isOver = false

    struct Question {
        let char: String
        let strokes: [StrokeSpec]
        /// nil = 笔顺正确；整数 = 实际播放时调换的笔画索引
        let scrambledAt: Int?
        /// 实际展示的笔画顺序
        let playOrder: [Int]
    }

    var body: some View {
        ZStack {
            PaperBackground()
            if isOver {
                resultView
            } else {
                VStack(spacing: 14) {
                    topBar
                    questionCard
                    choicesView
                    Spacer()
                }
                .padding(20)
            }
        }
        .onAppear(perform: buildQuestions)
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("退出", systemImage: "xmark")
            }
            .buttonStyle(GhostButtonStyle())
            Spacer()
            Text("🕵 笔顺警察")
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

    // ─── 题目卡：播放笔顺动画 ──────────────────────────────────────
    private var questionCard: some View {
        VStack(spacing: 10) {
            Text("观察笔顺，判断对错")
                .font(.system(size: 12))
                .tracking(2)
                .foregroundColor(Theme.muted)

            ZStack {
                Color.white
                RiceGrid()
                if let q = currentQuestion {
                    AnimatedStrokeOrder(
                        strokes: q.playOrder.compactMap { q.strokes.indices.contains($0) ? q.strokes[$0] : nil },
                        progress: animProgress
                    )
                    Text(q.char)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Theme.muted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                }
            }
            .frame(maxWidth: 360, maxHeight: 360)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))

            Button {
                replay()
            } label: {
                Label("重播", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    // ─── 选项 ────────────────────────────────────────────────────
    private var choicesView: some View {
        HStack(spacing: 12) {
            choiceButton(answer: true, label: "✓  笔顺正确",
                         color: userAnswer == nil ? Theme.ink : (isCorrect(true) ? .green : Theme.accent))
            choiceButton(answer: false, label: "✗  笔顺有错",
                         color: userAnswer == nil ? Theme.ink : (isCorrect(false) ? .green : Theme.accent))
        }
    }

    private func choiceButton(answer: Bool, label: String, color: Color) -> some View {
        Button {
            guard userAnswer == nil else { return }
            answerQuestion(answer)
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .tracking(3)
                .foregroundColor(userAnswer == nil ? Theme.ink : .white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(userAnswer == nil ? Color.white : color)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(userAnswer != nil)
    }

    private func isCorrect(_ choice: Bool) -> Bool {
        guard let q = currentQuestion else { return false }
        let actuallyCorrect = q.scrambledAt == nil
        return choice == actuallyCorrect
    }

    private var currentQuestion: Question? {
        questions.indices.contains(qIndex) ? questions[qIndex] : nil
    }

    // ─── 逻辑 ────────────────────────────────────────────────────
    private func buildQuestions() {
        // 用 2-3 笔的组合制造题目（把已有八画重新拼装成一个"字"）
        let charPool: [(String, [StrokeSpec])] = [
            ("十", [StandardStrokes.横, StandardStrokes.竖]),
            ("人", [StandardStrokes.撇, StandardStrokes.捺]),
            ("八", [StandardStrokes.撇, StandardStrokes.捺]),
            ("上", [StandardStrokes.竖, StandardStrokes.横, StandardStrokes.横]),
            ("下", [StandardStrokes.横, StandardStrokes.竖, StandardStrokes.点]),
            ("大", [StandardStrokes.横, StandardStrokes.撇, StandardStrokes.捺])
        ]
        var out: [Question] = []
        for (char, strokes) in charPool.shuffled().prefix(5) {
            let isScrambled = Bool.random()
            if isScrambled && strokes.count >= 2 {
                var order = Array(0..<strokes.count)
                let i = Int.random(in: 0..<strokes.count - 1)
                order.swapAt(i, i + 1)
                out.append(Question(char: char, strokes: strokes, scrambledAt: i, playOrder: order))
            } else {
                out.append(Question(char: char, strokes: strokes, scrambledAt: nil,
                                    playOrder: Array(0..<strokes.count)))
            }
        }
        questions = out
        replay()
    }

    private func replay() {
        animProgress = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 2.4)) { animProgress = 1.0 }
        }
    }

    private func answerQuestion(_ answer: Bool) {
        userAnswer = answer
        if isCorrect(answer) { totalScore += 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            nextQuestion()
        }
    }

    private func nextQuestion() {
        userAnswer = nil
        if qIndex + 1 >= questions.count {
            isOver = true
        } else {
            qIndex += 1
            replay()
        }
    }

    // ─── 结算 ────────────────────────────────────────────────────
    private var resultView: some View {
        VStack(spacing: 16) {
            Text("🎯").font(.system(size: 60))
            Text("本 局 结 束").font(.system(size: 14)).tracking(4).foregroundColor(Theme.muted)
            Text("\(totalScore)")
                .font(.system(size: 88, weight: .black, design: .serif))
                .foregroundColor(Theme.accent)
            Text("满分 \(questions.count * 10) · 你答对了 \(totalScore / 10) 题")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)

            HStack(spacing: 10) {
                Button("再来一局") {
                    qIndex = 0
                    totalScore = 0
                    isOver = false
                    buildQuestions()
                }
                .buttonStyle(PrimaryButtonStyle())
                Button("返回首页") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 20)
        }
        .padding(30)
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 按播放顺序逐笔动画
// ─────────────────────────────────────────────────────────────────

private struct AnimatedStrokeOrder: View {
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
                    p.move(to: pts[i - 1]); p.addLine(to: pts[i])
                    ctx.stroke(
                        p,
                        with: .color(Theme.ink),
                        style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
    }
}
