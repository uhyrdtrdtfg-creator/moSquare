import Foundation
import CoreGraphics

// ─────────────────────────────────────────────────────────────────
// MARK: - 标准字形数据结构（0-1 归一化坐标系）
// ─────────────────────────────────────────────────────────────────

/// 一笔：由若干 anchor 点定义其主干，渲染时做平滑
struct StrokeSpec: Equatable, Identifiable {
    let id: String
    let name: String                 // "横" / "竖" ...
    let points: [CGPoint]            // 归一化锚点，必须 ≥ 2
    let widthStart: CGFloat          // 起笔宽度（0-1 归一化）
    let widthEnd: CGFloat            // 收笔宽度
    let tips: [String]               // 书写要点（用于展示给零基础用户）
    let direction: String            // "→" / "↓" / "↙" ...
}

/// 一个字：由若干笔画组成
struct CharacterDef: Equatable, Identifiable {
    let id: String                   // "stroke:horizontal" / "char:永"
    let glyph: String                // 显示用字符（笔画显示示意字）
    let level: Int                   // 0..6
    let title: String                // 例: "横" / "永"
    let subtitle: String             // 辅助说明
    let strokes: [StrokeSpec]
}

// ─────────────────────────────────────────────────────────────────
// MARK: - L1 八画数据（零基础核心）
// ─────────────────────────────────────────────────────────────────

enum StandardStrokes {

    static let 横 = StrokeSpec(
        id: "s_heng",
        name: "横",
        points: [
            .init(x: 0.16, y: 0.52),
            .init(x: 0.50, y: 0.50),
            .init(x: 0.84, y: 0.51)
        ],
        widthStart: 0.06, widthEnd: 0.08,
        tips: [
            "起笔略向右下顿一下",
            "中段匀速向右运笔",
            "收笔略有回锋，略下压"
        ],
        direction: "→"
    )

    static let 竖 = StrokeSpec(
        id: "s_shu",
        name: "竖",
        points: [
            .init(x: 0.50, y: 0.16),
            .init(x: 0.50, y: 0.84)
        ],
        widthStart: 0.07, widthEnd: 0.06,
        tips: [
            "起笔略顿，笔要直",
            "像一根柱子立在格子中央",
            "收笔悬针则出锋、垂露则回锋"
        ],
        direction: "↓"
    )

    static let 撇 = StrokeSpec(
        id: "s_pie",
        name: "撇",
        points: [
            .init(x: 0.68, y: 0.20),
            .init(x: 0.48, y: 0.48),
            .init(x: 0.22, y: 0.84)
        ],
        widthStart: 0.08, widthEnd: 0.02,
        tips: [
            "从右上起笔、向左下行笔",
            "越写越细，出锋要尖",
            "不要太弯、也不要太直"
        ],
        direction: "↙"
    )

    static let 捺 = StrokeSpec(
        id: "s_na",
        name: "捺",
        points: [
            .init(x: 0.30, y: 0.22),
            .init(x: 0.50, y: 0.50),
            .init(x: 0.82, y: 0.82)
        ],
        widthStart: 0.02, widthEnd: 0.12,
        tips: [
            "从左上起笔、向右下行笔",
            "渐加力度，末端最粗",
            "收笔平出，如燕尾"
        ],
        direction: "↘"
    )

    static let 点 = StrokeSpec(
        id: "s_dian",
        name: "点",
        points: [
            .init(x: 0.44, y: 0.36),
            .init(x: 0.54, y: 0.52),
            .init(x: 0.60, y: 0.58)
        ],
        widthStart: 0.03, widthEnd: 0.10,
        tips: [
            "轻起、重按、快收",
            "形如瓜子，饱满有力",
            "位于字形上方偏中"
        ],
        direction: "●"
    )

    static let 提 = StrokeSpec(
        id: "s_ti",
        name: "提",
        points: [
            .init(x: 0.22, y: 0.70),
            .init(x: 0.82, y: 0.30)
        ],
        widthStart: 0.09, widthEnd: 0.02,
        tips: [
            "从左下起笔、向右上出锋",
            "起笔稍顿，中段加速",
            "末端变细像针尖"
        ],
        direction: "↗"
    )

    static let 折 = StrokeSpec(
        id: "s_zhe",
        name: "折",
        points: [
            .init(x: 0.18, y: 0.28),
            .init(x: 0.80, y: 0.28),
            .init(x: 0.80, y: 0.80)
        ],
        widthStart: 0.07, widthEnd: 0.07,
        tips: [
            "先写横，末端顿笔",
            "转折处稍停，再向下",
            "竖部要直，保持骨架"
        ],
        direction: "→↓"
    )

    static let 钩 = StrokeSpec(
        id: "s_gou",
        name: "钩",
        points: [
            .init(x: 0.50, y: 0.18),
            .init(x: 0.50, y: 0.76),
            .init(x: 0.30, y: 0.62)
        ],
        widthStart: 0.07, widthEnd: 0.03,
        tips: [
            "先写一笔竖",
            "到末端顿笔蓄势",
            "向左上快速钩出"
        ],
        direction: "↓↖"
    )

    /// L1 全部八画（按学习顺序）
    static let all: [CharacterDef] = [
        .init(id: "stroke:heng", glyph: "一", level: 1, title: "横",
              subtitle: "汉字最常见的基本笔画", strokes: [横]),
        .init(id: "stroke:shu", glyph: "丨", level: 1, title: "竖",
              subtitle: "汉字的骨架", strokes: [竖]),
        .init(id: "stroke:pie", glyph: "丿", level: 1, title: "撇",
              subtitle: "从右上扫到左下", strokes: [撇]),
        .init(id: "stroke:na", glyph: "㇏", level: 1, title: "捺",
              subtitle: "从左上扫到右下", strokes: [捺]),
        .init(id: "stroke:dian", glyph: "丶", level: 1, title: "点",
              subtitle: "小而有力", strokes: [点]),
        .init(id: "stroke:ti", glyph: "㇀", level: 1, title: "提",
              subtitle: "向右上出锋", strokes: [提]),
        .init(id: "stroke:zhe", glyph: "𠃍", level: 1, title: "折",
              subtitle: "先横后竖", strokes: [折]),
        .init(id: "stroke:gou", glyph: "亅", level: 1, title: "钩",
              subtitle: "蓄势后出锋", strokes: [钩])
    ]

    // 速写游戏使用的简易字（展示用，MVP 不做精确评分）
    static let speedChars: [String] = [
        "一", "二", "三", "人", "口", "日",
        "月", "山", "大", "小", "上", "下",
        "中", "土", "王", "木", "火", "水"
    ]
}

// ─────────────────────────────────────────────────────────────────
// MARK: - L2 偏旁部首（6 个高频偏旁）
// ─────────────────────────────────────────────────────────────────

enum StandardRadicals {

    /// 亻 单人旁 · 2 笔：撇 + 竖
    static let 亻 = CharacterDef(
        id: "radical:亻",
        glyph: "亻",
        level: 2,
        title: "亻",
        subtitle: "单人旁 · 左窄右宽",
        strokes: [
            StrokeSpec(
                id: "r_ren_1", name: "撇",
                points: [.init(x: 0.46, y: 0.18),
                         .init(x: 0.34, y: 0.42),
                         .init(x: 0.20, y: 0.80)],
                widthStart: 0.08, widthEnd: 0.02,
                tips: ["撇从右上起笔", "向左下行笔出锋"],
                direction: "↙"
            ),
            StrokeSpec(
                id: "r_ren_2", name: "竖",
                points: [.init(x: 0.42, y: 0.38),
                         .init(x: 0.42, y: 0.85)],
                widthStart: 0.06, widthEnd: 0.05,
                tips: ["竖起笔在撇中段", "竖直下行，稳稳立住"],
                direction: "↓"
            )
        ]
    )

    /// 氵 三点水 · 3 笔：两点 + 提
    static let 氵 = CharacterDef(
        id: "radical:氵",
        glyph: "氵",
        level: 2,
        title: "氵",
        subtitle: "三点水 · 上中下排列",
        strokes: [
            StrokeSpec(
                id: "r_shui_1", name: "点",
                points: [.init(x: 0.22, y: 0.18),
                         .init(x: 0.32, y: 0.30)],
                widthStart: 0.03, widthEnd: 0.10,
                tips: ["第一点在上", "向右下方点入"],
                direction: "●"
            ),
            StrokeSpec(
                id: "r_shui_2", name: "点",
                points: [.init(x: 0.14, y: 0.44),
                         .init(x: 0.24, y: 0.56)],
                widthStart: 0.03, widthEnd: 0.10,
                tips: ["第二点在左", "比第一点略靠左"],
                direction: "●"
            ),
            StrokeSpec(
                id: "r_shui_3", name: "提",
                points: [.init(x: 0.14, y: 0.82),
                         .init(x: 0.40, y: 0.68)],
                widthStart: 0.09, widthEnd: 0.02,
                tips: ["提从左下起笔", "向右上快速出锋"],
                direction: "↗"
            )
        ]
    )

    /// 扌 提手旁 · 3 笔：横 + 竖钩 + 提
    static let 扌 = CharacterDef(
        id: "radical:扌",
        glyph: "扌",
        level: 2,
        title: "扌",
        subtitle: "提手旁 · 竖钩是骨干",
        strokes: [
            StrokeSpec(
                id: "r_shou_1", name: "横",
                points: [.init(x: 0.12, y: 0.32),
                         .init(x: 0.42, y: 0.30)],
                widthStart: 0.06, widthEnd: 0.07,
                tips: ["横略向上倾", "不可太长"],
                direction: "→"
            ),
            StrokeSpec(
                id: "r_shou_2", name: "竖钩",
                points: [.init(x: 0.30, y: 0.18),
                         .init(x: 0.30, y: 0.72),
                         .init(x: 0.16, y: 0.58)],
                widthStart: 0.07, widthEnd: 0.03,
                tips: ["竖是骨架，要直", "末端顿笔向左上钩出"],
                direction: "↓↖"
            ),
            StrokeSpec(
                id: "r_shou_3", name: "提",
                points: [.init(x: 0.12, y: 0.82),
                         .init(x: 0.44, y: 0.68)],
                widthStart: 0.09, widthEnd: 0.02,
                tips: ["提在最下", "向右上方出锋"],
                direction: "↗"
            )
        ]
    )

    /// 讠 言字旁 · 2 笔：点 + 横折提
    static let 讠 = CharacterDef(
        id: "radical:讠",
        glyph: "讠",
        level: 2,
        title: "讠",
        subtitle: "言字旁 · 简体",
        strokes: [
            StrokeSpec(
                id: "r_yan_1", name: "点",
                points: [.init(x: 0.24, y: 0.18),
                         .init(x: 0.34, y: 0.30)],
                widthStart: 0.03, widthEnd: 0.10,
                tips: ["顶部一点", "向右下方点入"],
                direction: "●"
            ),
            StrokeSpec(
                id: "r_yan_2", name: "横折提",
                points: [.init(x: 0.10, y: 0.48),
                         .init(x: 0.42, y: 0.48),
                         .init(x: 0.16, y: 0.82),
                         .init(x: 0.44, y: 0.70)],
                widthStart: 0.06, widthEnd: 0.02,
                tips: ["先写横", "转折向下", "再向右上提出"],
                direction: "→↓↗"
            )
        ]
    )

    /// 宀 宝盖头 · 3 笔：点 + 点 + 横钩
    static let 宀 = CharacterDef(
        id: "radical:宀",
        glyph: "宀",
        level: 2,
        title: "宀",
        subtitle: "宝盖头 · 覆盖下方",
        strokes: [
            StrokeSpec(
                id: "r_bao_1", name: "点",
                points: [.init(x: 0.48, y: 0.18),
                         .init(x: 0.52, y: 0.32)],
                widthStart: 0.03, widthEnd: 0.08,
                tips: ["顶部中央一点", "轻起重收"],
                direction: "●"
            ),
            StrokeSpec(
                id: "r_bao_2", name: "点",
                points: [.init(x: 0.18, y: 0.36),
                         .init(x: 0.26, y: 0.48)],
                widthStart: 0.03, widthEnd: 0.09,
                tips: ["左侧一点", "略向右下点入"],
                direction: "●"
            ),
            StrokeSpec(
                id: "r_bao_3", name: "横钩",
                points: [.init(x: 0.26, y: 0.48),
                         .init(x: 0.80, y: 0.48),
                         .init(x: 0.74, y: 0.62)],
                widthStart: 0.06, widthEnd: 0.02,
                tips: ["横要平，略向上扬", "末端向左下钩出"],
                direction: "→↙"
            )
        ]
    )

    /// 艹 草字头 · 3 笔：横 + 竖 + 竖（简化版）
    static let 艹 = CharacterDef(
        id: "radical:艹",
        glyph: "艹",
        level: 2,
        title: "艹",
        subtitle: "草字头 · 左右两竖一横贯",
        strokes: [
            StrokeSpec(
                id: "r_cao_1", name: "横",
                points: [.init(x: 0.14, y: 0.38),
                         .init(x: 0.86, y: 0.36)],
                widthStart: 0.06, widthEnd: 0.07,
                tips: ["长横贯穿两竖", "略向上倾"],
                direction: "→"
            ),
            StrokeSpec(
                id: "r_cao_2", name: "竖",
                points: [.init(x: 0.30, y: 0.20),
                         .init(x: 0.30, y: 0.60)],
                widthStart: 0.06, widthEnd: 0.05,
                tips: ["左竖在横左侧", "起笔高于横"],
                direction: "↓"
            ),
            StrokeSpec(
                id: "r_cao_3", name: "竖",
                points: [.init(x: 0.70, y: 0.20),
                         .init(x: 0.70, y: 0.60)],
                widthStart: 0.06, widthEnd: 0.05,
                tips: ["右竖在横右侧", "与左竖对称"],
                direction: "↓"
            )
        ]
    )

    /// L2 全部偏旁（按学习顺序：由简到繁）
    static let all: [CharacterDef] = [亻, 氵, 扌, 讠, 宀, 艹]
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 偏旁拼合数据（用于部首拼图游戏）
// ─────────────────────────────────────────────────────────────────

/// 一个合成字的配方：由若干部件放在哪些位置
struct Composite {
    let glyph: String            // 完整字
    let parts: [Part]            // 组成部件
    let description: String      // 结构说明

    struct Part {
        let glyph: String        // 部件字符
        let zone: Zone           // 在米字格中的位置
    }

    enum Zone: Hashable {
        case left, right, top, bottom, whole
        case custom(CGRect)      // 归一化区域 (0-1)

        var rect: CGRect {
            switch self {
            case .left:   return CGRect(x: 0, y: 0, width: 0.45, height: 1)
            case .right:  return CGRect(x: 0.55, y: 0, width: 0.45, height: 1)
            case .top:    return CGRect(x: 0, y: 0, width: 1, height: 0.45)
            case .bottom: return CGRect(x: 0, y: 0.55, width: 1, height: 0.45)
            case .whole:  return CGRect(x: 0, y: 0, width: 1, height: 1)
            case .custom(let r): return r
            }
        }

        var label: String {
            switch self {
            case .left: return "左"
            case .right: return "右"
            case .top: return "上"
            case .bottom: return "下"
            case .whole: return "全"
            case .custom: return "·"
            }
        }
    }
}

enum CompositePool {
    /// MVP 拼图题目库（2 个部件的简单合成字）
    static let all: [Composite] = [
        .init(glyph: "明",
              parts: [.init(glyph: "日", zone: .left),
                      .init(glyph: "月", zone: .right)],
              description: "日 + 月 · 左右结构"),
        .init(glyph: "林",
              parts: [.init(glyph: "木", zone: .left),
                      .init(glyph: "木", zone: .right)],
              description: "木 + 木 · 左右结构"),
        .init(glyph: "好",
              parts: [.init(glyph: "女", zone: .left),
                      .init(glyph: "子", zone: .right)],
              description: "女 + 子 · 左右结构"),
        .init(glyph: "休",
              parts: [.init(glyph: "亻", zone: .left),
                      .init(glyph: "木", zone: .right)],
              description: "亻 + 木 · 人倚树"),
        .init(glyph: "江",
              parts: [.init(glyph: "氵", zone: .left),
                      .init(glyph: "工", zone: .right)],
              description: "氵 + 工 · 左窄右宽"),
        .init(glyph: "安",
              parts: [.init(glyph: "宀", zone: .top),
                      .init(glyph: "女", zone: .bottom)],
              description: "宀 + 女 · 家中有人"),
        .init(glyph: "花",
              parts: [.init(glyph: "艹", zone: .top),
                      .init(glyph: "化", zone: .bottom)],
              description: "艹 + 化 · 上下结构"),
        .init(glyph: "记",
              parts: [.init(glyph: "讠", zone: .left),
                      .init(glyph: "己", zone: .right)],
              description: "讠 + 己 · 左右结构")
    ]

    /// 游戏用的干扰部件（与目标不相关）
    static let distractors = ["口", "田", "目", "山", "力", "大", "一", "人"]
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 路径插值工具（将 anchor 点转成平滑曲线）
// ─────────────────────────────────────────────────────────────────

enum StrokePath {
    /// Catmull-Rom 平滑采样，生成 N 个点（归一化坐标）
    static func sample(_ anchors: [CGPoint], count: Int = 64) -> [CGPoint] {
        guard anchors.count >= 2 else { return anchors }
        if anchors.count == 2 {
            // 两点退化为直线
            return (0...count).map { i in
                let t = CGFloat(i) / CGFloat(count)
                return CGPoint(
                    x: anchors[0].x + (anchors[1].x - anchors[0].x) * t,
                    y: anchors[0].y + (anchors[1].y - anchors[0].y) * t
                )
            }
        }
        // Catmull-Rom：扩展前后各一个虚拟点
        var pts: [CGPoint] = []
        let ext: [CGPoint] = [anchors.first!] + anchors + [anchors.last!]
        let segs = anchors.count - 1
        for s in 0..<segs {
            let p0 = ext[s], p1 = ext[s + 1], p2 = ext[s + 2], p3 = ext[s + 3]
            let stepsPerSeg = max(4, count / segs)
            for i in 0..<stepsPerSeg {
                let t = CGFloat(i) / CGFloat(stepsPerSeg)
                pts.append(catmullRom(p0, p1, p2, p3, t: t))
            }
        }
        pts.append(anchors.last!)
        return pts
    }

    private static func catmullRom(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, t: CGFloat) -> CGPoint {
        let t2 = t * t, t3 = t2 * t
        let x = 0.5 * ((2 * p1.x) +
            (-p0.x + p2.x) * t +
            (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * t2 +
            (-p0.x + 3*p1.x - 3*p2.x + p3.x) * t3)
        let y = 0.5 * ((2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * t2 +
            (-p0.y + 3*p1.y - 3*p2.y + p3.y) * t3)
        return CGPoint(x: x, y: y)
    }
}
