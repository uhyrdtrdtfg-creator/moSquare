import SwiftUI

/// 认字闪卡 · 每卡一个字，跟读 + 看图理解
/// 洪恩 玩-认-练-写 中的"认"步：先认识再书写
struct FlashcardStudyView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPack: Pack? = nil

    enum Pack: String, Identifiable, CaseIterable {
        case basic, nature, bodyAnimal, direction, all
        var id: String { rawValue }
        var title: String {
            switch self {
            case .basic: return "基础 19 字"
            case .nature: return "自然 · 天地"
            case .bodyAnimal: return "身体 + 动物"
            case .direction: return "方位"
            case .all: return "全部 49 字"
            }
        }
        var emoji: String {
            switch self {
            case .basic: return "📝"
            case .nature: return "🌞"
            case .bodyAnimal: return "🐾"
            case .direction: return "🧭"
            case .all: return "🎓"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header
                        packGrid
                        Spacer(minLength: 30)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $selectedPack) { pack in
            FlashcardSession(chars: charsForPack(pack), packTitle: pack.title)
                .environmentObject(app)
        }
    }

    // MARK: - Header + grid

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                        Text("返回")
                    }.foregroundColor(Theme.accent)
                }.buttonStyle(.plain)
                Spacer()
            }
            Text("📚 认字课")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .tracking(8).foregroundColor(Theme.ink)
            Text("看一看，听一听，记住这些字")
                .font(.system(size: 14, design: .serif))
                .tracking(2).foregroundColor(Theme.muted)
        }
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var packGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 14) {
            ForEach(Pack.allCases) { pack in packCard(pack) }
        }
    }

    private func packCard(_ pack: Pack) -> some View {
        VStack(spacing: 6) {
            Text(pack.emoji).font(.system(size: 40))
            Text(pack.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.ink).tracking(2)
                .multilineTextAlignment(.center)
            Text("\(charsForPack(pack).count) 字")
                .font(.system(size: 11)).foregroundColor(Theme.muted)
            Text("点我开始")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.accent).tracking(1)
        }
        .frame(maxWidth: .infinity, minHeight: 140).padding(14)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture { Sound.pop.play(); selectedPack = pack }
    }

    // MARK: - Data

    func charsForPack(_ p: Pack) -> [CharacterDef] {
        let extra = KidsCharactersExtra.all
        switch p {
        case .basic:      return KidsCharacters.all
        case .nature:     return Array(extra.prefix(min(14, extra.count)))
        case .bodyAnimal:
            let lo = min(14, extra.count), hi = min(26, extra.count)
            return Array(extra[lo..<hi])
        case .direction:  return Array(extra.suffix(min(5, extra.count)))
        case .all:        return KidsCharacters.all + extra
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - FlashcardSession
// ─────────────────────────────────────────────────────────────────

struct FlashcardSession: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    let chars: [CharacterDef]
    let packTitle: String

    @State private var index: Int = 0
    @State private var showSummary: Bool = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            warmBg
            VStack(spacing: 14) {
                topBar
                Spacer()
                if showSummary {
                    summaryView.transition(.scale.combined(with: .opacity))
                } else if !chars.isEmpty {
                    flashcardView
                    bottomControls
                } else {
                    Text("这个包还没有字～")
                        .font(.system(size: 18, design: .serif))
                        .foregroundColor(Theme.muted)
                }
                Spacer()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .onAppear {
            if !chars.isEmpty { speakCurrent() }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                    Text("退出")
                }.foregroundColor(Theme.accent)
            }.buttonStyle(.plain)
            Spacer()
            Text("📚 \(packTitle)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .tracking(2).foregroundColor(Theme.ink)
            Spacer()
            if !showSummary && !chars.isEmpty {
                Text("\(index + 1)/\(chars.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.white))
                    .overlay(Capsule().stroke(Theme.accent.opacity(0.4), lineWidth: 1))
            } else {
                Color.clear.frame(width: 60, height: 20)
            }
        }
    }

    // MARK: - Flashcard

    private var flashcardView: some View {
        let c = chars[index]
        let meta = KidsCharacters.metaFor(c.id)
        return VStack(spacing: 20) {
            Text(meta?.emoji ?? "✨").font(.system(size: 64))
            Text(c.glyph)
                .font(.system(size: 180, weight: .black, design: .serif))
                .foregroundColor(Theme.ink)
                .lineLimit(1).minimumScaleFactor(0.4)
            HStack(spacing: 10) {
                Text(meta?.pinyin ?? "")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.accent).tracking(4)
                Button { speakCurrent() } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .font(.system(size: 40)).foregroundColor(Theme.accent)
                }.buttonStyle(.plain)
            }
            Text(meta?.meaning ?? c.subtitle)
                .font(.system(size: 20, design: .serif))
                .foregroundColor(Theme.muted).tracking(2)
                .multilineTextAlignment(.center)
        }
        .padding(30).frame(maxWidth: 500)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.gold.opacity(0.4), lineWidth: 2))
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width / 24)))
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        let dir: CGFloat = value.translation.width > 0 ? 1 : -1
                        withAnimation(.easeOut(duration: 0.25)) {
                            dragOffset = CGSize(width: dir * 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            if dir > 0 { prev() } else { next() }
                            dragOffset = .zero
                        }
                    } else {
                        withAnimation(.spring()) { dragOffset = .zero }
                    }
                }
        )
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        HStack(spacing: 16) {
            Button { prev() } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(index > 0 ? Theme.accent : Theme.muted.opacity(0.4))
            }.buttonStyle(.plain).disabled(index <= 0)
            Spacer()
            Text(index + 1 == chars.count ? "完成 🎉" : "下一张 →")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .tracking(2).foregroundColor(.white)
                .padding(.horizontal, 22).padding(.vertical, 12)
                .background(Capsule().fill(Theme.accent))
                .contentShape(Capsule())
                .onTapGesture { next() }
            Spacer()
            Button { speakCurrent() } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 44)).foregroundColor(Theme.accent)
            }.buttonStyle(.plain)
        }
        .frame(maxWidth: 500)
    }

    // MARK: - Summary

    private var summaryView: some View {
        VStack(spacing: 14) {
            Text("🎊").font(.system(size: 80))
            Text("学完啦!")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .tracking(6).foregroundColor(Theme.accent)
            Text("认识了 \(chars.count) 个字")
                .font(.system(size: 14))
                .foregroundColor(Theme.muted).tracking(2)
            Text(Encouragements.randomPerStroke())
                .font(.system(size: 13, design: .serif))
                .foregroundColor(Theme.ink.opacity(0.7))
                .tracking(2).multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(44), spacing: 6), count: 8),
                spacing: 6
            ) {
                ForEach(chars) { c in
                    Text(c.glyph)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Theme.ink)
                        .frame(width: 40, height: 40)
                        .background(Theme.highlight.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }.padding(.vertical, 12)

            HStack(spacing: 10) {
                Button("再来一次") {
                    Sound.pop.play(); index = 0
                    withAnimation(.spring()) { showSummary = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { speakCurrent() }
                }.buttonStyle(PrimaryButtonStyle(filled: false))
                Button("去练字") { Sound.pop.play(); dismiss() }
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Background

    private var warmBg: some View {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.97, blue: 0.88),
                Color(red: 0.98, green: 0.92, blue: 0.78)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Actions

    private func next() {
        guard !chars.isEmpty else { return }
        if index + 1 >= chars.count {
            endSession()
        } else {
            Sound.success.play()
            index += 1
            speakCurrent()
        }
    }

    private func prev() {
        guard index > 0 else { return }
        Sound.success.play()
        index -= 1
        speakCurrent()
    }

    private func speakCurrent() {
        guard index >= 0 && index < chars.count else { return }
        // 只念字 —— 有 MP3 就播晓晓神经网络，没有就系统 TTS。
        // 不念 meaning 避免"大 大大的"这种回声
        Speaker.shared.speak(chars[index].glyph)
    }

    private func endSession() {
        Sound.fanfare.play()
        app.recordFlashcardSession(count: chars.count)
        Speaker.shared.speak("太棒啦，一起学会了\(chars.count)个字")
        withAnimation(.spring()) { showSummary = true }
    }
}
