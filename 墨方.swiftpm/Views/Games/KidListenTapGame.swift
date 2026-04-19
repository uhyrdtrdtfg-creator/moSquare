import SwiftUI

struct KidListenTapGame: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var roundIndex = 0
    @State private var correctCount = 0
    @State private var options: [CharacterDef] = []
    @State private var correctIndex = 0
    @State private var hasAnsweredCorrectly = false
    @State private var anyWrongThisRound = false
    @State private var wrongFlashIndex: Int? = nil
    @State private var correctFlash = false
    @State private var shakeToken = 0
    @State private var isGameOver = false
    @State private var previousBest = 0
    @State private var celebrateText: String? = nil

    private let greenFlash = Color(red: 0.20, green: 0.70, blue: 0.40)
    private let redFlash = Color(red: 0.90, green: 0.30, blue: 0.25)

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

            if isGameOver {
                resultView
            } else {
                gameView
            }
        }
        .navigationBarHidden(true)
        .onAppear { startNewRound() }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            Text("🔊 听音找字")
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(Theme.ink)
            Spacer()
            Text("第 \(min(roundIndex + 1, 10))/10 题")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.highlight))
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Game view
    private var gameView: some View {
        VStack(spacing: 28) {
            topBar

            Spacer(minLength: 0)

            Button(action: { speakCurrent() }) {
                ZStack {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 130, height: 130)
                        .shadow(color: Theme.accent.opacity(0.35), radius: 12, x: 0, y: 6)
                    Text("🔊")
                        .font(.system(size: 80))
                }
            }
            .buttonStyle(.plain)

            Text("听一听，点出对应的字")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.muted)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)], spacing: 24) {
                ForEach(0..<options.count, id: \.self) { idx in
                    cardView(for: idx)
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: 520)

            if let text = celebrateText {
                Text(text)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(greenFlash)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer(minLength: 0)

            Text("点错了也没关系，再试试!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.muted)
                .padding(.bottom, 20)
        }
    }

    private func cardView(for idx: Int) -> some View {
        let def = options[idx]
        let meta = KidsCharacters.metaFor(def.id)
        let isWrong = wrongFlashIndex == idx
        let isCorrect = correctFlash && idx == correctIndex
        let bg: Color = isCorrect ? greenFlash.opacity(0.85) : (isWrong ? redFlash.opacity(0.80) : Color.white)
        let fg: Color = (isCorrect || isWrong) ? .white : Theme.ink

        return Button(action: { handleTap(index: idx) }) {
            VStack(spacing: 8) {
                Text(def.glyph)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundColor(fg)
                if let meta = meta {
                    Text(meta.pinyin)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(fg.opacity(0.85))
                }
            }
            .frame(width: 140, height: 170)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(bg)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .modifier(ShakeEffect(shakes: isWrong ? shakeToken : 0))
        .animation(.easeInOut(duration: 0.25), value: wrongFlashIndex)
        .animation(.easeInOut(duration: 0.25), value: correctFlash)
    }

    // MARK: - Result view
    private var resultView: some View {
        let score = correctCount * 10
        let medal = score >= 90 ? "🥇" : (score >= 70 ? "🥈" : "🥉")
        let isNewBest = score > previousBest

        return VStack(spacing: 24) {
            Spacer()

            Text("🎉 结束啦!")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(Theme.ink)

            Text(medal)
                .font(.system(size: 96))

            Text("\(score)")
                .font(.system(size: 96, weight: .black))
                .foregroundColor(Theme.accent)

            Text("答对 \(correctCount) / 10 题")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Theme.muted)

            if isNewBest {
                Text("✨ 新纪录!")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.gold))
            }

            Spacer()

            HStack(spacing: 18) {
                Button("再来一局") { resetGame() }
                    .buttonStyle(PrimaryButtonStyle(filled: true))
                Button("返回") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 30)
    }

    // MARK: - Logic
    private func startNewRound() {
        hasAnsweredCorrectly = false
        anyWrongThisRound = false
        wrongFlashIndex = nil
        correctFlash = false
        celebrateText = nil

        let pool = KidsCharacters.all.shuffled()
        options = Array(pool.prefix(4))
        correctIndex = Int.random(in: 0..<min(4, options.count))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            speakCurrent()
        }
    }

    private func speakCurrent() {
        guard correctIndex < options.count else { return }
        // 念汉字（zh-CN TTS 会正确读出拼音发音）；不要直接念 "sān" 字符串
        Speaker.shared.speak(options[correctIndex].glyph)
    }

    private func handleTap(index: Int) {
        if hasAnsweredCorrectly { return }
        if index == correctIndex {
            Sound.success.play()
            hasAnsweredCorrectly = true
            correctFlash = true
            if !anyWrongThisRound {
                correctCount += 1
            }
            withAnimation(.spring()) {
                celebrateText = Encouragements.randomPerCharacter()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                advance()
            }
        } else {
            Sound.fail.play()
            anyWrongThisRound = true
            wrongFlashIndex = index
            shakeToken += 1
            withAnimation(.spring()) {
                celebrateText = "😅 " + Encouragements.randomOnFail()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongFlashIndex = nil
                withAnimation { celebrateText = nil }
            }
        }
    }

    private func advance() {
        if roundIndex < 9 {
            roundIndex += 1
            startNewRound()
        } else {
            endGame()
        }
    }

    private func endGame() {
        let score = correctCount * 10
        previousBest = app.gameBests["listen_tap"] ?? 0
        app.recordKidGame(id: "listen_tap", score: score)
        Sound.fanfare.play()
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameOver = true
        }
    }

    private func resetGame() {
        roundIndex = 0
        correctCount = 0
        isGameOver = false
        previousBest = 0
        startNewRound()
    }
}
