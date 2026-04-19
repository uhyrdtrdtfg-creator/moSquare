import SwiftUI
import CoreGraphics

/// A Chinese character with its stroke data, sourced from the open-source
/// `hanzi-writer-data` project. Strokes are SVG path "d" strings using a
/// 1024×1024 canvas with a bottom-left origin (Y-up).
struct HanziChar: Equatable, Identifiable, Codable {
    /// Stable identifier — typically the glyph itself.
    let id: String
    /// The character, e.g. "月".
    let glyph: String
    /// Pinyin reading, e.g. "yuè".
    let pinyin: String
    /// Brief English meaning.
    let meaning: String
    /// SVG path "d" strings, one per stroke, in stroke order.
    let strokes: [String]
    /// Raw medians (flat [x, y] arrays, as stored in hanzi-writer-data JSON).
    /// Use `medians` computed property to get CGPoint form.
    private let mediansRaw: [[[Double]]]?

    /// Per-stroke centerline points (same 1024×1024 coord space).
    var medians: [[CGPoint]]? {
        mediansRaw?.map { stroke in
            stroke.map { pair in
                CGPoint(x: pair.count > 0 ? pair[0] : 0,
                        y: pair.count > 1 ? pair[1] : 0)
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, glyph, pinyin, meaning, strokes
        case mediansRaw = "medians"
    }

    // 保留原有字面量初始化形式的兼容（以防有代码直接构造 HanziChar）
    init(id: String, glyph: String, pinyin: String, meaning: String,
         strokes: [String], medians: [[CGPoint]]?) {
        self.id = id
        self.glyph = glyph
        self.pinyin = pinyin
        self.meaning = meaning
        self.strokes = strokes
        self.mediansRaw = medians?.map { stroke in
            stroke.map { [Double($0.x), Double($0.y)] }
        }
    }

    /// 把 HanziChar 转成 CharacterDef 供老系统（KidPracticeSessionView）消费。
    /// strokes 里的 StrokeSpec 从 medians 抽取 3 个锚点，StrokeMatcher 用它做笔顺匹配。
    /// 米字格坐标：hanzi-writer-data 是 1024×1024 Y 上增；我们的 StrokeSpec 是 0-1 Y 下增。
    var asCharacterDef: CharacterDef {
        let mds = mediansRaw ?? []
        let specs: [StrokeSpec] = strokes.enumerated().map { idx, _ in
            let pts = idx < mds.count ? mds[idx] : []
            let norm: [CGPoint] = pts.map { raw in
                let x = raw.count > 0 ? raw[0] : 0
                let y = raw.count > 1 ? raw[1] : 0
                return CGPoint(x: x / 1024, y: 1 - y / 1024)  // Y 翻转 + 归一化
            }
            let anchors: [CGPoint]
            if norm.count >= 3 {
                anchors = [norm.first!, norm[norm.count / 2], norm.last!]
            } else if norm.count == 2 {
                anchors = [norm.first!, norm.last!]
            } else if norm.count == 1 {
                anchors = [norm[0], norm[0]]
            } else {
                anchors = [CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.5, y: 0.5)]
            }
            return StrokeSpec(
                id: "\(glyph)_\(idx)",
                name: "第\(idx + 1)笔",
                points: anchors,
                widthStart: 0.06, widthEnd: 0.06,
                tips: [],
                direction: "→"
            )
        }
        return CharacterDef(
            id: "kid:" + glyph,
            glyph: glyph,
            level: 0,
            title: glyph,
            subtitle: pinyin,
            strokes: specs
        )
    }
}

/// Renders a Hanzi character by drawing each of its strokes from SVG path data.
///
/// The view sizes itself to a square (min of width/height) and centers the
/// character inside. `progress` lets callers animate stroke-by-stroke draw-on.
struct HanziStrokeView: View {
    let hanzi: HanziChar

    /// 0.0 → show nothing; 1.0 → show all strokes.
    /// Integer portion = number of full strokes drawn.
    /// Fractional portion is currently ignored (full-stroke granularity).
    var progress: Double = 1.0

    /// Fill color used for each stroke shape.
    var fill: Color = .black
    /// Outline color (only drawn if `strokeLineWidth > 0`).
    var stroke: Color = .clear
    /// Outline width in view-space points. Values ≤ 0 disable the outline.
    var strokeLineWidth: CGFloat = 0

    /// Source coordinate system size. `hanzi-writer-data` uses 1024×1024
    /// with a bottom-left (Y-up) origin, which we flip to SwiftUI's top-left
    /// (Y-down) at render time.
    var sourceSize: CGFloat = 1024

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let scale = sourceSize > 0 ? side / sourceSize : 1
            let strokeCount = hanzi.strokes.count
            let clamped = max(0.0, min(1.0, progress))
            let fullStrokes = strokeCount == 0
                ? 0
                : max(0, min(strokeCount, Int(floor(clamped * Double(strokeCount)))))

            Canvas { ctx, _ in
                guard strokeCount > 0, fullStrokes > 0, side > 0 else { return }

                // Hanzi Writer coords: bottom-left origin, Y-up.
                // SwiftUI Canvas: top-left origin, Y-down.
                // Apply the mapping once on the GraphicsContext, then draw
                // every stroke in raw source coordinates.
                ctx.translateBy(x: 0, y: side)
                ctx.scaleBy(x: scale, y: -scale)

                for i in 0..<fullStrokes {
                    let p = SVGPathParser.parse(hanzi.strokes[i])
                    ctx.fill(p, with: .color(fill))
                    if strokeLineWidth > 0 {
                        // Divide by scale so the visual stroke width stays
                        // constant in view-space points.
                        ctx.stroke(p, with: .color(stroke), lineWidth: strokeLineWidth / scale)
                    }
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
