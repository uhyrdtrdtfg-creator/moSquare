import SwiftUI

// MARK: - Data Models

struct EvolutionStage {
    let era, eraEnglish, representation: String
    let useEmoji: Bool
    let note: String
}

struct EvolutionEntry: Identifiable {
    let id, glyph: String
    let stages: [EvolutionStage]
}

enum EvolutionData {
    static let entries: [EvolutionEntry] = [
        .init(id: "kid:日", glyph: "日", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "☉", useEmoji: true, note: "像一个太阳，中间一点"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "⊙", useEmoji: true, note: "在青铜器上，日变规整了"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "日", useEmoji: false, note: "线条开始变直"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "日", useEmoji: false, note: "方方正正起来了"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "日", useEmoji: false, note: "今天我们写的字!")
        ]),
        .init(id: "kid:月", glyph: "月", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🌙", useEmoji: true, note: "像一弯月亮"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "☾", useEmoji: true, note: "月牙清楚了"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "月", useEmoji: false, note: "拉直了一点"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "月", useEmoji: false, note: "方方的"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "月", useEmoji: false, note: "写成现在这样")
        ]),
        .init(id: "kid:山", glyph: "山", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "⛰️", useEmoji: true, note: "三座小山峰"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "⛰", useEmoji: true, note: "线条化了"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "山", useEmoji: false, note: "三竖排起来"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "山", useEmoji: false, note: "方正"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "山", useEmoji: false, note: "现在这样")
        ]),
        .init(id: "kid:水", glyph: "水", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "〰️", useEmoji: true, note: "像流动的水"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "💧", useEmoji: true, note: "水珠出现了"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "水", useEmoji: false, note: "三条水纹"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "水", useEmoji: false, note: "规整"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "水", useEmoji: false, note: "我们写的水")
        ]),
        .init(id: "kid:火", glyph: "火", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🔥", useEmoji: true, note: "跳动的火焰"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🔥", useEmoji: true, note: "火苗多了"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "火", useEmoji: false, note: "竖起来了"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "火", useEmoji: false, note: "方正"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "火", useEmoji: false, note: "今天的火")
        ]),
        .init(id: "kid:木", glyph: "木", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🌳", useEmoji: true, note: "一棵大树"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🌲", useEmoji: true, note: "简化的树"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "木", useEmoji: false, note: "树干 + 枝"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "木", useEmoji: false, note: "方直"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "木", useEmoji: false, note: "今天的木")
        ]),
        .init(id: "kid:人", glyph: "人", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🚶", useEmoji: true, note: "像一个站着的人"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🧍", useEmoji: true, note: "人形简化"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "人", useEmoji: false, note: "一撇一捺"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "人", useEmoji: false, note: "更直了"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "人", useEmoji: false, note: "今天的人")
        ]),
        .init(id: "kid:口", glyph: "口", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "👄", useEmoji: true, note: "一张嘴"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "⬜", useEmoji: true, note: "简化成方框"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "口", useEmoji: false, note: "方方的"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "口", useEmoji: false, note: "规整"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "口", useEmoji: false, note: "今天的口")
        ]),
        .init(id: "kid:牛", glyph: "牛", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🐂", useEmoji: true, note: "牛的正面头"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🐃", useEmoji: true, note: "牛角显眼"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "牛", useEmoji: false, note: "简化"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "牛", useEmoji: false, note: "方正"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "牛", useEmoji: false, note: "现在的牛")
        ]),
        .init(id: "kid:羊", glyph: "羊", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🐏", useEmoji: true, note: "羊角弯弯"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🐑", useEmoji: true, note: "羊形简化"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "羊", useEmoji: false, note: "竖起来"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "羊", useEmoji: false, note: "方直"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "羊", useEmoji: false, note: "今天的羊")
        ]),
        .init(id: "kid:鱼", glyph: "鱼", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🐟", useEmoji: true, note: "一条鱼"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🐠", useEmoji: true, note: "鱼鳞出现"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "鱼", useEmoji: false, note: "线条化"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "鱼", useEmoji: false, note: "方正"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "鱼", useEmoji: false, note: "现在的鱼")
        ]),
        .init(id: "kid:鸟", glyph: "鸟", stages: [
            .init(era: "甲骨文", eraEnglish: "Oracle", representation: "🐦", useEmoji: true, note: "一只鸟"),
            .init(era: "金文", eraEnglish: "Bronze", representation: "🕊️", useEmoji: true, note: "翅膀张开"),
            .init(era: "小篆", eraEnglish: "Seal", representation: "鸟", useEmoji: false, note: "简化"),
            .init(era: "隶书", eraEnglish: "Clerical", representation: "鸟", useEmoji: false, note: "方直"),
            .init(era: "楷书", eraEnglish: "Standard", representation: "鸟", useEmoji: false, note: "今天的鸟")
        ])
    ]
}

// MARK: - List View

struct EvolutionView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var presented: EvolutionEntry? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header
                        entryGrid
                        Spacer(minLength: 30)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $presented) { entry in
            EvolutionDetail(entry: entry).environmentObject(app)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("📜 字形演变")
                    .font(.system(size: 30, weight: .black, design: .serif))
                    .foregroundColor(Theme.ink)
                Text("字本来像画 — 看看它们怎么变过来的")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Theme.muted)
            }
        }
    }

    private var entryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(EvolutionData.entries) { entry in
                entryCard(entry).onTapGesture { presented = entry }
            }
        }
    }

    private func entryCard(_ entry: EvolutionEntry) -> some View {
        let seen = app.evolutionSeen.contains(entry.id)
        return VStack(spacing: 6) {
            HStack(spacing: 4) {
                Text(entry.stages[0].representation).font(.system(size: 24))
                Text("→").font(.system(size: 10)).foregroundColor(Theme.muted)
                Text(entry.glyph)
                    .font(.system(size: 32, weight: .black, design: .serif))
                    .foregroundColor(Theme.ink)
            }
            if seen {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 9))
                    Text("看过").font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Theme.accent)
            } else {
                Text("点我看").font(.system(size: 10, weight: .bold)).foregroundColor(Theme.accent)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding(10)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Detail View

struct EvolutionDetail: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let entry: EvolutionEntry

    @State private var currentStage: Int = 0
    @State private var isPlaying: Bool = false

    var body: some View {
        ZStack {
            ancientBg
            VStack(spacing: 16) {
                topBar
                stageProgress
                Spacer()
                stageDisplay
                stageNote
                Spacer()
                controls
                markSeenButton
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .onAppear { startPlay() }
        .onDisappear { isPlaying = false }
    }

    private var ancientBg: some View {
        LinearGradient(colors: [Color(red: 0.18, green: 0.12, blue: 0.08), Color(red: 0.28, green: 0.20, blue: 0.12)],
                       startPoint: .top, endPoint: .bottom).ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.75))
            }
            Spacer()
            Text("📜 字形演变 · \(entry.glyph)")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(.white)
            Spacer()
            Text("\(currentStage + 1)/\(entry.stages.count)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.gold)
        }
    }

    private var stageProgress: some View {
        HStack(spacing: 8) {
            ForEach(0..<entry.stages.count, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStage ? Theme.gold : Color.white.opacity(0.2))
                    .frame(width: i == currentStage ? 24 : 10, height: 6)
                    .animation(.easeInOut(duration: 0.4), value: currentStage)
            }
        }
    }

    private var stageDisplay: some View {
        let stage = entry.stages[currentStage]
        return VStack(spacing: 16) {
            Text(stage.representation)
                .font(.system(size: stage.useEmoji ? 180 : 200,
                              weight: stageWeight(for: currentStage),
                              design: stageDesign(for: currentStage)))
                .foregroundColor(.white)
                .shadow(color: Theme.gold.opacity(0.4), radius: 30)
            Text(stage.era)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .tracking(8)
                .foregroundColor(Theme.gold)
            Text(stage.eraEnglish)
                .font(.system(size: 12))
                .tracking(4)
                .foregroundColor(.white.opacity(0.6))
        }
        .id(currentStage)
        .transition(.opacity.combined(with: .scale))
    }

    private var stageNote: some View {
        let stage = entry.stages[currentStage]
        return Text(stage.note)
            .font(.system(size: 16, design: .serif))
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .id("note-\(currentStage)")
            .transition(.opacity)
    }

    private var controls: some View {
        HStack(spacing: 20) {
            Button { prev() } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.gold)
            }
            .disabled(currentStage == 0)
            .opacity(currentStage == 0 ? 0.35 : 1)

            Button { togglePlay() } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.white)
            }

            Button { nextStage() } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.gold)
            }
            .disabled(currentStage >= entry.stages.count - 1)
            .opacity(currentStage >= entry.stages.count - 1 ? 0.35 : 1)
        }
    }

    @ViewBuilder
    private var markSeenButton: some View {
        if currentStage == entry.stages.count - 1 {
            Button {
                app.markEvolutionSeen(entry.id)
                Sound.sticker.play()
                Speaker.shared.speak("字的一生，看完啦")
                dismiss()
            } label: {
                Text("✓ 看懂啦!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .tracking(4)
            }
            .buttonStyle(PrimaryButtonStyle())
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        } else {
            Color.clear.frame(height: 48)
        }
    }

    // MARK: - Style helpers

    private func stageWeight(for idx: Int) -> Font.Weight {
        switch idx {
        case 2: return .semibold
        case 3: return .bold
        default: return .regular
        }
    }

    private func stageDesign(for idx: Int) -> Font.Design {
        idx >= 2 ? .serif : .default
    }

    // MARK: - Play logic

    private func startPlay() {
        isPlaying = true
        let stage = entry.stages[currentStage]
        Speaker.shared.speak(stage.era)
        playLoop()
    }

    private func playLoop() {
        guard isPlaying else { return }
        if currentStage < entry.stages.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                guard isPlaying else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentStage += 1
                }
                let stage = entry.stages[currentStage]
                Speaker.shared.speak(stage.era)
                if currentStage == entry.stages.count - 1 {
                    Sound.success.play()
                    isPlaying = false
                } else {
                    playLoop()
                }
            }
        } else {
            isPlaying = false
        }
    }

    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            if currentStage == entry.stages.count - 1 {
                withAnimation { currentStage = 0 }
            }
            playLoop()
        }
    }

    private func prev() {
        if currentStage > 0 {
            isPlaying = false
            withAnimation(.easeInOut(duration: 0.3)) { currentStage -= 1 }
            Speaker.shared.speak(entry.stages[currentStage].era)
        }
    }

    private func nextStage() {
        if currentStage < entry.stages.count - 1 {
            isPlaying = false
            withAnimation(.easeInOut(duration: 0.3)) { currentStage += 1 }
            Speaker.shared.speak(entry.stages[currentStage].era)
        }
    }
}
