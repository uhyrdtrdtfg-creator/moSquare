import SwiftUI

struct KidMemoryMatchGame: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    struct Card: Identifiable {
        let id: UUID = UUID()
        let pairID: Int
        let kind: Kind
        var isFlipped: Bool = false
        var isMatched: Bool = false
        enum Kind {
            case glyph(String)
            case emoji(String)
        }
    }

    @State private var cards: [Card] = []
    @State private var firstIndex: Int? = nil
    @State private var attempts: Int = 0
    @State private var matchedPairs: Int = 0
    @State private var startTime: Date = Date()
    @State private var isGameOver: Bool = false
    @State private var busy: Bool = false
    @State private var finalScore: Int = 0
    @State private var previousBest: Int = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.95, blue: 0.85),
                    Color(red: 1.00, green: 0.98, blue: 0.92),
                    Color(red: 0.98, green: 0.93, blue: 0.80)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                topBar
                cardGrid
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)

            if isGameOver {
                resultOverlay
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            if cards.isEmpty { startGame() }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 14) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.muted)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("🃏 翻翻配对")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.ink)

            Spacer()

            HStack(spacing: 10) {
                Text("配对 \(matchedPairs)/6")
                Text("·")
                    .foregroundColor(Theme.muted)
                Text("尝试 \(attempts)")
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(Theme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(Color.white.opacity(0.85))
            )
            .overlay(
                Capsule().stroke(Theme.line, lineWidth: 1)
            )
        }
    }

    // MARK: - Card grid

    private var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                cardView(card: card, index: index)
            }
        }
        .padding(.top, 6)
    }

    @ViewBuilder
    private func cardView(card: Card, index: Int) -> some View {
        ZStack {
            if card.isFlipped || card.isMatched {
                frontFace(for: card)
            } else {
                backFace
            }
        }
        .frame(width: 110, height: 130)
        .scaleEffect(card.isMatched ? 1.03 : 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(card.isMatched ? Theme.accent : Color.clear, lineWidth: 3)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 3)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: card.isFlipped)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: card.isMatched)
        .onTapGesture {
            if !busy { flip(at: index) }
        }
    }

    private var backFace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.55, blue: 0.30),
                            Color(red: 1.00, green: 0.78, blue: 0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("?")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
    }

    @ViewBuilder
    private func frontFace(for card: Card) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
            switch card.kind {
            case .glyph(let g):
                Text(g)
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(Theme.ink)
            case .emoji(let e):
                Text(e)
                    .font(.system(size: 48))
            }
        }
    }

    // MARK: - Result overlay

    private var resultOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 18) {
                Text("🎉 全部配对啦!")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.ink)

                let elapsed = Int(Date().timeIntervalSince(startTime))
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(elapsed)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(Theme.accent2)
                    Text("秒")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.muted)
                }

                Text("\(finalScore)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(Theme.accent)

                Text(medal(for: finalScore))
                    .font(.system(size: 50))

                if finalScore > previousBest {
                    Text("✨ 新纪录")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Theme.gold))
                }

                HStack(spacing: 14) {
                    Button("再来一局") {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            startGame()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("返回") { dismiss() }
                        .buttonStyle(GhostButtonStyle())
                }
                .padding(.top, 6)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 1.0, green: 0.99, blue: 0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Theme.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 40)
        }
    }

    private func medal(for score: Int) -> String {
        if score >= 90 { return "🥇" }
        if score >= 70 { return "🥈" }
        return "🥉"
    }

    // MARK: - Game logic

    private func startGame() {
        let pool = Array(KidsCharacters.all.shuffled().prefix(6))
        var newCards: [Card] = []
        for (i, c) in pool.enumerated() {
            newCards.append(Card(pairID: i, kind: .glyph(c.glyph)))
            let emoji = KidsCharacters.metaFor(c.id)?.emoji ?? "⭐"
            newCards.append(Card(pairID: i, kind: .emoji(emoji)))
        }
        cards = newCards.shuffled()
        firstIndex = nil
        attempts = 0
        matchedPairs = 0
        startTime = Date()
        isGameOver = false
        busy = false
        finalScore = 0
        previousBest = app.gameBests["memory_match"] ?? 0
    }

    private func flip(at idx: Int) {
        guard idx >= 0, idx < cards.count else { return }
        guard !cards[idx].isFlipped, !cards[idx].isMatched, !busy else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            cards[idx].isFlipped = true
        }
        Sound.success.play()

        if let first = firstIndex {
            attempts += 1
            busy = true
            if cards[first].pairID == cards[idx].pairID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        cards[first].isMatched = true
                        cards[idx].isMatched = true
                        matchedPairs += 1
                    }
                    firstIndex = nil
                    busy = false
                    Sound.sticker.play()
                    if matchedPairs == 6 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            endGame()
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        cards[first].isFlipped = false
                        cards[idx].isFlipped = false
                    }
                    firstIndex = nil
                    busy = false
                    Sound.fail.play()
                }
            }
        } else {
            firstIndex = idx
        }
    }

    private func endGame() {
        Sound.fanfare.play()
        let extra = max(0, attempts - 6)
        finalScore = max(40, 100 - extra * 6)
        previousBest = app.gameBests["memory_match"] ?? 0
        app.recordKidGame(id: "memory_match", score: finalScore)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isGameOver = true
        }
    }
}
