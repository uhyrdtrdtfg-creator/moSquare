import SwiftUI

// MARK: - FlowLayout (shared)

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineH: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth {
                x = 0
                y += lineH + spacing
                lineH = 0
            }
            x += sz.width + spacing
            lineH = max(lineH, sz.height)
        }
        let finalWidth = maxWidth.isFinite ? maxWidth : x
        return CGSize(width: finalWidth, height: y + lineH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineH: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX {
                x = bounds.minX
                y += lineH + spacing
                lineH = 0
            }
            sv.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += sz.width + spacing
            lineH = max(lineH, sz.height)
        }
    }
}

// MARK: - StoryView (绘本书架)

struct StoryView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var presentedFable: Fable? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        headerBar
                        headerText
                        fableGrid
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $presentedFable) { fable in
            FablePictureBookView(fable: fable).environmentObject(app)
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
            }
            Spacer()
            Text("已读 \(app.storiesRead.count)/\(FablePool.all.count)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.highlight.opacity(0.7))
                .clipShape(Capsule())
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("📖 识 字 绘 本 · 寓言三十则")
                .font(.system(size: 22, weight: .black, design: .serif))
                .tracking(4)
            Text("翻一页，读一篇。学过的字会变亮，点一下会说话。")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
        }
    }

    private var fableGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ], spacing: 14) {
            ForEach(FablePool.all) { fable in
                fableCard(fable)
            }
        }
    }

    private func fableCard(_ fable: Fable) -> some View {
        let isRead = app.storiesRead.contains(fable.id)
        return VStack(spacing: 6) {
            ZStack {
                FableSceneBackground(scene: fable.pages.first?.scene ?? .hills,
                                     thumbnail: true)
                    .frame(height: 90)
                    .clipped()
                Text(fable.cover).font(.system(size: 38))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(fable.title)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundColor(Theme.ink)
                .lineLimit(1)
            Text("\(fable.pages.count) 页")
                .font(.system(size: 10))
                .foregroundColor(Theme.muted)
            if isRead {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 9))
                    Text("已读").font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(Theme.accent)
            } else {
                Text("翻开")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.accent)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            presentedFable = fable
        }
    }
}

// MARK: - FablePictureBookView (翻页阅读)

struct FablePictureBookView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    let fable: Fable

    // 0 = cover, 1...N = pages[0..N-1], N+1 = moral/end page
    @State private var pageIndex: Int = 0
    @State private var celebrate: Bool = false

    private var totalPages: Int { fable.pages.count + 2 }  // cover + pages + end

    var body: some View {
        ZStack {
            // 当前页背景
            currentBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: pageIndex)

            // 内容层
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                currentPageContent
                    .padding(.horizontal, 24)
                Spacer(minLength: 0)
                pageControls
            }
            .padding(.vertical, 16)

            if celebrate { congratsOverlay }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -40 { nextPage() }
                    else if value.translation.width > 40 { prevPage() }
                }
        )
    }

    // MARK: Background switch

    @ViewBuilder
    private var currentBackground: some View {
        if pageIndex == 0 {
            FableSceneBackground(scene: fable.pages.first?.scene ?? .hills)
        } else if pageIndex <= fable.pages.count {
            FableSceneBackground(scene: fable.pages[pageIndex - 1].scene)
        } else {
            FableSceneBackground(scene: fable.pages.last?.scene ?? .hills)
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                    Text("关上")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.85))
                .clipShape(Capsule())
            }
            Spacer()
            Text("\(pageIndex + 1) / \(totalPages)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.85))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
    }

    // MARK: Page content

    @ViewBuilder
    private var currentPageContent: some View {
        if pageIndex == 0 {
            coverPage
        } else if pageIndex <= fable.pages.count {
            readingPage(fable.pages[pageIndex - 1])
        } else {
            moralPage
        }
    }

    private var coverPage: some View {
        VStack(spacing: 18) {
            Text(fable.cover).font(.system(size: 100))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            Text(fable.title)
                .font(.system(size: 36, weight: .black, design: .serif))
                .tracking(8)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Theme.ink.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text("共 \(fable.pages.count) 页 · 向右滑动翻页")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.45))
                .clipShape(Capsule())
        }
        .transition(.opacity)
        .id("cover-\(pageIndex)")
    }

    private func readingPage(_ page: FablePage) -> some View {
        VStack {
            Spacer()
            // 文字卡片，压在画面下半部
            VStack(alignment: .leading, spacing: 10) {
                FlowLayout(spacing: 2) {
                    ForEach(Array(page.text.enumerated()), id: \.offset) { _, ch in
                        charChip(String(ch))
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [
                    Color.white.opacity(0.94),
                    Color(red: 1.00, green: 0.97, blue: 0.90).opacity(0.94)
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(.bottom, 40)
        }
        .transition(.opacity)
        .id("page-\(pageIndex)")
    }

    private var moralPage: some View {
        VStack(spacing: 20) {
            Text("📖").font(.system(size: 72))
                .shadow(color: .black.opacity(0.2), radius: 4)

            VStack(spacing: 10) {
                Text("寓 意")
                    .font(.system(size: 14, weight: .black, design: .serif))
                    .tracking(8)
                    .foregroundColor(Theme.accent)

                FlowLayout(spacing: 2) {
                    ForEach(Array(fable.moral.enumerated()), id: \.offset) { _, ch in
                        charChip(String(ch))
                    }
                }
                .frame(maxWidth: 340)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.94))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.3), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            if !app.storiesRead.contains(fable.id) {
                Button { finishReading() } label: {
                    Text("✓ 读完啦")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(4)
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("已读过").font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.85))
                .clipShape(Capsule())
            }
        }
        .transition(.opacity)
        .id("end-\(pageIndex)")
    }

    // MARK: Char chip

    private func charChip(_ c: String) -> some View {
        let charID = "kid:\(c)"
        let isLearned = app.doneStrokeIDs.contains(charID)
        let isPunct = c == "，" || c == "。" || c == "！" || c == "？"
            || c == " " || c == "、" || c == "!" || c == "?" || c == "："
        return Text(c)
            .font(.system(size: 22, weight: isLearned ? .bold : .regular, design: .serif))
            .foregroundColor(isPunct ? Theme.muted : (isLearned ? Theme.accent : Theme.ink))
            .padding(.horizontal, isPunct ? 0 : 3)
            .padding(.vertical, 2)
            .background(isLearned ? Theme.highlight.opacity(0.75) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .contentShape(Rectangle())
            .onTapGesture {
                if !isPunct { speakChar(c) }
            }
    }

    private func speakChar(_ c: String) {
        let charID = "kid:\(c)"
        if let meta = KidsCharacters.metaFor(charID) {
            Speaker.shared.speak("\(c) \(meta.meaning)")
        } else {
            Speaker.shared.speak(c)
        }
        Sound.success.play()
    }

    // MARK: Controls

    private var pageControls: some View {
        HStack(spacing: 14) {
            Button { prevPage() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(pageIndex == 0 ? Theme.muted : Theme.ink)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }
            .disabled(pageIndex == 0)

            // dot indicator
            HStack(spacing: 5) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Circle()
                        .fill(i == pageIndex ? Theme.accent : Color.white.opacity(0.65))
                        .frame(width: i == pageIndex ? 9 : 6,
                               height: i == pageIndex ? 9 : 6)
                }
            }

            Button { nextPage() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(pageIndex == totalPages - 1 ? Theme.muted : Theme.ink)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }
            .disabled(pageIndex == totalPages - 1)
        }
        .padding(.bottom, 4)
    }

    private func nextPage() {
        guard pageIndex < totalPages - 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) { pageIndex += 1 }
        Sound.success.play()
    }

    private func prevPage() {
        guard pageIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.25)) { pageIndex -= 1 }
        Sound.success.play()
    }

    private func finishReading() {
        app.markStoryRead(fable.id)
        Sound.sticker.play()
        Speaker.shared.speak("读完啦，真棒！")
        withAnimation(.spring()) { celebrate = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { celebrate = false }
            dismiss()
        }
    }

    // MARK: Celebrate overlay

    private var congratsOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 10) {
                Text("🎉").font(.system(size: 80))
                Text("读完啦！").font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("又认识了许多字")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(30)
            .background(Color.black.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .transition(.opacity)
    }
}

// MARK: - FableSceneBackground (scene renderer)

struct FableSceneBackground: View {
    let scene: FableScene
    var thumbnail: Bool = false   // true → use simple gradient (书架缩略图用)

    var body: some View {
        if thumbnail {
            ThumbnailScene(scene: scene)
        } else {
            switch scene {
            case .forest: ImageBG("scene_forest")
            case .hills:  ImageBG("scene_hills")
            case .castle: ImageBG("scene_castle")
            case .desert: ImageBG("scene_desert")
            case .night:  NightScene()
            case .rain:   RainScene()
            case .snow:   SnowScene()
            case .home:   HomeScene()
            case .pond:   PondScene()
            case .sunrise:SunriseScene()
            }
        }
    }
}

// 缩略图版本：避免 GeometryReader + random 范围在 90pt 小框里崩溃
private struct ThumbnailScene: View {
    let scene: FableScene
    var body: some View {
        Group {
            switch scene {
            case .forest:
                LinearGradient(colors: [Color(red: 0.80, green: 0.92, blue: 0.95),
                                        Color(red: 0.54, green: 0.72, blue: 0.48)],
                               startPoint: .top, endPoint: .bottom)
            case .hills:
                LinearGradient(colors: [Color(red: 0.80, green: 0.92, blue: 0.95),
                                        Color(red: 0.70, green: 0.86, blue: 0.60)],
                               startPoint: .top, endPoint: .bottom)
            case .castle:
                LinearGradient(colors: [Color(red: 0.80, green: 0.92, blue: 0.95),
                                        Color(red: 0.72, green: 0.82, blue: 0.60)],
                               startPoint: .top, endPoint: .bottom)
            case .desert:
                LinearGradient(colors: [Color(red: 0.85, green: 0.93, blue: 0.98),
                                        Color(red: 0.88, green: 0.80, blue: 0.62)],
                               startPoint: .top, endPoint: .bottom)
            case .night:
                LinearGradient(colors: [Color(red: 0.09, green: 0.10, blue: 0.28),
                                        Color(red: 0.30, green: 0.31, blue: 0.55)],
                               startPoint: .top, endPoint: .bottom)
            case .rain:
                LinearGradient(colors: [Color(red: 0.48, green: 0.54, blue: 0.62),
                                        Color(red: 0.72, green: 0.76, blue: 0.80)],
                               startPoint: .top, endPoint: .bottom)
            case .snow:
                LinearGradient(colors: [Color(red: 0.85, green: 0.89, blue: 0.95),
                                        Color(red: 0.96, green: 0.97, blue: 0.99)],
                               startPoint: .top, endPoint: .bottom)
            case .home:
                LinearGradient(colors: [Color(red: 1.00, green: 0.94, blue: 0.82),
                                        Color(red: 0.97, green: 0.86, blue: 0.70)],
                               startPoint: .top, endPoint: .bottom)
            case .pond:
                LinearGradient(colors: [Color(red: 0.72, green: 0.88, blue: 0.95),
                                        Color(red: 0.42, green: 0.66, blue: 0.82)],
                               startPoint: .top, endPoint: .bottom)
            case .sunrise:
                LinearGradient(colors: [Color(red: 1.00, green: 0.75, blue: 0.48),
                                        Color(red: 1.00, green: 0.93, blue: 0.75)],
                               startPoint: .top, endPoint: .bottom)
            }
        }
    }
}

// MARK: - Image background (Kenney PNGs)

private struct ImageBG: View {
    let name: String
    init(_ n: String) { self.name = n }
    var body: some View {
        GeometryReader { geo in
            Image(name, bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
}

// MARK: - SwiftUI-drawn scenes

private struct NightScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.09, green: 0.10, blue: 0.28),
                Color(red: 0.18, green: 0.22, blue: 0.45),
                Color(red: 0.30, green: 0.31, blue: 0.55)
            ], startPoint: .top, endPoint: .bottom)

            // stars
            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                let h = max(geo.size.height * 0.65, 1)
                ForEach(0..<40, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(.random(in: 0.3...0.9)))
                        .frame(width: .random(in: 1.5...3.5))
                        .position(x: .random(in: 0...w), y: .random(in: 0...h))
                }
            }

            // moon
            GeometryReader { geo in
                Circle()
                    .fill(Color(red: 1.0, green: 0.96, blue: 0.80))
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.yellow.opacity(0.4), radius: 20)
                    .position(x: geo.size.width - 90, y: 120)
            }

            // dark hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.82))
                    p.addCurve(to: .init(x: w * 0.5, y: h * 0.72),
                               control1: .init(x: w * 0.2, y: h * 0.78),
                               control2: .init(x: w * 0.35, y: h * 0.68))
                    p.addCurve(to: .init(x: w, y: h * 0.80),
                               control1: .init(x: w * 0.70, y: h * 0.78),
                               control2: .init(x: w * 0.88, y: h * 0.72))
                    p.addLine(to: .init(x: w, y: h))
                    p.addLine(to: .init(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.10, green: 0.13, blue: 0.28))
            }
        }
    }
}

private struct RainScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.55, green: 0.60, blue: 0.68),
                Color(red: 0.72, green: 0.76, blue: 0.80)
            ], startPoint: .top, endPoint: .bottom)

            // dark clouds
            GeometryReader { geo in
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(Color(red: 0.35, green: 0.38, blue: 0.45).opacity(0.85))
                        .frame(width: 180, height: 50)
                        .position(
                            x: CGFloat(i) * (max(geo.size.width, 1) / 3) + 40,
                            y: 60 + CGFloat(i) * 14
                        )
                }
            }

            // rain streaks
            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                let h = max(geo.size.height, 1)
                let yHi = max(h * 0.85, 30)
                let yLo = min(20, yHi - 1)
                ForEach(0..<50, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 1.5, height: 14)
                        .rotationEffect(.degrees(15))
                        .position(
                            x: .random(in: 0...w),
                            y: .random(in: yLo...yHi)
                        )
                }
            }

            // green hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.78))
                    p.addCurve(to: .init(x: w, y: h * 0.80),
                               control1: .init(x: w * 0.35, y: h * 0.72),
                               control2: .init(x: w * 0.65, y: h * 0.75))
                    p.addLine(to: .init(x: w, y: h))
                    p.addLine(to: .init(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.50, green: 0.64, blue: 0.48))
            }
        }
    }
}

private struct SnowScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.85, green: 0.89, blue: 0.95),
                Color(red: 0.95, green: 0.96, blue: 0.99)
            ], startPoint: .top, endPoint: .bottom)

            // snowflakes
            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                let h = max(geo.size.height * 0.85, 1)
                ForEach(0..<60, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: .random(in: 3...7))
                        .position(x: .random(in: 0...w), y: .random(in: 0...h))
                        .shadow(color: Color.black.opacity(0.06), radius: 1)
                }
            }

            // snowy hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.70))
                    p.addCurve(to: .init(x: w * 0.5, y: h * 0.62),
                               control1: .init(x: w * 0.2, y: h * 0.66),
                               control2: .init(x: w * 0.35, y: h * 0.58))
                    p.addCurve(to: .init(x: w, y: h * 0.72),
                               control1: .init(x: w * 0.70, y: h * 0.66),
                               control2: .init(x: w * 0.88, y: h * 0.62))
                    p.addLine(to: .init(x: w, y: h))
                    p.addLine(to: .init(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3)
            }

            // bare tree
            GeometryReader { geo in
                Text("🌲").font(.system(size: 80))
                    .position(x: geo.size.width * 0.25, y: geo.size.height * 0.55)
                Text("🌲").font(.system(size: 60))
                    .position(x: geo.size.width * 0.75, y: geo.size.height * 0.62)
            }
        }
    }
}

private struct HomeScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 1.00, green: 0.94, blue: 0.82),
                Color(red: 0.97, green: 0.86, blue: 0.70)
            ], startPoint: .top, endPoint: .bottom)

            // wooden floor
            GeometryReader { geo in
                Rectangle()
                    .fill(LinearGradient(colors: [
                        Color(red: 0.78, green: 0.60, blue: 0.40),
                        Color(red: 0.66, green: 0.48, blue: 0.30)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: geo.size.width, height: geo.size.height * 0.30)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.85)
            }

            // window
            GeometryReader { geo in
                let ww: CGFloat = 140, wh: CGFloat = 120
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(colors: [
                        Color(red: 0.70, green: 0.86, blue: 0.95),
                        Color(red: 0.85, green: 0.92, blue: 0.98)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: ww, height: wh)
                    .overlay(
                        ZStack {
                            Rectangle().fill(Color(red: 0.55, green: 0.40, blue: 0.26))
                                .frame(width: ww, height: 5)
                            Rectangle().fill(Color(red: 0.55, green: 0.40, blue: 0.26))
                                .frame(width: 5, height: wh)
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(red: 0.45, green: 0.30, blue: 0.18), lineWidth: 4))
                    .position(x: geo.size.width * 0.30, y: geo.size.height * 0.38)
            }

            // potted plant / decoration
            GeometryReader { geo in
                Text("🪴").font(.system(size: 70))
                    .position(x: geo.size.width * 0.75, y: geo.size.height * 0.55)
            }
        }
    }
}

private struct PondScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.72, green: 0.88, blue: 0.95),
                Color(red: 0.88, green: 0.94, blue: 0.98)
            ], startPoint: .top, endPoint: .bottom)

            // distant hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.55))
                    p.addCurve(to: .init(x: w, y: h * 0.55),
                               control1: .init(x: w * 0.35, y: h * 0.48),
                               control2: .init(x: w * 0.65, y: h * 0.50))
                    p.addLine(to: .init(x: w, y: h * 0.62))
                    p.addLine(to: .init(x: 0, y: h * 0.62))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.68, green: 0.82, blue: 0.82))
            }

            // water
            GeometryReader { geo in
                Rectangle()
                    .fill(LinearGradient(colors: [
                        Color(red: 0.48, green: 0.74, blue: 0.88),
                        Color(red: 0.32, green: 0.56, blue: 0.76)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: geo.size.width, height: geo.size.height * 0.45)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.80)
            }

            // ripples
            GeometryReader { geo in
                ForEach(0..<4, id: \.self) { i in
                    Ellipse()
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                        .frame(width: 80 + CGFloat(i) * 20, height: 12)
                        .position(x: geo.size.width * 0.3 + CGFloat(i) * 30,
                                  y: geo.size.height * 0.75 + CGFloat(i) * 10)
                }
            }

            // lotus / fish
            GeometryReader { geo in
                Text("🪷").font(.system(size: 46))
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.68)
            }
        }
    }
}

private struct SunriseScene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.96, green: 0.67, blue: 0.43),
                Color(red: 1.00, green: 0.82, blue: 0.55),
                Color(red: 1.00, green: 0.93, blue: 0.75)
            ], startPoint: .top, endPoint: .bottom)

            // sun
            GeometryReader { geo in
                Circle()
                    .fill(LinearGradient(colors: [
                        Color(red: 1.00, green: 0.95, blue: 0.55),
                        Color(red: 1.00, green: 0.75, blue: 0.30)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.orange.opacity(0.5), radius: 40)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.58)
            }

            // back hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.70))
                    p.addCurve(to: .init(x: w, y: h * 0.72),
                               control1: .init(x: w * 0.3, y: h * 0.60),
                               control2: .init(x: w * 0.7, y: h * 0.62))
                    p.addLine(to: .init(x: w, y: h))
                    p.addLine(to: .init(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.42, green: 0.32, blue: 0.35))
            }

            // front hills
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    p.move(to: .init(x: 0, y: h * 0.82))
                    p.addCurve(to: .init(x: w, y: h * 0.80),
                               control1: .init(x: w * 0.3, y: h * 0.72),
                               control2: .init(x: w * 0.7, y: h * 0.76))
                    p.addLine(to: .init(x: w, y: h))
                    p.addLine(to: .init(x: 0, y: h))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.22, green: 0.16, blue: 0.20))
            }
        }
    }
}
