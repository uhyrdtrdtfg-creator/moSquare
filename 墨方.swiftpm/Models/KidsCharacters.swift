import Foundation
import CoreGraphics

// ─────────────────────────────────────────────────────────────────
// MARK: - 幼儿识字 · 第一批 20 字（4-5 岁友好）
// ─────────────────────────────────────────────────────────────────
//
// 依据：《认识500个儿童常用字（基础字1）（4-5岁适用）》
// 原则：笔画数 ≤ 5、起笔明确、结构简单、生活高频
// 顺序：数字 → 象形 → 高频形容词
//
// 所有字的笔顺坐标均为 0-1 归一化，在米字格中合理居中
// 每一笔的 points 至少 2 个锚点（直笔）或 3 个锚点（带转折）
// ─────────────────────────────────────────────────────────────────

enum KidsCharacters {

    // ─── 数字 10 字 ────────────────────────────────────────────

    static let 一 = CharacterDef(
        id: "kid:一", glyph: "一", level: 0,
        title: "一", subtitle: "一横 · 最简单的字",
        strokes: [
            StrokeSpec(id: "k_1_1", name: "横",
                       points: [.init(x: 0.14, y: 0.50), .init(x: 0.86, y: 0.50)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["从左到右画一横"], direction: "→")
        ]
    )

    static let 二 = CharacterDef(
        id: "kid:二", glyph: "二", level: 0,
        title: "二", subtitle: "两横 · 上短下长",
        strokes: [
            StrokeSpec(id: "k_2_1", name: "短横",
                       points: [.init(x: 0.26, y: 0.32), .init(x: 0.70, y: 0.32)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["先写上面的短横"], direction: "→"),
            StrokeSpec(id: "k_2_2", name: "长横",
                       points: [.init(x: 0.14, y: 0.70), .init(x: 0.86, y: 0.70)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["再写下面的长横，要更长"], direction: "→")
        ]
    )

    static let 三 = CharacterDef(
        id: "kid:三", glyph: "三", level: 0,
        title: "三", subtitle: "三横 · 从上到下",
        strokes: [
            StrokeSpec(id: "k_3_1", name: "短横",
                       points: [.init(x: 0.24, y: 0.24), .init(x: 0.70, y: 0.24)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["最上面一横"], direction: "→"),
            StrokeSpec(id: "k_3_2", name: "短横",
                       points: [.init(x: 0.30, y: 0.50), .init(x: 0.66, y: 0.50)],
                       widthStart: 0.05, widthEnd: 0.06,
                       tips: ["中间一横短一些"], direction: "→"),
            StrokeSpec(id: "k_3_3", name: "长横",
                       points: [.init(x: 0.14, y: 0.76), .init(x: 0.86, y: 0.76)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最下面一横最长"], direction: "→")
        ]
    )

    static let 十 = CharacterDef(
        id: "kid:十", glyph: "十", level: 0,
        title: "十", subtitle: "先横后竖",
        strokes: [
            StrokeSpec(id: "k_10_1", name: "横",
                       points: [.init(x: 0.15, y: 0.50), .init(x: 0.85, y: 0.50)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["先画一横"], direction: "→"),
            StrokeSpec(id: "k_10_2", name: "竖",
                       points: [.init(x: 0.50, y: 0.16), .init(x: 0.50, y: 0.84)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["再画一竖"], direction: "↓")
        ]
    )

    // ─── 象形字 10 字 ──────────────────────────────────────────

    static let 人 = CharacterDef(
        id: "kid:人", glyph: "人", level: 0,
        title: "人", subtitle: "一撇一捺",
        strokes: [
            StrokeSpec(id: "k_ren_1", name: "撇",
                       points: [.init(x: 0.50, y: 0.18),
                                .init(x: 0.36, y: 0.45),
                                .init(x: 0.18, y: 0.84)],
                       widthStart: 0.08, widthEnd: 0.02,
                       tips: ["从上往左下撇"], direction: "↙"),
            StrokeSpec(id: "k_ren_2", name: "捺",
                       points: [.init(x: 0.50, y: 0.18),
                                .init(x: 0.64, y: 0.45),
                                .init(x: 0.84, y: 0.84)],
                       widthStart: 0.03, widthEnd: 0.12,
                       tips: ["再从上往右下捺"], direction: "↘")
        ]
    )

    static let 八 = CharacterDef(
        id: "kid:八", glyph: "八", level: 0,
        title: "八", subtitle: "左撇右捺 · 分开",
        strokes: [
            StrokeSpec(id: "k_ba_1", name: "撇",
                       points: [.init(x: 0.42, y: 0.22),
                                .init(x: 0.18, y: 0.78)],
                       widthStart: 0.08, widthEnd: 0.02,
                       tips: ["左边一撇"], direction: "↙"),
            StrokeSpec(id: "k_ba_2", name: "捺",
                       points: [.init(x: 0.58, y: 0.22),
                                .init(x: 0.82, y: 0.78)],
                       widthStart: 0.03, widthEnd: 0.12,
                       tips: ["右边一捺"], direction: "↘")
        ]
    )

    static let 口 = CharacterDef(
        id: "kid:口", glyph: "口", level: 0,
        title: "口", subtitle: "像一张嘴",
        strokes: [
            StrokeSpec(id: "k_kou_1", name: "竖",
                       points: [.init(x: 0.22, y: 0.24), .init(x: 0.22, y: 0.80)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写左竖"], direction: "↓"),
            StrokeSpec(id: "k_kou_2", name: "横折",
                       points: [.init(x: 0.22, y: 0.24),
                                .init(x: 0.78, y: 0.24),
                                .init(x: 0.78, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["再写横折（上横+右竖）"], direction: "→↓"),
            StrokeSpec(id: "k_kou_3", name: "横",
                       points: [.init(x: 0.22, y: 0.80), .init(x: 0.78, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["最后封底一横"], direction: "→")
        ]
    )

    static let 山 = CharacterDef(
        id: "kid:山", glyph: "山", level: 0,
        title: "山", subtitle: "三座小山峰",
        strokes: [
            StrokeSpec(id: "k_shan_1", name: "竖",
                       points: [.init(x: 0.50, y: 0.22), .init(x: 0.50, y: 0.78)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写中间一竖（最高的山）"], direction: "↓"),
            StrokeSpec(id: "k_shan_2", name: "竖折",
                       points: [.init(x: 0.20, y: 0.40),
                                .init(x: 0.20, y: 0.78),
                                .init(x: 0.80, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["再写左边 → 下面 → 折到右边"], direction: "↓→"),
            StrokeSpec(id: "k_shan_3", name: "竖",
                       points: [.init(x: 0.80, y: 0.38), .init(x: 0.80, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["最后右边的小竖"], direction: "↓")
        ]
    )

    static let 日 = CharacterDef(
        id: "kid:日", glyph: "日", level: 0,
        title: "日", subtitle: "像太阳的方框",
        strokes: [
            StrokeSpec(id: "k_ri_1", name: "竖",
                       points: [.init(x: 0.28, y: 0.20), .init(x: 0.28, y: 0.80)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写左竖"], direction: "↓"),
            StrokeSpec(id: "k_ri_2", name: "横折",
                       points: [.init(x: 0.28, y: 0.20),
                                .init(x: 0.72, y: 0.20),
                                .init(x: 0.72, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["再写横折（上横+右竖）"], direction: "→↓"),
            StrokeSpec(id: "k_ri_3", name: "横",
                       points: [.init(x: 0.28, y: 0.50), .init(x: 0.72, y: 0.50)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["中间一横"], direction: "→"),
            StrokeSpec(id: "k_ri_4", name: "横",
                       points: [.init(x: 0.28, y: 0.80), .init(x: 0.72, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["最后封底一横"], direction: "→")
        ]
    )

    static let 月 = CharacterDef(
        id: "kid:月", glyph: "月", level: 0,
        title: "月", subtitle: "像弯弯的月亮",
        strokes: [
            StrokeSpec(id: "k_yue_1", name: "撇",
                       points: [.init(x: 0.40, y: 0.18),
                                .init(x: 0.30, y: 0.50),
                                .init(x: 0.20, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.04,
                       tips: ["左边一撇，像月亮的轮廓"], direction: "↙"),
            StrokeSpec(id: "k_yue_2", name: "横折钩",
                       points: [.init(x: 0.40, y: 0.18),
                                .init(x: 0.78, y: 0.18),
                                .init(x: 0.78, y: 0.80),
                                .init(x: 0.66, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["横+竖+钩，末尾向左上钩"], direction: "→↓↖"),
            StrokeSpec(id: "k_yue_3", name: "横",
                       points: [.init(x: 0.30, y: 0.42), .init(x: 0.78, y: 0.42)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间上面的一横"], direction: "→"),
            StrokeSpec(id: "k_yue_4", name: "横",
                       points: [.init(x: 0.26, y: 0.62), .init(x: 0.78, y: 0.62)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间下面的一横"], direction: "→")
        ]
    )

    static let 木 = CharacterDef(
        id: "kid:木", glyph: "木", level: 0,
        title: "木", subtitle: "像一棵小树",
        strokes: [
            StrokeSpec(id: "k_mu_1", name: "横",
                       points: [.init(x: 0.15, y: 0.38), .init(x: 0.85, y: 0.38)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["先写一横（树枝）"], direction: "→"),
            StrokeSpec(id: "k_mu_2", name: "竖",
                       points: [.init(x: 0.50, y: 0.20), .init(x: 0.50, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["再写一竖（树干）"], direction: "↓"),
            StrokeSpec(id: "k_mu_3", name: "撇",
                       points: [.init(x: 0.50, y: 0.42),
                                .init(x: 0.22, y: 0.78)],
                       widthStart: 0.05, widthEnd: 0.02,
                       tips: ["左边一撇（树根）"], direction: "↙"),
            StrokeSpec(id: "k_mu_4", name: "捺",
                       points: [.init(x: 0.50, y: 0.42),
                                .init(x: 0.78, y: 0.78)],
                       widthStart: 0.03, widthEnd: 0.10,
                       tips: ["右边一捺（树根）"], direction: "↘")
        ]
    )

    static let 火 = CharacterDef(
        id: "kid:火", glyph: "火", level: 0,
        title: "火", subtitle: "像燃烧的火焰",
        strokes: [
            StrokeSpec(id: "k_huo_1", name: "点",
                       points: [.init(x: 0.32, y: 0.22), .init(x: 0.24, y: 0.38)],
                       widthStart: 0.03, widthEnd: 0.09,
                       tips: ["左上一点"], direction: "●"),
            StrokeSpec(id: "k_huo_2", name: "撇",
                       points: [.init(x: 0.68, y: 0.28), .init(x: 0.58, y: 0.42)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["右上一短撇"], direction: "↙"),
            StrokeSpec(id: "k_huo_3", name: "撇",
                       points: [.init(x: 0.50, y: 0.28),
                                .init(x: 0.22, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["中间长撇"], direction: "↙"),
            StrokeSpec(id: "k_huo_4", name: "捺",
                       points: [.init(x: 0.50, y: 0.32),
                                .init(x: 0.82, y: 0.82)],
                       widthStart: 0.03, widthEnd: 0.11,
                       tips: ["右边一捺"], direction: "↘")
        ]
    )

    static let 水 = CharacterDef(
        id: "kid:水", glyph: "水", level: 0,
        title: "水", subtitle: "像流动的水",
        strokes: [
            StrokeSpec(id: "k_shui_1", name: "竖钩",
                       points: [.init(x: 0.50, y: 0.18),
                                .init(x: 0.50, y: 0.72),
                                .init(x: 0.40, y: 0.62)],
                       widthStart: 0.07, widthEnd: 0.03,
                       tips: ["中间一竖带钩"], direction: "↓↖"),
            StrokeSpec(id: "k_shui_2", name: "横撇",
                       points: [.init(x: 0.28, y: 0.42),
                                .init(x: 0.40, y: 0.50),
                                .init(x: 0.22, y: 0.74)],
                       widthStart: 0.04, widthEnd: 0.02,
                       tips: ["左边小横撇"], direction: "→↙"),
            StrokeSpec(id: "k_shui_3", name: "撇",
                       points: [.init(x: 0.60, y: 0.38), .init(x: 0.36, y: 0.82)],
                       widthStart: 0.05, widthEnd: 0.02,
                       tips: ["左边长撇"], direction: "↙"),
            StrokeSpec(id: "k_shui_4", name: "捺",
                       points: [.init(x: 0.58, y: 0.40), .init(x: 0.80, y: 0.78)],
                       widthStart: 0.03, widthEnd: 0.10,
                       tips: ["右边一捺"], direction: "↘")
        ]
    )

    static let 土 = CharacterDef(
        id: "kid:土", glyph: "土", level: 0,
        title: "土", subtitle: "两横一竖",
        strokes: [
            StrokeSpec(id: "k_tu_1", name: "横",
                       points: [.init(x: 0.24, y: 0.34), .init(x: 0.70, y: 0.34)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写上面的短横"], direction: "→"),
            StrokeSpec(id: "k_tu_2", name: "竖",
                       points: [.init(x: 0.50, y: 0.20), .init(x: 0.50, y: 0.78)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["再写中间一竖"], direction: "↓"),
            StrokeSpec(id: "k_tu_3", name: "长横",
                       points: [.init(x: 0.14, y: 0.78), .init(x: 0.86, y: 0.78)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后写下面的长横"], direction: "→")
        ]
    )

    // ─── 高频形容词 / 方位 ──────────────────────────────────────

    static let 大 = CharacterDef(
        id: "kid:大", glyph: "大", level: 0,
        title: "大", subtitle: "像张开双手的人",
        strokes: [
            StrokeSpec(id: "k_da_1", name: "横",
                       points: [.init(x: 0.15, y: 0.38), .init(x: 0.85, y: 0.38)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["先写一横"], direction: "→"),
            StrokeSpec(id: "k_da_2", name: "撇",
                       points: [.init(x: 0.50, y: 0.18),
                                .init(x: 0.20, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["再写左撇"], direction: "↙"),
            StrokeSpec(id: "k_da_3", name: "捺",
                       points: [.init(x: 0.50, y: 0.40),
                                .init(x: 0.80, y: 0.82)],
                       widthStart: 0.03, widthEnd: 0.11,
                       tips: ["最后写右捺"], direction: "↘")
        ]
    )

    static let 小 = CharacterDef(
        id: "kid:小", glyph: "小", level: 0,
        title: "小", subtitle: "中间一竖钩，两边两点",
        strokes: [
            StrokeSpec(id: "k_xiao_1", name: "竖钩",
                       points: [.init(x: 0.50, y: 0.25),
                                .init(x: 0.50, y: 0.70),
                                .init(x: 0.40, y: 0.62)],
                       widthStart: 0.07, widthEnd: 0.03,
                       tips: ["中间先写一竖钩"], direction: "↓↖"),
            StrokeSpec(id: "k_xiao_2", name: "撇",
                       points: [.init(x: 0.30, y: 0.38), .init(x: 0.18, y: 0.58)],
                       widthStart: 0.05, widthEnd: 0.02,
                       tips: ["左边一点"], direction: "↙"),
            StrokeSpec(id: "k_xiao_3", name: "点",
                       points: [.init(x: 0.70, y: 0.38), .init(x: 0.82, y: 0.58)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["右边一点"], direction: "●")
        ]
    )

    static let 上 = CharacterDef(
        id: "kid:上", glyph: "上", level: 0,
        title: "上", subtitle: "先竖后横",
        strokes: [
            StrokeSpec(id: "k_shang_1", name: "竖",
                       points: [.init(x: 0.50, y: 0.22), .init(x: 0.50, y: 0.60)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写一竖"], direction: "↓"),
            StrokeSpec(id: "k_shang_2", name: "短横",
                       points: [.init(x: 0.50, y: 0.50), .init(x: 0.78, y: 0.50)],
                       widthStart: 0.05, widthEnd: 0.06,
                       tips: ["再写右边短横"], direction: "→"),
            StrokeSpec(id: "k_shang_3", name: "长横",
                       points: [.init(x: 0.15, y: 0.75), .init(x: 0.85, y: 0.75)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后写长横"], direction: "→")
        ]
    )

    static let 下 = CharacterDef(
        id: "kid:下", glyph: "下", level: 0,
        title: "下", subtitle: "先横后竖再一点",
        strokes: [
            StrokeSpec(id: "k_xia_1", name: "长横",
                       points: [.init(x: 0.15, y: 0.30), .init(x: 0.85, y: 0.30)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["先写长横"], direction: "→"),
            StrokeSpec(id: "k_xia_2", name: "竖",
                       points: [.init(x: 0.50, y: 0.30), .init(x: 0.50, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["再写一竖"], direction: "↓"),
            StrokeSpec(id: "k_xia_3", name: "点",
                       points: [.init(x: 0.50, y: 0.52), .init(x: 0.64, y: 0.46)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["最后点一点"], direction: "●")
        ]
    )

    static let 中 = CharacterDef(
        id: "kid:中", glyph: "中", level: 0,
        title: "中", subtitle: "口字中间穿一竖",
        strokes: [
            StrokeSpec(id: "k_zhong_1", name: "竖",
                       points: [.init(x: 0.30, y: 0.28), .init(x: 0.30, y: 0.70)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写左竖"], direction: "↓"),
            StrokeSpec(id: "k_zhong_2", name: "横折",
                       points: [.init(x: 0.30, y: 0.28),
                                .init(x: 0.70, y: 0.28),
                                .init(x: 0.70, y: 0.70)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["再写横折"], direction: "→↓"),
            StrokeSpec(id: "k_zhong_3", name: "横",
                       points: [.init(x: 0.30, y: 0.70), .init(x: 0.70, y: 0.70)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["封底一横"], direction: "→"),
            StrokeSpec(id: "k_zhong_4", name: "长竖",
                       points: [.init(x: 0.50, y: 0.14), .init(x: 0.50, y: 0.86)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["最后中间一长竖"], direction: "↓")
        ]
    )

    // ─── 汇总 ────────────────────────────────────────────────────

    /// 第一批 20 字（按学习顺序：简单→复杂）
    static let all: [CharacterDef] = [
        一, 二, 三, 十,                  // 数字（简）
        人, 八, 大, 小, 上, 下,           // 方位 / 人体
        口, 土, 木, 山, 中,               // 象形
        日, 月, 火, 水,                   // 自然
        中                                // (收尾示例)
    ]
        .reduce(into: [CharacterDef]()) { acc, c in
            if !acc.contains(where: { $0.id == c.id }) { acc.append(c) }
        }

    /// 供首页 & Path UI 显示的分组
    static let groups: [(title: String, chars: [CharacterDef])] = [
        ("数字 · 一二三十", [一, 二, 三, 十]),
        ("人 · 人八大小上下", [人, 八, 大, 小, 上, 下]),
        ("物 · 口土木山中", [口, 土, 木, 山, 中]),
        ("天地 · 日月火水", [日, 月, 火, 水])
    ]

    // ─── 幼儿元数据：拼音、图示 emoji、含义 ──────────────────────
    /// 为 4-5 岁小朋友提供"听音 + 看图"的感官锚点
    struct Meta {
        let pinyin: String       // "yuè"
        let emoji: String        // "🌙"
        let meaning: String      // "月亮"
        let sticker: String      // 完成后解锁的贴纸（emoji 替代）
        let cheer: String?       // 特别鼓励话（可选）
    }

    static let meta: [String: Meta] = [
        "kid:一": .init(pinyin: "yī",    emoji: "☝️",  meaning: "一只",     sticker: "🌟", cheer: nil),
        "kid:二": .init(pinyin: "èr",   emoji: "✌️",  meaning: "二月",     sticker: "🌸", cheer: nil),
        "kid:三": .init(pinyin: "sān",  emoji: "🌟",  meaning: "三角形",   sticker: "🌈", cheer: nil),
        "kid:十": .init(pinyin: "shí",  emoji: "🔟",  meaning: "十全十美", sticker: "🍬", cheer: "十写完啦，十个棒!"),
        "kid:人": .init(pinyin: "rén",  emoji: "🧍",  meaning: "人类",     sticker: "🧑", cheer: nil),
        "kid:八": .init(pinyin: "bā",   emoji: "🐙",  meaning: "章鱼八只脚", sticker: "🎈", cheer: nil),
        "kid:大": .init(pinyin: "dà",   emoji: "🐘",  meaning: "大象",     sticker: "🐘", cheer: "哇，这字好大!"),
        "kid:小": .init(pinyin: "xiǎo", emoji: "🐜",  meaning: "小蚂蚁",   sticker: "🐞", cheer: nil),
        "kid:上": .init(pinyin: "shàng",emoji: "⬆️",  meaning: "上面",     sticker: "⭐", cheer: nil),
        "kid:下": .init(pinyin: "xià",  emoji: "⬇️",  meaning: "下面",     sticker: "🍎", cheer: nil),
        "kid:口": .init(pinyin: "kǒu",  emoji: "👄",  meaning: "嘴巴",     sticker: "👄", cheer: nil),
        "kid:土": .init(pinyin: "tǔ",   emoji: "🟫",  meaning: "土地",     sticker: "🪴", cheer: nil),
        "kid:木": .init(pinyin: "mù",   emoji: "🌳",  meaning: "树木",     sticker: "🌳", cheer: "一棵大树长好啦!"),
        "kid:山": .init(pinyin: "shān", emoji: "⛰️",  meaning: "高山",     sticker: "🏔️", cheer: nil),
        "kid:中": .init(pinyin: "zhōng",emoji: "🎯",  meaning: "中间",     sticker: "🎯", cheer: nil),
        "kid:日": .init(pinyin: "rì",   emoji: "☀️",  meaning: "太阳",     sticker: "☀️", cheer: "太阳出来啦!"),
        "kid:月": .init(pinyin: "yuè",  emoji: "🌙",  meaning: "月亮",     sticker: "🌙", cheer: "月亮升起来了~"),
        "kid:火": .init(pinyin: "huǒ",  emoji: "🔥",  meaning: "火焰",     sticker: "🔥", cheer: nil),
        "kid:水": .init(pinyin: "shuǐ", emoji: "💧",  meaning: "河水",     sticker: "🌊", cheer: nil)
    ]

    static func metaFor(_ id: String) -> Meta? {
        // 依次查：原批 → 扩展包 → 第三包
        meta[id] ?? KidsCharactersExtra.meta[id] ?? KidsCharactersPack3.meta[id]
    }
}
