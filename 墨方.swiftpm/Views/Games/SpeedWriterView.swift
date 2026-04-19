import SwiftUI

/// 速写达人 · 60 秒挑战
/// MVP 版评分规则：根据用户画出的笔画数量、覆盖度、稳定度给出 0-3 分
struct SpeedWriterView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var timeLeft: Int = 60
    @State private var score: Int = 0
    @State private var combo: Int = 0
    @State private var bestCombo: Int = 0
    @State private var currentIndex: Int = 0
    @State private var strokes: [UserStroke] = []
    @State private var timer: Timer?
    @State private var isOver = false
    @State private var recent: [(char: String, score: Int)] = []

    private var targets: [String] { StandardStrokes.speedChars }
    private var currentChar: String { targets[currentIndex % targets.count] }

    var body: some View {
        ZStack {
            PaperBackground()

            if isOver {
                resultView
            } else {
                VStack(spacing: 14) {
                    topBar
                    statusBar
                    targetView
                    canvasArea
                    controls
                    Spacer()
                }
                .padding(20)
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear { timer?.invalidate() }
    }

    // ─── 上：返回 + 标题 ──────────────────────────────────────────
    private var topBar: some View {
        HStack {
            Button {
                timer?.invalidate()
                dismiss()
            } label: {
                Label("退出", systemImage: "xmark")
            }
            .buttonStyle(GhostButtonStyle())
            Spacer()
            Text("🏆 速写达人")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .tracking(3)
            Spacer()
            Color.clear.frame(width: 60)
        }
    }

    // ─── 得分 / 时间 / 连击 ───────────────────────────────────────
    private var statusBar: some View {
        HStack {
            VStack {
                Text("得分").font(.system(size: 11)).tracking(2).foregroundColor(.white.opacity(0.7))
                Text("\(score)").font(.system(size: 22, weight: .bold, design: .serif)).foregroundColor(.white)
            }
            Spacer()
            VStack {
                Text("倒计时").font(.system(size: 11)).tracking(2).foregroundColor(.white.opacity(0.7))
                Text("\(timeLeft)\"").font(.system(size: 26, weight: .black, design: .serif))
                    .foregroundColor(timeLeft <= 10 ? .red : Theme.gold)
            }
            Spacer()
            VStack {
                Text("连击").font(.system(size: 11)).tracking(2).foregroundColor(.white.opacity(0.7))
                Text("×\(combo)").font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(combo >= 3 ? Theme.gold : .white)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        .background(Theme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // ─── 当前目标字 ───────────────────────────────────────────────
    private var targetView: some View {
        HStack(spacing: 20) {
            Text("当前")
                .font(.system(size: 14))
                .foregroundColor(Theme.muted)
            Text(currentChar)
                .font(.system(size: 70, weight: .bold, design: .serif))
                .foregroundColor(Theme.accent)
                .frame(width: 100, height: 100)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text("在右侧格子里写出这个字")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.ink.opacity(0.7))
                Text("评分规则：笔画越完整、居中越好，得分越高")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
        }
    }

    // ─── 画布 ────────────────────────────────────────────────────
    private var canvasArea: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                ZStack {
                    Color.white
                    RiceGrid()
                    InkCanvasView(strokes: $strokes, canvasSize: geo.size)
                }
                .frame(width: min(geo.size.height, 340), height: min(geo.size.height, 340))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
                Spacer()
            }
        }
        .frame(height: 340)
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button("清除") { strokes.removeAll() }
                .buttonStyle(GhostButtonStyle())
                .disabled(strokes.isEmpty)
            Spacer()
            Button("提交 · 下一字") { submit() }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(strokes.isEmpty)
        }
    }

    // ─── 提交评分 ────────────────────────────────────────────────
    private func submit() {
        let s = scoreQuickly(strokes: strokes)
        recent.append((char: currentChar, score: s.total))
        if s.total >= 95       { score += 3; combo += 1 }
        else if s.total >= 80  { score += 2; combo += 1 }
        else if s.total >= 60  { score += 1; combo = 0 }
        else                   { combo = 0 }
        if combo >= 3 { score += 1 }     // 连击 +1 额外
        bestCombo = max(bestCombo, combo)
        currentIndex += 1
        strokes.removeAll()
    }

    /// 简易评分：笔画数、占格比、稳定度
    private func scoreQuickly(strokes: [UserStroke]) -> (total: Int, strokes: Int) {
        guard !strokes.isEmpty else { return (0, 0) }
        let allPts = strokes.flatMap { $0.points }
        let xs = allPts.map(\.x), ys = allPts.map(\.y)
        let w = (xs.max() ?? 0) - (xs.min() ?? 0)
        let h = (ys.max() ?? 0) - (ys.min() ?? 0)
        let coverage = min(1.0, Double(max(w, h)) / 0.7)  // bbox 占格率

        let strokeBonus = min(1.0, Double(strokes.count) / 4.0)
        let base = 40 + Int(coverage * 30) + Int(strokeBonus * 30)
        return (min(100, base + Int.random(in: 0...8)), strokes.count)
    }

    // ─── 计时 ────────────────────────────────────────────────────
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeLeft > 0 { timeLeft -= 1 }
                if timeLeft == 0 { endGame() }
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        isOver = true
        if score > app.bestSpeedScore { app.bestSpeedScore = score }
    }

    // ─── 结算 ────────────────────────────────────────────────────
    private var resultView: some View {
        VStack(spacing: 16) {
            Text("🏆")
                .font(.system(size: 60))
            Text("本 局 结 束")
                .font(.system(size: 14))
                .tracking(4)
                .foregroundColor(Theme.muted)
            Text("\(score)")
                .font(.system(size: 88, weight: .black, design: .serif))
                .foregroundColor(Theme.accent)
            Text("得分 · 最高连击 ×\(bestCombo)")
                .font(.system(size: 14))
                .foregroundColor(Theme.muted)

            if score > app.bestSpeedScore || score == app.bestSpeedScore {
                Label("新纪录", systemImage: "star.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.gold)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Theme.gold.opacity(0.18))
                    .clipShape(Capsule())
            }

            // 战绩简表
            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("你写了 \(recent.count) 个字")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                    HStack(spacing: 4) {
                        ForEach(0..<min(10, recent.count), id: \.self) { i in
                            Text(recent[i].char)
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .frame(width: 32, height: 32)
                                .background(recent[i].score >= 80 ? Theme.accent.opacity(0.9) : Color.white)
                                .foregroundColor(recent[i].score >= 80 ? .white : Theme.ink)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.line, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .padding(.top, 12)
            }

            HStack(spacing: 10) {
                Button("再来一局") { restart() }
                    .buttonStyle(PrimaryButtonStyle(filled: true))
                Button("返回首页") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 20)
        }
        .padding(30)
    }

    private func restart() {
        timeLeft = 60
        score = 0
        combo = 0
        bestCombo = 0
        currentIndex = 0
        strokes.removeAll()
        recent.removeAll()
        isOver = false
        startTimer()
    }
}
