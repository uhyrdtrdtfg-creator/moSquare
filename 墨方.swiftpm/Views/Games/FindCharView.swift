import SwiftUI

struct FindCharView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var presentedLevel: FindLevel? = nil

    static let levels: [FindLevel] = [
        .init(id: "f1", title: "第一关", targetGlyph: "日", gridSize: 4, targetCount: 3, distractorCount: 13),
        .init(id: "f2", title: "第二关", targetGlyph: "月", gridSize: 4, targetCount: 4, distractorCount: 12),
        .init(id: "f3", title: "第三关", targetGlyph: "山", gridSize: 5, targetCount: 4, distractorCount: 21),
        .init(id: "f4", title: "第四关", targetGlyph: "水", gridSize: 5, targetCount: 5, distractorCount: 20),
        .init(id: "f5", title: "第五关", targetGlyph: "花", gridSize: 6, targetCount: 6, distractorCount: 30)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        headerText
                        levelGrid
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $presentedLevel) { level in
            FindCharGame(level: level).environmentObject(app)
        }
    }

    var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔍 字 卡 找 找 看")
                .font(.system(size: 22, weight: .black, design: .serif))
                .tracking(4)
            Text("在格子里找出所有目标字")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
        }
    }

    var levelGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Self.levels) { level in
                levelCard(level)
            }
        }
    }

    func levelCard(_ level: FindLevel) -> some View {
        let done = app.findCompleted.contains(level.id)
        return Button {
            presentedLevel = level
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(Theme.ink)
                    Text("找 \(level.targetCount) 个「\(level.targetGlyph)」")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.muted)
                    if done {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 10))
                            Text("通关").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Theme.accent)
                    } else {
                        Text("挑战")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.accent)
                    }
                }
                Spacer()
                Text(level.targetGlyph)
                    .font(.system(size: 46, weight: .black, design: .serif))
                    .foregroundColor(done ? Theme.accent : Theme.ink)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 90)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

struct FindLevel: Identifiable, Hashable {
    let id: String
    let title: String
    let targetGlyph: String
    let gridSize: Int
    let targetCount: Int
    let distractorCount: Int
    var totalTiles: Int { targetCount + distractorCount }
}

struct FindCharGame: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let level: FindLevel

    struct Tile: Identifiable {
        let id: UUID = UUID()
        let glyph: String
        let isTarget: Bool
        var foundOrMissed: Bool = false
        var bgColor: Color
    }

    @State private var tiles: [Tile] = []
    @State private var foundCount: Int = 0
    @State private var missClicks: Int = 0
    @State private var shakeToken: Int = 0
    @State private var finished: Bool = false
    @State private var startTime: Date = Date()
    @State private var elapsedText: String = "0 秒"

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.95, green: 0.97, blue: 0.88),
                Color(red: 0.92, green: 0.93, blue: 0.78)
            ], startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 12) {
                topBar
                targetDisplay
                grid
                statusRow
                Spacer(minLength: 4)
            }.padding(20)

            if finished { winOverlay }
        }
        .navigationBarHidden(true)
        .onAppear { setup() }
    }

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack { Image(systemName: "xmark.circle.fill").font(.system(size: 24)); Text("退出") }.foregroundColor(Theme.accent)
            }.buttonStyle(.plain)
            Spacer()
            Text("🔍 \(level.title)").font(.system(size: 16, weight: .bold, design: .rounded)).tracking(2)
            Spacer()
            Text("\(foundCount) / \(level.targetCount)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(Theme.accent))
        }
    }

    var targetDisplay: some View {
        HStack(spacing: 10) {
            Text("找:").font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.muted)
            Text(level.targetGlyph)
                .font(.system(size: 40, weight: .black, design: .serif))
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 14).padding(.vertical, 4)
                .background(Theme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if let m = KidsCharacters.metaFor("kid:\(level.targetGlyph)") {
                Text(m.pinyin).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(Theme.accent)
                Button {
                    Speaker.shared.speak(level.targetGlyph)
                } label: { Image(systemName: "speaker.wave.2.fill") }.buttonStyle(.plain)
            }
            Spacer()
        }
    }

    var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: level.gridSize),
            spacing: 6
        ) {
            ForEach(tiles) { tile in
                tileView(tile)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .modifier(ShakeEffect(shakes: shakeToken))
    }

    func tileView(_ tile: Tile) -> some View {
        let isFoundTarget = tile.isTarget && tile.foundOrMissed
        let isMissDim = !tile.isTarget && tile.foundOrMissed
        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isFoundTarget ? Theme.accent.opacity(0.9) : tile.bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFoundTarget ? Theme.accent : Color.white.opacity(0.85), lineWidth: 2)
                )
            Text(tile.glyph)
                .font(.system(size: fontForSize, weight: .bold, design: .serif))
                .foregroundColor(isFoundTarget ? .white : Theme.ink)
            if isFoundTarget {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .offset(x: 18, y: -18)
            }
        }
        .opacity(isMissDim ? 0.35 : 1.0)
        .frame(height: tileSize)
        .scaleEffect(isFoundTarget ? 1.05 : 1.0)
        .onTapGesture { tap(tile) }
    }

    var tileSize: CGFloat {
        switch level.gridSize {
        case 4: return 80
        case 5: return 64
        default: return 52
        }
    }

    var fontForSize: CGFloat {
        switch level.gridSize {
        case 4: return 36
        case 5: return 30
        default: return 24
        }
    }

    var statusRow: some View {
        HStack {
            Label("用时 \(elapsedText)", systemImage: "clock")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.muted)
            Spacer()
            if missClicks > 0 {
                Label("失误 \(missClicks)", systemImage: "exclamationmark.circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.accent)
            }
        }
    }

    func setup() {
        startTime = Date()
        foundCount = 0
        missClicks = 0
        finished = false

        var list: [Tile] = []
        let palette = [
            Color(red: 1.00, green: 0.95, blue: 0.85),
            Color(red: 0.98, green: 0.88, blue: 0.75),
            Color(red: 0.90, green: 0.94, blue: 0.85),
            Color(red: 0.88, green: 0.92, blue: 0.98),
            Color(red: 0.96, green: 0.85, blue: 0.90),
            Color(red: 0.94, green: 0.90, blue: 0.80)
        ]

        for _ in 0..<level.targetCount {
            list.append(Tile(glyph: level.targetGlyph, isTarget: true, bgColor: palette.randomElement() ?? .white))
        }
        let pool = (KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all)
            .map(\.glyph)
            .filter { $0 != level.targetGlyph }
        for _ in 0..<level.distractorCount {
            let g = pool.randomElement() ?? "一"
            list.append(Tile(glyph: g, isTarget: false, bgColor: palette.randomElement() ?? .white))
        }

        tiles = list.shuffled()

        Speaker.shared.speak("找出所有的 \(level.targetGlyph)")
    }

    func tap(_ tile: Tile) {
        if finished { return }
        guard let idx = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
        if tiles[idx].foundOrMissed { return }

        if tile.isTarget {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                tiles[idx].foundOrMissed = true
            }
            foundCount += 1
            Sound.success.play()
            if foundCount >= level.targetCount {
                finishLevel()
            }
        } else {
            missClicks += 1
            shakeToken += 1
            Sound.fail.play()
            withAnimation(.easeInOut(duration: 0.2)) {
                tiles[idx].foundOrMissed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let i2 = tiles.firstIndex(where: { $0.id == tile.id }) {
                    withAnimation { tiles[i2].foundOrMissed = false }
                }
            }
        }

        let secs = Int(Date().timeIntervalSince(startTime))
        elapsedText = "\(secs) 秒"
    }

    func finishLevel() {
        let secs = Int(Date().timeIntervalSince(startTime))
        elapsedText = "\(secs) 秒"
        Sound.fanfare.play()
        Speaker.shared.speak("全部找到啦，真棒!")
        app.markFindCompleted(level.id)
        withAnimation(.spring()) { finished = true }
    }

    var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🏆").font(.system(size: 80))
                Text("找到啦!")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .tracking(4).foregroundColor(.white)
                Text("用时 \(elapsedText) · 失误 \(missClicks) 次")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                HStack(spacing: 10) {
                    Button("再来一局") { setup() }.buttonStyle(PrimaryButtonStyle())
                    Button("返回") { dismiss() }.buttonStyle(GhostButtonStyle()).tint(.white).foregroundColor(.white)
                }.padding(.top, 10)
            }
            .padding(30)
            .background(Color.black.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
