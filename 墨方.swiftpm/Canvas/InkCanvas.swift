import SwiftUI
import PencilKit
import UIKit

/// 用户书写的一笔（归一化 0-1 坐标）
struct UserStroke: Identifiable {
    let id = UUID()
    var points: [UserPoint]
    var startTime: TimeInterval
    var endTime: TimeInterval
}

struct UserPoint {
    let x: CGFloat        // 0-1
    let y: CGFloat        // 0-1
    let pressure: CGFloat // 0-1
    let timeOffset: TimeInterval
}

// ──────────────────────────────────────────────────────────────────
// MARK: - PencilKit 封装
// ──────────────────────────────────────────────────────────────────

struct InkCanvasView: UIViewRepresentable {
    @Binding var strokes: [UserStroke]
    var canvasSize: CGSize
    var onStrokeEnd: ((UserStroke) -> Void)? = nil
    /// 是否允许手指书写（iPad 上可关闭只让 Pencil 写）
    var allowsFinger: Bool = true

    func makeUIView(context: Context) -> PKCanvasView {
        let v = PKCanvasView()
        v.backgroundColor = .clear
        v.isOpaque = false
        v.drawingPolicy = allowsFinger ? .anyInput : .pencilOnly
        v.tool = PKInkingTool(.pen, color: UIColor.black, width: 8)
        v.delegate = context.coordinator
        v.maximumZoomScale = 1
        v.minimumZoomScale = 1
        v.bouncesZoom = false
        v.alwaysBounceVertical = false
        v.alwaysBounceHorizontal = false
        return v
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawingPolicy = allowsFinger ? .anyInput : .pencilOnly
        // 外部要求清空
        if strokes.isEmpty && !uiView.drawing.strokes.isEmpty {
            uiView.drawing = PKDrawing()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: InkCanvasView
        init(_ p: InkCanvasView) { self.parent = p }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // 只取最新一笔
            let pkStrokes = canvasView.drawing.strokes
            guard pkStrokes.count > parent.strokes.count else { return }
            let size = canvasView.bounds.size
            guard size.width > 0, size.height > 0 else { return }

            for i in parent.strokes.count ..< pkStrokes.count {
                let pk = pkStrokes[i]
                let stroke = Self.normalize(pk, size: size)
                DispatchQueue.main.async {
                    self.parent.strokes.append(stroke)
                    self.parent.onStrokeEnd?(stroke)
                }
            }
        }

        private static func normalize(_ pk: PKStroke, size: CGSize) -> UserStroke {
            var points: [UserPoint] = []
            var tMin: TimeInterval = .greatestFiniteMagnitude
            var tMax: TimeInterval = -.greatestFiniteMagnitude
            pk.path.forEach { p in
                let loc = p.location
                let up = UserPoint(
                    x: loc.x / max(1, size.width),
                    y: loc.y / max(1, size.height),
                    pressure: CGFloat(p.force),
                    timeOffset: p.timeOffset
                )
                points.append(up)
                tMin = min(tMin, p.timeOffset)
                tMax = max(tMax, p.timeOffset)
            }
            return UserStroke(
                points: points,
                startTime: tMin == .greatestFiniteMagnitude ? 0 : tMin,
                endTime: tMax == -.greatestFiniteMagnitude ? 0 : tMax
            )
        }
    }

    // ─── 外部操作 ────────────────────────────────────────────────────
    static func clear(strokes: inout [UserStroke]) {
        strokes.removeAll()
    }

    static func undo(strokes: inout [UserStroke]) {
        if !strokes.isEmpty { strokes.removeLast() }
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: - 米字格
// ──────────────────────────────────────────────────────────────────

struct RiceGrid: View {
    var color: Color = Theme.accent.opacity(0.45)
    var dashColor: Color = Theme.accent.opacity(0.25)
    var body: some View {
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
            ctx.stroke(Path(rect), with: .color(color), lineWidth: 1.5)
            // 十字
            var cross = Path()
            cross.move(to: CGPoint(x: size.width / 2, y: 2))
            cross.addLine(to: CGPoint(x: size.width / 2, y: size.height - 2))
            cross.move(to: CGPoint(x: 2, y: size.height / 2))
            cross.addLine(to: CGPoint(x: size.width - 2, y: size.height / 2))
            ctx.stroke(cross, with: .color(color), lineWidth: 1)
            // 对角虚线
            var diag = Path()
            diag.move(to: CGPoint(x: 2, y: 2))
            diag.addLine(to: CGPoint(x: size.width - 2, y: size.height - 2))
            diag.move(to: CGPoint(x: size.width - 2, y: 2))
            diag.addLine(to: CGPoint(x: 2, y: size.height - 2))
            ctx.stroke(
                diag,
                with: .color(dashColor),
                style: StrokeStyle(lineWidth: 0.8, dash: [4, 4])
            )
        }
        .allowsHitTesting(false)
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: - 描红底纹 / 标准笔画示意
// ──────────────────────────────────────────────────────────────────

struct GuideStrokeView: View {
    let strokes: [StrokeSpec]
    /// 透明度：描红模式 0.18，临摹模式 0.08
    var opacity: Double = 0.18
    /// 是否显示方向箭头（描红模式 true）
    var showArrow: Bool = true

    var body: some View {
        Canvas { ctx, size in
            for s in strokes {
                drawStroke(s, in: &ctx, size: size)
                if showArrow { drawArrow(s, in: &ctx, size: size) }
            }
        }
        .allowsHitTesting(false)
    }

    private func drawStroke(_ spec: StrokeSpec, in ctx: inout GraphicsContext, size: CGSize) {
        let pts = StrokePath.sample(spec.points, count: 48).map {
            CGPoint(x: $0.x * size.width, y: $0.y * size.height)
        }
        guard pts.count >= 2 else { return }
        // 用变粗细的分段画笔模拟毛笔头
        let minDim = min(size.width, size.height)
        let wStart = spec.widthStart * minDim
        let wEnd = spec.widthEnd * minDim
        for i in 1..<pts.count {
            let t = CGFloat(i) / CGFloat(pts.count - 1)
            let w = wStart + (wEnd - wStart) * t
            var p = Path()
            p.move(to: pts[i - 1])
            p.addLine(to: pts[i])
            ctx.stroke(
                p,
                with: .color(Color.black.opacity(opacity)),
                style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round)
            )
        }
    }

    private func drawArrow(_ spec: StrokeSpec, in ctx: inout GraphicsContext, size: CGSize) {
        guard spec.points.count >= 2 else { return }
        let pts = spec.points.map {
            CGPoint(x: $0.x * size.width, y: $0.y * size.height)
        }
        let last = pts.last!
        let prev = pts[pts.count - 2]
        let ang = atan2(last.y - prev.y, last.x - prev.x)
        let len: CGFloat = 18
        let wing: CGFloat = 8

        let tip = last
        let p1 = CGPoint(
            x: tip.x - len * cos(ang) + wing * cos(ang + .pi / 2),
            y: tip.y - len * sin(ang) + wing * sin(ang + .pi / 2)
        )
        let p2 = CGPoint(
            x: tip.x - len * cos(ang) - wing * cos(ang + .pi / 2),
            y: tip.y - len * sin(ang) - wing * sin(ang + .pi / 2)
        )
        var path = Path()
        path.move(to: tip)
        path.addLine(to: p1)
        path.addLine(to: p2)
        path.closeSubpath()
        ctx.fill(path, with: .color(Theme.accent))
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: - 完整画布（组合 grid + guide + PKCanvasView）
// ──────────────────────────────────────────────────────────────────

enum PracticeMode: String, CaseIterable, Identifiable {
    case watch       // 观：看动画
    case guided      // 逐笔描：只显示当前目标笔画，写对一笔才出现下一笔（幼儿友好）
    case trace       // 描：显示全部底纹覆写
    case copy        // 临：有范字，独立书写
    case blank       // 背：无范字

    var id: String { rawValue }
    var label: String {
        switch self {
        case .watch:  return "观"
        case .guided: return "跟"
        case .trace:  return "描"
        case .copy:   return "临"
        case .blank:  return "背"
        }
    }
    var hint: String {
        switch self {
        case .watch:  return "观察笔顺动画、看标准书写方向"
        case .guided: return "跟着提示一笔一笔写，写对了再出现下一笔"
        case .trace:  return "灰色底纹上覆写，箭头指引笔走方向"
        case .copy:   return "旁边有范字，在格子里独立写一遍"
        case .blank:  return "格子里没有范字，凭记忆书写"
        }
    }

    /// 幼儿模式下应显示的模式（简化：只有「跟」和「背」）
    static let kidModes: [PracticeMode] = [.guided, .blank]
    /// 成人模式下应显示的模式
    static let adultModes: [PracticeMode] = [.watch, .trace, .copy, .blank]
}

struct PracticeCanvas: View {
    let character: CharacterDef
    let mode: PracticeMode
    @Binding var strokes: [UserStroke]
    var onStrokeEnd: ((UserStroke) -> Void)? = nil

    /// 逐笔描摹模式下：当前已完成的笔画数（0..character.strokes.count）
    var guidedCompletedCount: Int = 0
    /// 逐笔描摹模式下：已完成笔画的标准形状（用于"变黑"展示）
    var guidedShowStandardInk: Bool = true
    /// 幼儿模式（画布会更柔和）
    var isKidMode: Bool = false

    // 仅在 watch 模式下驱动笔画动画
    @State private var watchProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                RiceGrid(
                    color: isKidMode ? Theme.accent.opacity(0.6) : Theme.accent.opacity(0.45),
                    dashColor: isKidMode ? Theme.accent.opacity(0.35) : Theme.accent.opacity(0.25)
                )

                guideLayer

                if mode == .watch {
                    WatchAnimationLayer(strokes: character.strokes, progress: watchProgress)
                }

                InkCanvasView(
                    strokes: $strokes,
                    canvasSize: geo.size,
                    onStrokeEnd: onStrokeEnd,
                    allowsFinger: true
                )
                .allowsHitTesting(mode != .watch)
            }
            .clipShape(RoundedRectangle(cornerRadius: isKidMode ? 20 : 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: isKidMode ? 20 : 12, style: .continuous)
                    .stroke(isKidMode ? Theme.accent.opacity(0.5) : Theme.line,
                            lineWidth: isKidMode ? 3 : 1)
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: mode) { _, new in
            if new == .watch { runWatchAnimation() }
        }
        .onAppear {
            if mode == .watch { runWatchAnimation() }
        }
    }

    @ViewBuilder private var guideLayer: some View {
        switch mode {
        case .watch, .trace:
            // 优先用 HanziPool 真实 SVG 作为底图 + 箭头提示
            if let hanzi = HanziPool.find(character.glyph) {
                ZStack {
                    HanziStrokeView(hanzi: hanzi, progress: 1.0,
                                    fill: Color.black.opacity(0.20))
                        .padding(14)
                    GuideStrokeView(strokes: character.strokes, opacity: 0.0, showArrow: true)
                }
            } else {
                GuideStrokeView(strokes: character.strokes, opacity: 0.20, showArrow: true)
            }
        case .guided:
            if let hanzi = HanziPool.find(character.glyph) {
                // 真实 SVG 渲染已完成笔画 + 下一笔的 hint
                HanziGuidedLayer(
                    hanzi: hanzi,
                    completedCount: guidedCompletedCount,
                    fallbackStrokes: character.strokes
                )
            } else {
                GuidedTraceLayer(
                    allStrokes: character.strokes,
                    completedCount: guidedCompletedCount,
                    showStandardInk: guidedShowStandardInk
                )
            }
        case .copy:
            if let hanzi = HanziPool.find(character.glyph) {
                HanziStrokeView(hanzi: hanzi, progress: 1.0,
                                fill: Color.black.opacity(0.08))
                    .padding(14)
            } else {
                GuideStrokeView(strokes: character.strokes, opacity: 0.08, showArrow: false)
            }
        case .blank:
            EmptyView()
        }
    }

    private func runWatchAnimation() {
        watchProgress = 0
        withAnimation(.easeInOut(duration: 2.4)) { watchProgress = 1.0 }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 逐笔描摹引导层
// ─────────────────────────────────────────────────────────────────
//
// 显示规则：
//   已完成的笔画 → 用墨黑色（0.85 透明度）显示，给小朋友成就感
//   当前目标笔画 → 灰色 + 方向箭头 + 起笔红色圆点 + 终笔绿色圆点
//   未来笔画 → 完全不显示

struct GuidedTraceLayer: View {
    let allStrokes: [StrokeSpec]
    let completedCount: Int
    let showStandardInk: Bool

    var body: some View {
        Canvas { ctx, size in
            // 1) 已完成的笔画 → 墨黑色
            if showStandardInk {
                for i in 0..<min(completedCount, allStrokes.count) {
                    drawStroke(allStrokes[i], in: &ctx, size: size,
                               color: Color.black.opacity(0.85))
                }
            }
            // 2) 当前目标笔画 → 灰色 + 提示
            if completedCount < allStrokes.count {
                let current = allStrokes[completedCount]
                drawStroke(current, in: &ctx, size: size,
                           color: Color.gray.opacity(0.35))
                drawArrow(current, in: &ctx, size: size)
                drawStartEndMarkers(current, in: &ctx, size: size)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawStroke(_ spec: StrokeSpec, in ctx: inout GraphicsContext,
                            size: CGSize, color: Color) {
        let pts = StrokePath.sample(spec.points, count: 48).map {
            CGPoint(x: $0.x * size.width, y: $0.y * size.height)
        }
        guard pts.count >= 2 else { return }
        let minDim = min(size.width, size.height)
        let wStart = spec.widthStart * minDim
        let wEnd = spec.widthEnd * minDim
        for i in 1..<pts.count {
            let t = CGFloat(i) / CGFloat(pts.count - 1)
            let w = wStart + (wEnd - wStart) * t
            var p = Path()
            p.move(to: pts[i - 1])
            p.addLine(to: pts[i])
            ctx.stroke(
                p,
                with: .color(color),
                style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round)
            )
        }
    }

    private func drawArrow(_ spec: StrokeSpec, in ctx: inout GraphicsContext, size: CGSize) {
        guard spec.points.count >= 2 else { return }
        let pts = spec.points.map {
            CGPoint(x: $0.x * size.width, y: $0.y * size.height)
        }
        let last = pts.last!
        let prev = pts[pts.count - 2]
        let ang = atan2(last.y - prev.y, last.x - prev.x)
        let len: CGFloat = 22
        let wing: CGFloat = 10
        let p1 = CGPoint(
            x: last.x - len * cos(ang) + wing * cos(ang + .pi / 2),
            y: last.y - len * sin(ang) + wing * sin(ang + .pi / 2)
        )
        let p2 = CGPoint(
            x: last.x - len * cos(ang) - wing * cos(ang + .pi / 2),
            y: last.y - len * sin(ang) - wing * sin(ang + .pi / 2)
        )
        var path = Path()
        path.move(to: last)
        path.addLine(to: p1)
        path.addLine(to: p2)
        path.closeSubpath()
        ctx.fill(path, with: .color(Theme.accent))
    }

    private func drawStartEndMarkers(_ spec: StrokeSpec, in ctx: inout GraphicsContext, size: CGSize) {
        guard let first = spec.points.first, let last = spec.points.last else { return }
        let start = CGPoint(x: first.x * size.width, y: first.y * size.height)
        let end = CGPoint(x: last.x * size.width, y: last.y * size.height)

        // 起笔：红色圆圈（像交通灯的"起点"）
        let startCircle = Path(ellipseIn: CGRect(x: start.x - 9, y: start.y - 9, width: 18, height: 18))
        ctx.fill(startCircle, with: .color(Theme.accent))
        let startInner = Path(ellipseIn: CGRect(x: start.x - 4, y: start.y - 4, width: 8, height: 8))
        ctx.fill(startInner, with: .color(.white))

        // 终笔：绿色圆圈
        let endCircle = Path(ellipseIn: CGRect(x: end.x - 7, y: end.y - 7, width: 14, height: 14))
        ctx.stroke(endCircle,
                   with: .color(Color(red: 0.16, green: 0.62, blue: 0.36)),
                   lineWidth: 2)
    }
}

/// 观字模式的逐笔动画层
private struct WatchAnimationLayer: View {
    let strokes: [StrokeSpec]
    let progress: Double

    var body: some View {
        Canvas { ctx, size in
            let pts = strokes.flatMap { spec in
                StrokePath.sample(spec.points, count: 60).map { p in
                    (spec, CGPoint(x: p.x * size.width, y: p.y * size.height))
                }
            }
            let total = pts.count
            let cut = Int(Double(total) * progress)
            guard cut > 1 else { return }
            for i in 1..<cut {
                let (spec, p1) = pts[i - 1]
                let (_, p2) = pts[i]
                let t = CGFloat(i) / CGFloat(total)
                let minDim = min(size.width, size.height)
                let w = (spec.widthStart + (spec.widthEnd - spec.widthStart) * t) * minDim
                var path = Path()
                path.move(to: p1); path.addLine(to: p2)
                ctx.stroke(
                    path,
                    with: .color(Theme.ink),
                    style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - HanziPool-based guided trace（接真实 SVG 数据）
// ─────────────────────────────────────────────────────────────────
//
// 当 HanziPool 有该字时替代 GuidedTraceLayer：
//   - 已完成笔画：真实 SVG 填充墨黑色
//   - 当前目标笔画：灰色 SVG 半透明
//   - 起笔红色圆点 + 终笔绿色圈（用 medians 首尾点）
//   - 方向箭头（用 medians 末两点）

struct HanziGuidedLayer: View {
    let hanzi: HanziChar
    let completedCount: Int
    let fallbackStrokes: [StrokeSpec]   // 暂未使用，备份

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let padding: CGFloat = 14
            let drawSide = side - padding * 2
            let scale = drawSide / 1024
            let originX = (geo.size.width - drawSide) / 2
            let originY = (geo.size.height - drawSide) / 2

            ZStack {
                // 已完成笔画：真实 SVG 墨黑
                if completedCount > 0 {
                    HanziStrokeView(
                        hanzi: hanzi,
                        progress: Double(completedCount) / Double(max(1, hanzi.strokes.count)),
                        fill: Color.black.opacity(0.85)
                    )
                    .padding(padding)
                }

                // 当前目标笔画：灰色半透明 + 起终点 + 箭头
                if completedCount < hanzi.strokes.count {
                    currentStrokeGuide(
                        svgPath: hanzi.strokes[completedCount],
                        median: hanzi.medians?[safe: completedCount] ?? [],
                        originX: originX, originY: originY,
                        drawSide: drawSide, scale: scale
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func currentStrokeGuide(
        svgPath: String,
        median: [CGPoint],
        originX: CGFloat,
        originY: CGFloat,
        drawSide: CGFloat,
        scale: CGFloat
    ) -> some View {
        ZStack {
            // 1. 灰色半透明 SVG 笔画
            Canvas { ctx, _ in
                ctx.translateBy(x: originX, y: originY + drawSide)
                ctx.scaleBy(x: scale, y: -scale)
                let p = SVGPathParser.parse(svgPath)
                ctx.fill(p, with: .color(Color.gray.opacity(0.35)))
            }

            // 2. 起笔点 + 终笔圈 + 箭头（用 median 首尾点）
            if median.count >= 2,
               let first = median.first,
               let last = median.last {
                // 转换 1024-space 到视图坐标（Y 翻转）
                let startPt = CGPoint(
                    x: originX + first.x * scale,
                    y: originY + (1024 - first.y) * scale
                )
                let endPt = CGPoint(
                    x: originX + last.x * scale,
                    y: originY + (1024 - last.y) * scale
                )

                Canvas { ctx, _ in
                    // 起笔 · 红色实心圆
                    let startCircle = Path(ellipseIn: CGRect(
                        x: startPt.x - 9, y: startPt.y - 9, width: 18, height: 18
                    ))
                    ctx.fill(startCircle, with: .color(Theme.accent))
                    let startInner = Path(ellipseIn: CGRect(
                        x: startPt.x - 4, y: startPt.y - 4, width: 8, height: 8
                    ))
                    ctx.fill(startInner, with: .color(.white))

                    // 终笔 · 绿色圆圈
                    let endCircle = Path(ellipseIn: CGRect(
                        x: endPt.x - 7, y: endPt.y - 7, width: 14, height: 14
                    ))
                    ctx.stroke(
                        endCircle,
                        with: .color(Color(red: 0.16, green: 0.62, blue: 0.36)),
                        lineWidth: 2
                    )

                    // 箭头（指向终笔）
                    let ang = atan2(endPt.y - startPt.y, endPt.x - startPt.x)
                    let len: CGFloat = 22, wing: CGFloat = 10
                    let p1 = CGPoint(
                        x: endPt.x - len * cos(ang) + wing * cos(ang + .pi / 2),
                        y: endPt.y - len * sin(ang) + wing * sin(ang + .pi / 2)
                    )
                    let p2 = CGPoint(
                        x: endPt.x - len * cos(ang) - wing * cos(ang + .pi / 2),
                        y: endPt.y - len * sin(ang) - wing * sin(ang + .pi / 2)
                    )
                    var arrow = Path()
                    arrow.move(to: endPt)
                    arrow.addLine(to: p1)
                    arrow.addLine(to: p2)
                    arrow.closeSubpath()
                    ctx.fill(arrow, with: .color(Theme.accent))
                }
            }
        }
    }
}

// 安全下标
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
