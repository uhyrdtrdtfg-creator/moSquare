import SwiftUI

struct KidBubblePopGame: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    struct Bubble: Identifiable {
        let id: UUID = UUID()
        var glyph: String
        var position: CGPoint
        var velocity: CGVector
        var color: Color
        var popping: Bool = false
    }

    @State private var bubbles: [Bubble] = []
    @State private var target: String = "月"
    @State private var correctPops: Int = 0
    @State private var timeLeft: Double = 30.0
    @State private var shakeToken: Int = 0
    @State private var isGameOver: Bool = false
    @State private var playSize: CGSize = .zero
    @State private var timer: Timer? = nil
    @State private var finalScore: Int = 0
    @State private var previousBest: Int = 0
    @State private var popEffectAt: CGPoint? = nil

    private let bubbleDiameter: CGFloat = 70

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.paper, Color(red: 1.0, green: 0.96, blue: 0.88)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if isGameOver {
                resultView
            } else {
                gameView
            }
        }
        .navigationBarHidden(true)
        .onAppear { startGame() }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 14) {
            topBar
            targetCard
            playArea
            tipsBar
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private var topBar: some View {
        HStack {
            Button {
                timer?.invalidate()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.muted)
            }

            Spacer()

            Text("⏱ 30 秒挑战")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.ink)

            Spacer()

            Text(String(format: "%.1fs", max(0, timeLeft)))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(
                    Capsule().fill(timeLeft <= 5 ? Color.red : Theme.accent)
                )
        }
    }

    private var targetCard: some View {
        HStack(spacing: 16) {
            Text("找:")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Theme.muted)
            Text(target)
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundColor(Theme.ink)
                .id("target-\(target)")
                .transition(.scale.combined(with: .opacity))

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("已爆")
                    .font(.system(size: 14)).foregroundColor(Theme.muted)
                Text("\(correctPops)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.gold)
            }
        }
        .padding(.horizontal, 22).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
    }

    private var playArea: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Theme.line, lineWidth: 2)
                    )

                ForEach(bubbles) { b in
                    ZStack {
                        Circle().fill(b.color.opacity(0.85))
                            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                            .shadow(color: b.color.opacity(0.4), radius: 4, y: 2)
                        Text(b.glyph)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    }
                    .frame(width: bubbleDiameter, height: bubbleDiameter)
                    .position(b.position)
                    .scaleEffect(b.popping ? 1.6 : 1.0)
                    .opacity(b.popping ? 0 : 1)
                    .onTapGesture { tap(b) }
                }

                if let p = popEffectAt {
                    Text("✨")
                        .font(.system(size: 44))
                        .position(p)
                        .transition(.scale.combined(with: .opacity))
                        .id("burst-\(p.x)-\(p.y)")
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .modifier(ShakeEffect(shakes: shakeToken))
            .onAppear {
                playSize = geo.size
                if bubbles.isEmpty { seedBubbles() }
            }
            .onChange(of: geo.size) { _, newSize in
                playSize = newSize
            }
        }
        .aspectRatio(4.0/3.0, contentMode: .fit)
    }

    private var tipsBar: some View {
        Text("点中目标字泡 +1 · 点错 -0.8 秒")
            .font(.system(size: 14))
            .foregroundColor(Theme.muted)
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 22) {
            Text("⏰ 时间到!")
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(Theme.ink)

            Text(medalEmoji)
                .font(.system(size: 96))

            Text("\(finalScore)")
                .font(.system(size: 80, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.gold)

            Text("爆了 \(correctPops) 个字泡!")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Theme.ink)

            if finalScore > previousBest && previousBest > 0 {
                Text("🏆 新纪录!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.gold)
            } else if previousBest > 0 {
                Text("最高分: \(previousBest)")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.muted)
            }

            HStack(spacing: 16) {
                Button("再来一局") { startGame() }
                    .buttonStyle(PrimaryButtonStyle())
                Button("返回") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.top, 12)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 16, y: 6)
        )
        .padding(28)
    }

    private var medalEmoji: String {
        switch finalScore {
        case 90...: return "🥇"
        case 60..<90: return "🥈"
        case 30..<60: return "🥉"
        default: return "🎈"
        }
    }

    // MARK: - Game logic

    private func startGame() {
        timer?.invalidate()
        target = randomTargetChar()
        correctPops = 0
        timeLeft = 30.0
        isGameOver = false
        shakeToken = 0
        popEffectAt = nil
        if playSize.width > 0 && playSize.height > 0 {
            seedBubbles()
        } else {
            bubbles = []
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            tick()
        }
    }

    private func seedBubbles() {
        bubbles = (0..<7).map { _ in randomBubble() }
    }

    private func randomBubble() -> Bubble {
        let chars = KidsCharacters.all.shuffled()
        let glyph: String
        if Double.random(in: 0...1) < 0.35 {
            glyph = target
        } else {
            glyph = chars.first(where: { $0.glyph != target })?.glyph ?? "山"
        }
        let w = max(100, playSize.width)
        let h = max(100, playSize.height)
        let pos = CGPoint(
            x: CGFloat.random(in: 50...max(51, w - 50)),
            y: CGFloat.random(in: 50...max(51, h - 50))
        )
        let speed: CGFloat = 40
        let angle = Double.random(in: 0..<(2 * .pi))
        let vel = CGVector(
            dx: speed * CGFloat(cos(angle)),
            dy: speed * CGFloat(sin(angle))
        )
        let palette: [Color] = [
            Theme.accent, Theme.accent2, Theme.gold,
            Color(red: 0.26, green: 0.66, blue: 0.48),
            Color(red: 0.56, green: 0.40, blue: 0.74)
        ]
        return Bubble(
            glyph: glyph,
            position: pos,
            velocity: vel,
            color: palette.randomElement() ?? Theme.accent
        )
    }

    private func randomTargetChar() -> String {
        KidsCharacters.all.randomElement()?.glyph ?? "月"
    }

    private func tick() {
        guard !isGameOver else { return }
        timeLeft -= 0.05
        if timeLeft <= 0 {
            timeLeft = 0
            endGame()
            return
        }
        let dt: CGFloat = 0.05
        let r: CGFloat = bubbleDiameter / 2
        for i in bubbles.indices {
            if bubbles[i].popping { continue }
            var b = bubbles[i]
            b.position.x += b.velocity.dx * dt
            b.position.y += b.velocity.dy * dt
            if b.position.x < r {
                b.position.x = r
                b.velocity.dx = abs(b.velocity.dx)
            }
            if b.position.x > playSize.width - r {
                b.position.x = playSize.width - r
                b.velocity.dx = -abs(b.velocity.dx)
            }
            if b.position.y < r {
                b.position.y = r
                b.velocity.dy = abs(b.velocity.dy)
            }
            if b.position.y > playSize.height - r {
                b.position.y = playSize.height - r
                b.velocity.dy = -abs(b.velocity.dy)
            }
            bubbles[i] = b
        }
    }

    private func tap(_ bubble: Bubble) {
        guard let idx = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }
        if bubbles[idx].popping { return }
        if bubble.glyph == target {
            Sound.success.play()
            correctPops += 1
            popEffectAt = bubble.position
            withAnimation(.easeOut(duration: 0.2)) {
                bubbles[idx].popping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                bubbles.removeAll { $0.id == bubble.id }
                bubbles.append(randomBubble())
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    target = randomTargetChar()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                popEffectAt = nil
            }
        } else {
            Sound.fail.play()
            shakeToken += 1
            timeLeft = max(0, timeLeft - 0.8)
        }
    }

    private func endGame() {
        timer?.invalidate()
        timer = nil
        Sound.fanfare.play()
        finalScore = min(100, correctPops * 8)
        previousBest = app.gameBests["bubble_pop"] ?? 0
        app.recordKidGame(id: "bubble_pop", score: finalScore)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isGameOver = true
        }
    }
}
