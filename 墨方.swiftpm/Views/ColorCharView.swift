import SwiftUI
import UIKit

// MARK: - Drawing model

struct ColorStroke {
    var color: Color
    var points: [CGPoint]
    var lineWidth: CGFloat
}

// MARK: - List / entry view

struct ColorCharView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var presentedChar: CharacterDef? = nil

    var colorableChars: [CharacterDef] {
        let preferred = ["kid:日", "kid:月", "kid:火", "kid:水", "kid:木", "kid:山",
                         "kid:人", "kid:大", "kid:花", "kid:鱼", "kid:心", "kid:雨"]
        let pool = KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all
        return preferred.compactMap { id in pool.first { $0.id == id } }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        headerText
                        charGrid
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.muted)
                        .padding(14)
                }
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(item: $presentedChar) { c in
            ColoringCanvas(character: c).environmentObject(app)
        }
    }

    var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🎨 填 色 描 字")
                .font(.system(size: 22, weight: .black, design: .serif))
                .tracking(4)
            Text("选一个字，用颜色把它填满")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
        }
    }

    var charGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
            spacing: 10
        ) {
            ForEach(colorableChars) { c in
                charCard(c)
                    .contentShape(Rectangle())
                    .onTapGesture { presentedChar = c }
            }
        }
    }

    func charCard(_ c: CharacterDef) -> some View {
        let colored = app.coloredChars.contains(c.id)
        return VStack(spacing: 4) {
            ZStack {
                Color.white
                Text(c.glyph)
                    .font(.system(size: 56, weight: .black, design: .serif))
                    .foregroundColor(colored ? Theme.accent : Color.gray.opacity(0.35))
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1)
            )

            if let m = KidsCharacters.metaFor(c.id) {
                HStack(spacing: 3) {
                    Text(m.emoji).font(.system(size: 12))
                    Text(m.pinyin)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.accent)
                }
            }
            if colored {
                HStack(spacing: 2) {
                    Image(systemName: "paintbrush.fill").font(.system(size: 9))
                    Text("已涂色").font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Theme.accent)
            } else {
                Text("点我涂色")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.muted)
            }
        }
        .padding(.bottom, 6)
    }
}

// MARK: - Coloring canvas

struct ColoringCanvas: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let character: CharacterDef

    @State private var strokes: [ColorStroke] = []
    @State private var current: ColorStroke? = nil
    @State private var selectedColor: Color = Color(red: 0.90, green: 0.30, blue: 0.25)
    @State private var lineWidth: CGFloat = 18
    @State private var celebrate: Bool = false

    static let palette: [Color] = [
        Color(red: 0.90, green: 0.30, blue: 0.25),   // red
        Color(red: 0.98, green: 0.65, blue: 0.18),   // orange
        Color(red: 0.98, green: 0.85, blue: 0.25),   // yellow
        Color(red: 0.40, green: 0.72, blue: 0.40),   // green
        Color(red: 0.35, green: 0.62, blue: 0.88),   // blue
        Color(red: 0.58, green: 0.40, blue: 0.75),   // purple
        Color(red: 0.95, green: 0.55, blue: 0.70),   // pink
        Color(red: 0.35, green: 0.25, blue: 0.18)    // brown
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 1.00, green: 0.96, blue: 0.88),
                Color(red: 0.98, green: 0.92, blue: 0.82)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 12) {
                topBar
                canvasArea
                toolbar
                actionRow
            }
            .padding(20)

            if celebrate { congratsOverlay }
        }
        .navigationBarHidden(true)
    }

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                    Text("返回").font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 6) {
                Text(character.glyph)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Theme.ink)
                if let m = KidsCharacters.metaFor(character.id) {
                    Text(m.pinyin)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.accent)
                    Text("·").foregroundColor(Theme.muted)
                    Text(m.meaning)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.muted)
                }
            }

            Spacer()
            Color.clear.frame(width: 60)
        }
    }

    var canvasArea: some View {
        ZStack {
            Color.white
            GuideStrokeView(strokes: character.strokes, opacity: 0.25, showArrow: false)
            Canvas { ctx, size in
                let all = strokes + (current.map { [$0] } ?? [])
                for s in all {
                    guard let first = s.points.first else { continue }
                    if s.points.count == 1 {
                        let r = s.lineWidth / 2
                        let rect = CGRect(
                            x: first.x - r, y: first.y - r,
                            width: s.lineWidth, height: s.lineWidth
                        )
                        ctx.fill(Path(ellipseIn: rect), with: .color(s.color))
                        continue
                    }
                    var path = Path()
                    path.move(to: first)
                    for p in s.points.dropFirst() { path.addLine(to: p) }
                    ctx.stroke(
                        path,
                        with: .color(s.color),
                        style: StrokeStyle(
                            lineWidth: s.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if current == nil {
                            current = ColorStroke(
                                color: selectedColor,
                                points: [value.location],
                                lineWidth: lineWidth
                            )
                        } else {
                            current?.points.append(value.location)
                        }
                    }
                    .onEnded { _ in
                        if let c = current { strokes.append(c) }
                        current = nil
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Theme.line, lineWidth: 2)
        )
    }

    var toolbar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(Self.palette.indices, id: \.self) { i in
                    let color = Self.palette[i]
                    Button {
                        selectedColor = color
                        Sound.success.play()
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle().stroke(
                                    Color.white,
                                    lineWidth: selectedColor == color ? 4 : 2
                                )
                            )
                            .overlay(
                                Circle().stroke(Theme.ink.opacity(0.2), lineWidth: 1)
                            )
                            .scaleEffect(selectedColor == color ? 1.15 : 1.0)
                            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 10) {
                Text("笔刷")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.muted)
                ForEach([12.0, 18.0, 28.0], id: \.self) { w in
                    Button {
                        lineWidth = CGFloat(w)
                    } label: {
                        Circle()
                            .fill(Theme.ink)
                            .frame(width: CGFloat(w), height: CGFloat(w))
                            .padding(8)
                            .background(
                                Circle().fill(
                                    lineWidth == CGFloat(w)
                                        ? Theme.accent.opacity(0.2)
                                        : Color.clear
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    var actionRow: some View {
        HStack(spacing: 10) {
            Button("清空") {
                strokes = []
                current = nil
            }
            .buttonStyle(GhostButtonStyle())
            .disabled(strokes.isEmpty)

            Spacer()

            Button {
                saveArtwork()
            } label: {
                Label("保存作品", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(strokes.isEmpty)
        }
    }

    @MainActor
    func saveArtwork() {
        let snapshot = ZStack {
            Color.white
            GuideStrokeView(strokes: character.strokes, opacity: 0.25, showArrow: false)
            Canvas { ctx, size in
                for s in strokes {
                    guard let first = s.points.first else { continue }
                    if s.points.count == 1 {
                        let r = s.lineWidth / 2
                        let rect = CGRect(
                            x: first.x - r, y: first.y - r,
                            width: s.lineWidth, height: s.lineWidth
                        )
                        ctx.fill(Path(ellipseIn: rect), with: .color(s.color))
                        continue
                    }
                    var path = Path()
                    path.move(to: first)
                    for p in s.points.dropFirst() { path.addLine(to: p) }
                    ctx.stroke(
                        path,
                        with: .color(s.color),
                        style: StrokeStyle(
                            lineWidth: s.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
        }
        .frame(width: 600, height: 600)

        let renderer = ImageRenderer(content: snapshot)
        renderer.scale = UIScreen.main.scale
        if let img = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
        app.markCharColored(character.id)
        Sound.fanfare.play()
        Speaker.shared.speak("好漂亮的\(character.glyph)字!")
        withAnimation(.spring()) { celebrate = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { celebrate = false }
            dismiss()
        }
    }

    var congratsOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 10) {
                Text("🎨").font(.system(size: 80))
                Text("好美啊!")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("已保存到相册")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
