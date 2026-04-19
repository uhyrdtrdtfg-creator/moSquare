import SwiftUI

struct GrowthTreeView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showBreeze: Bool = false

    enum Stage: Int, CaseIterable {
        case seed = 0, sprout, small, large, fruit

        var name: String  { ["种子","小苗","小树","大树","果树"][rawValue] }
        var emoji: String { ["🌱","🌿","🌳","🌲","🍎"][rawValue] }
        var minMastered: Int { [0,5,15,30,50][rawValue] }
    }

    var masteredCount: Int {
        let kidDone = app.doneStrokeIDs.filter { $0.hasPrefix("kid:") }.count
        let composites = app.compositesLearned.count
        return kidDone + composites
    }

    var stage: Stage {
        let n = masteredCount
        if n >= 50 { return .fruit }
        if n >= 30 { return .large }
        if n >= 15 { return .small }
        if n >= 5  { return .sprout }
        return .seed
    }

    var progressToNext: Double {
        let thresholds = [0, 5, 15, 30, 50]
        let i = stage.rawValue
        if i >= thresholds.count - 1 { return 1.0 }
        let lo = thresholds[i]
        let hi = thresholds[i + 1]
        return min(1, max(0, Double(masteredCount - lo) / Double(hi - lo)))
    }

    var leafCount: Int { min(masteredCount * 2, 36) }
    var fruitCount: Int { max(0, min(8, (masteredCount - 30) / 3)) }
    var flowerCount: Int { max(0, min(6, (masteredCount - 15) / 4)) }

    var body: some View {
        ZStack {
            skyBackground
                .ignoresSafeArea()
            VStack(spacing: 12) {
                topBar
                stageInfo
                Spacer(minLength: 0)
                treeArea
                Spacer(minLength: 0)
                progressSection
                encourageText
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .onAppear {
            Speaker.shared.speak("你已经掌握 \(masteredCount) 个字啦，真棒!")
            animateBreeze()
        }
    }

    // MARK: - Sky Background

    var skyBackground: some View {
        LinearGradient(colors: [
            Color(red: 0.70, green: 0.86, blue: 0.96),
            Color(red: 0.90, green: 0.94, blue: 0.85),
            Color(red: 0.75, green: 0.88, blue: 0.65),
        ], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Top Bar

    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.ink.opacity(0.7))
            }
            Spacer()
            Text("🌱 我的小树")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(Theme.ink)
            Spacer()
            Text("掌握 \(masteredCount) 字")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.accent)
                .clipShape(Capsule())
        }
    }

    // MARK: - Stage Info

    var stageInfo: some View {
        HStack(spacing: 8) {
            Text(stage.emoji).font(.system(size: 32))
            Text(stage.name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .tracking(4)
                .foregroundColor(Theme.ink)
        }
    }

    // MARK: - Tree Area

    var treeArea: some View {
        GeometryReader { geo in
            ZStack {
                // sun
                Text("☀️")
                    .font(.system(size: 40))
                    .position(x: geo.size.width * 0.85, y: 40)

                // cloud
                Text("☁️")
                    .font(.system(size: 32))
                    .position(x: geo.size.width * 0.20, y: 60)
                    .offset(x: showBreeze ? 20 : 0)

                // tree
                treeVisual(geo: geo)

                // ground
                Ellipse()
                    .fill(Color(red: 0.62, green: 0.77, blue: 0.52))
                    .frame(width: geo.size.width * 0.9, height: 30)
                    .position(x: geo.size.width / 2, y: geo.size.height - 20)
            }
        }
        .frame(height: 380)
    }

    func treeVisual(geo: GeometryProxy) -> some View {
        let cx = geo.size.width / 2
        let baseY = geo.size.height - 35

        let trunkH: CGFloat = [20, 40, 90, 130, 150][stage.rawValue]
        let trunkW: CGFloat = [8, 14, 28, 36, 40][stage.rawValue]
        let canopyR: CGFloat = [15, 30, 70, 100, 120][stage.rawValue]

        return ZStack {
            // trunk
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.55, green: 0.35, blue: 0.20))
                .frame(width: trunkW, height: trunkH)
                .position(x: cx, y: baseY - trunkH / 2)

            if stage == .seed {
                // little sprout on top of a tiny stem
                Text("🌱")
                    .font(.system(size: 48))
                    .position(x: cx, y: baseY - trunkH)
            } else {
                // canopy disc
                Circle()
                    .fill(Color(red: 0.40, green: 0.72, blue: 0.40))
                    .frame(width: canopyR * 2, height: canopyR * 2)
                    .position(x: cx, y: baseY - trunkH - canopyR)

                // leaves scattered around canopy border
                ForEach(0..<leafCount, id: \.self) { i in
                    let angle = Double(i) / Double(max(1, leafCount)) * 2 * .pi
                    let radius = canopyR * 0.85
                    Text("🍃")
                        .font(.system(size: 18))
                        .position(
                            x: cx + CGFloat(cos(angle)) * radius,
                            y: baseY - trunkH - canopyR + CGFloat(sin(angle)) * radius
                        )
                        .rotationEffect(.degrees(showBreeze ? 5 : 0))
                        .animation(
                            .easeInOut(duration: 2).repeatForever().delay(Double(i) * 0.03),
                            value: showBreeze
                        )
                }

                // fruits on fruit stage
                if stage == .fruit {
                    ForEach(0..<fruitCount, id: \.self) { i in
                        let angle = Double(i) / Double(max(1, fruitCount)) * 2 * .pi + 0.2
                        Text("🍎")
                            .font(.system(size: 22))
                            .position(
                                x: cx + CGFloat(cos(angle)) * (canopyR * 0.6),
                                y: baseY - trunkH - canopyR + CGFloat(sin(angle)) * (canopyR * 0.6)
                            )
                    }
                }

                // flowers on large / fruit stages
                if stage == .large || stage == .fruit {
                    ForEach(0..<flowerCount, id: \.self) { i in
                        let angle = Double(i) / Double(max(1, flowerCount)) * 2 * .pi + 0.5
                        Text("🌸")
                            .font(.system(size: 18))
                            .position(
                                x: cx + CGFloat(cos(angle)) * (canopyR * 0.7),
                                y: baseY - trunkH - canopyR + CGFloat(sin(angle)) * (canopyR * 0.7)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Progress

    @ViewBuilder
    var progressSection: some View {
        if let next = Stage(rawValue: stage.rawValue + 1) {
            VStack(spacing: 6) {
                HStack {
                    Text("下一阶段: \(next.emoji) \(next.name)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.ink)
                    Spacer()
                    Text("\(masteredCount) / \(next.minMastered)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(progressToNext), height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(12)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Text("🏆 已达最高阶段 · 果树!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.accent)
                .padding(12)
                .background(Color.white.opacity(0.7))
                .clipShape(Capsule())
        }
    }

    // MARK: - Encourage Text

    var encourageText: some View {
        let text: String = {
            switch stage {
            case .seed:   return "快来练字，帮小苗发芽吧!"
            case .sprout: return "小苗在长大，继续加油!"
            case .small:  return "你的小树抽芽啦!"
            case .large:  return "大树开花咯，好香!"
            case .fruit:  return "果树结果啦! 你好棒!"
            }
        }()
        return Text(text)
            .font(.system(size: 13, design: .rounded))
            .foregroundColor(Theme.muted)
    }

    // MARK: - Animation

    func animateBreeze() {
        withAnimation(.easeInOut(duration: 3).repeatForever()) {
            showBreeze = true
        }
    }
}
