import Foundation
import CoreGraphics

// ─────────────────────────────────────────────────────────────
// L0 幼儿字 · 扩展 30 字（在 KidsCharacters.all 之外的新字）
// 分 5 包：数字续 / 自然 / 身体 / 动物 / 动作方位
// ─────────────────────────────────────────────────────────────

enum KidsCharactersExtra {

    // ─── Pack 1 · 数字续 ──────────────────────────────

    static let 四 = CharacterDef(
        id: "kid:四", glyph: "四", level: 0,
        title: "四", subtitle: "像一个小框框",
        strokes: [
            StrokeSpec(id: "k_si_1", name: "竖",
                       points: [.init(x: 0.22, y: 0.24), .init(x: 0.22, y: 0.78)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写左边一竖"], direction: "↓"),
            StrokeSpec(id: "k_si_2", name: "横折",
                       points: [.init(x: 0.22, y: 0.24),
                                .init(x: 0.78, y: 0.24),
                                .init(x: 0.78, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["再写横折"], direction: "→↓"),
            StrokeSpec(id: "k_si_3", name: "撇",
                       points: [.init(x: 0.38, y: 0.38), .init(x: 0.36, y: 0.66)],
                       widthStart: 0.06, widthEnd: 0.04,
                       tips: ["里面左边一短竖"], direction: "↓"),
            StrokeSpec(id: "k_si_4", name: "竖弯",
                       points: [.init(x: 0.58, y: 0.38),
                                .init(x: 0.58, y: 0.62),
                                .init(x: 0.66, y: 0.66)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["里面右边一竖弯"], direction: "↓→"),
            StrokeSpec(id: "k_si_5", name: "横",
                       points: [.init(x: 0.22, y: 0.78), .init(x: 0.78, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["最后封底一横"], direction: "→")
        ]
    )

    static let 五 = CharacterDef(
        id: "kid:五", glyph: "五", level: 0,
        title: "五", subtitle: "四笔写成",
        strokes: [
            StrokeSpec(id: "k_wu_1", name: "横",
                       points: [.init(x: 0.20, y: 0.26), .init(x: 0.78, y: 0.26)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["先写上面一横"], direction: "→"),
            StrokeSpec(id: "k_wu_2", name: "竖",
                       points: [.init(x: 0.34, y: 0.26), .init(x: 0.30, y: 0.60)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["再写一竖"], direction: "↓"),
            StrokeSpec(id: "k_wu_3", name: "横折",
                       points: [.init(x: 0.30, y: 0.56),
                                .init(x: 0.74, y: 0.56),
                                .init(x: 0.74, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["横折包一包"], direction: "→↓"),
            StrokeSpec(id: "k_wu_4", name: "长横",
                       points: [.init(x: 0.16, y: 0.80), .init(x: 0.84, y: 0.80)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横封底"], direction: "→")
        ]
    )

    static let 六 = CharacterDef(
        id: "kid:六", glyph: "六", level: 0,
        title: "六", subtitle: "上面一点一横",
        strokes: [
            StrokeSpec(id: "k_liu_1", name: "点",
                       points: [.init(x: 0.48, y: 0.18), .init(x: 0.52, y: 0.28)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["上面一点"], direction: "●"),
            StrokeSpec(id: "k_liu_2", name: "横",
                       points: [.init(x: 0.16, y: 0.40), .init(x: 0.84, y: 0.40)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["再写长横"], direction: "→"),
            StrokeSpec(id: "k_liu_3", name: "撇",
                       points: [.init(x: 0.36, y: 0.58), .init(x: 0.22, y: 0.82)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["左边一撇"], direction: "↙"),
            StrokeSpec(id: "k_liu_4", name: "点",
                       points: [.init(x: 0.64, y: 0.58), .init(x: 0.80, y: 0.82)],
                       widthStart: 0.03, widthEnd: 0.09,
                       tips: ["右边一点"], direction: "●")
        ]
    )

    static let 七 = CharacterDef(
        id: "kid:七", glyph: "七", level: 0,
        title: "七", subtitle: "先横再竖弯钩",
        strokes: [
            StrokeSpec(id: "k_qi_1", name: "横",
                       points: [.init(x: 0.16, y: 0.44), .init(x: 0.70, y: 0.40)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["先写一斜横"], direction: "→"),
            StrokeSpec(id: "k_qi_2", name: "竖弯钩",
                       points: [.init(x: 0.44, y: 0.22),
                                .init(x: 0.44, y: 0.70),
                                .init(x: 0.82, y: 0.72),
                                .init(x: 0.84, y: 0.60)],
                       widthStart: 0.07, widthEnd: 0.03,
                       tips: ["再写竖弯钩"], direction: "↓→↑")
        ]
    )

    static let 九 = CharacterDef(
        id: "kid:九", glyph: "九", level: 0,
        title: "九", subtitle: "一撇一横折弯钩",
        strokes: [
            StrokeSpec(id: "k_jiu_1", name: "撇",
                       points: [.init(x: 0.44, y: 0.22),
                                .init(x: 0.34, y: 0.48),
                                .init(x: 0.18, y: 0.80)],
                       widthStart: 0.08, widthEnd: 0.02,
                       tips: ["先写一撇"], direction: "↙"),
            StrokeSpec(id: "k_jiu_2", name: "横折弯钩",
                       points: [.init(x: 0.34, y: 0.34),
                                .init(x: 0.80, y: 0.34),
                                .init(x: 0.80, y: 0.70),
                                .init(x: 0.72, y: 0.60)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["再写横折弯钩"], direction: "→↓↖")
        ]
    )

    // ─── Pack 2 · 自然 ──────────────────────────────

    static let 天 = CharacterDef(
        id: "kid:天", glyph: "天", level: 0,
        title: "天", subtitle: "上面一片天",
        strokes: [
            StrokeSpec(id: "k_tian_1", name: "短横",
                       points: [.init(x: 0.26, y: 0.26), .init(x: 0.72, y: 0.26)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写上面短横"], direction: "→"),
            StrokeSpec(id: "k_tian_2", name: "长横",
                       points: [.init(x: 0.16, y: 0.46), .init(x: 0.84, y: 0.46)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["再写下面长横"], direction: "→"),
            StrokeSpec(id: "k_tian_3", name: "撇",
                       points: [.init(x: 0.50, y: 0.46),
                                .init(x: 0.22, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["左撇"], direction: "↙"),
            StrokeSpec(id: "k_tian_4", name: "捺",
                       points: [.init(x: 0.50, y: 0.46),
                                .init(x: 0.80, y: 0.82)],
                       widthStart: 0.03, widthEnd: 0.11,
                       tips: ["右捺"], direction: "↘")
        ]
    )

    static let 雨 = CharacterDef(
        id: "kid:雨", glyph: "雨", level: 0,
        title: "雨", subtitle: "天上下小雨点",
        strokes: [
            StrokeSpec(id: "k_yu_1", name: "横",
                       points: [.init(x: 0.26, y: 0.18), .init(x: 0.74, y: 0.18)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写上面一横"], direction: "→"),
            StrokeSpec(id: "k_yu_2", name: "竖",
                       points: [.init(x: 0.22, y: 0.30), .init(x: 0.22, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["左边一竖"], direction: "↓"),
            StrokeSpec(id: "k_yu_3", name: "横折钩",
                       points: [.init(x: 0.22, y: 0.30),
                                .init(x: 0.78, y: 0.30),
                                .init(x: 0.78, y: 0.80),
                                .init(x: 0.70, y: 0.74)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["横折包一包"], direction: "→↓↖"),
            StrokeSpec(id: "k_yu_4", name: "竖",
                       points: [.init(x: 0.50, y: 0.38), .init(x: 0.50, y: 0.78)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间一竖"], direction: "↓"),
            StrokeSpec(id: "k_yu_5", name: "点",
                       points: [.init(x: 0.34, y: 0.48), .init(x: 0.36, y: 0.56)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["小雨点一"], direction: "●"),
            StrokeSpec(id: "k_yu_6", name: "点",
                       points: [.init(x: 0.34, y: 0.64), .init(x: 0.36, y: 0.72)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["小雨点二"], direction: "●"),
            StrokeSpec(id: "k_yu_7", name: "点",
                       points: [.init(x: 0.62, y: 0.48), .init(x: 0.64, y: 0.56)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["小雨点三"], direction: "●"),
            StrokeSpec(id: "k_yu_8", name: "点",
                       points: [.init(x: 0.62, y: 0.64), .init(x: 0.64, y: 0.72)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["小雨点四"], direction: "●")
        ]
    )

    static let 云 = CharacterDef(
        id: "kid:云", glyph: "云", level: 0,
        title: "云", subtitle: "天上的白云",
        strokes: [
            StrokeSpec(id: "k_yun_1", name: "短横",
                       points: [.init(x: 0.28, y: 0.28), .init(x: 0.66, y: 0.28)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写短横"], direction: "→"),
            StrokeSpec(id: "k_yun_2", name: "长横",
                       points: [.init(x: 0.18, y: 0.48), .init(x: 0.82, y: 0.48)],
                       widthStart: 0.07, widthEnd: 0.07,
                       tips: ["再写长横"], direction: "→"),
            StrokeSpec(id: "k_yun_3", name: "撇折",
                       points: [.init(x: 0.30, y: 0.58),
                                .init(x: 0.26, y: 0.72),
                                .init(x: 0.70, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["撇折一下"], direction: "↙→"),
            StrokeSpec(id: "k_yun_4", name: "点",
                       points: [.init(x: 0.62, y: 0.58), .init(x: 0.72, y: 0.68)],
                       widthStart: 0.03, widthEnd: 0.09,
                       tips: ["最后一点"], direction: "●")
        ]
    )

    static let 雪 = CharacterDef(
        id: "kid:雪", glyph: "雪", level: 0,
        title: "雪", subtitle: "雪花飘下来",
        strokes: [
            StrokeSpec(id: "k_xue_1", name: "横",
                       points: [.init(x: 0.28, y: 0.14), .init(x: 0.72, y: 0.14)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["雨字头一横"], direction: "→"),
            StrokeSpec(id: "k_xue_2", name: "竖",
                       points: [.init(x: 0.24, y: 0.24), .init(x: 0.24, y: 0.46)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["雨字头左竖"], direction: "↓"),
            StrokeSpec(id: "k_xue_3", name: "横折",
                       points: [.init(x: 0.24, y: 0.24),
                                .init(x: 0.76, y: 0.24),
                                .init(x: 0.76, y: 0.46)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["雨字头横折"], direction: "→↓"),
            StrokeSpec(id: "k_xue_4", name: "点",
                       points: [.init(x: 0.42, y: 0.32), .init(x: 0.44, y: 0.40)],
                       widthStart: 0.03, widthEnd: 0.06,
                       tips: ["里面小点"], direction: "●"),
            StrokeSpec(id: "k_xue_5", name: "点",
                       points: [.init(x: 0.56, y: 0.32), .init(x: 0.58, y: 0.40)],
                       widthStart: 0.03, widthEnd: 0.06,
                       tips: ["里面小点"], direction: "●"),
            StrokeSpec(id: "k_xue_6", name: "横折",
                       points: [.init(x: 0.24, y: 0.58),
                                .init(x: 0.76, y: 0.58),
                                .init(x: 0.76, y: 0.74)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["彐头横折"], direction: "→↓"),
            StrokeSpec(id: "k_xue_7", name: "横",
                       points: [.init(x: 0.30, y: 0.66), .init(x: 0.70, y: 0.66)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["彐中一横"], direction: "→"),
            StrokeSpec(id: "k_xue_8", name: "长横",
                       points: [.init(x: 0.18, y: 0.82), .init(x: 0.82, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.07,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    static let 风 = CharacterDef(
        id: "kid:风", glyph: "风", level: 0,
        title: "风", subtitle: "风呼呼地吹",
        strokes: [
            StrokeSpec(id: "k_feng_1", name: "撇",
                       points: [.init(x: 0.28, y: 0.20),
                                .init(x: 0.20, y: 0.50),
                                .init(x: 0.16, y: 0.82)],
                       widthStart: 0.08, widthEnd: 0.04,
                       tips: ["左边一长撇"], direction: "↙"),
            StrokeSpec(id: "k_feng_2", name: "横折弯钩",
                       points: [.init(x: 0.28, y: 0.20),
                                .init(x: 0.82, y: 0.20),
                                .init(x: 0.82, y: 0.76),
                                .init(x: 0.70, y: 0.82)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["横折弯钩"], direction: "→↓↙"),
            StrokeSpec(id: "k_feng_3", name: "撇",
                       points: [.init(x: 0.48, y: 0.42), .init(x: 0.36, y: 0.68)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["里面一撇"], direction: "↙"),
            StrokeSpec(id: "k_feng_4", name: "点",
                       points: [.init(x: 0.56, y: 0.44), .init(x: 0.66, y: 0.62)],
                       widthStart: 0.03, widthEnd: 0.09,
                       tips: ["里面一点"], direction: "●")
        ]
    )

    static let 花 = CharacterDef(
        id: "kid:花", glyph: "花", level: 0,
        title: "花", subtitle: "漂亮的小花",
        strokes: [
            StrokeSpec(id: "k_hua_1", name: "横",
                       points: [.init(x: 0.18, y: 0.28), .init(x: 0.82, y: 0.28)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["草字头一横"], direction: "→"),
            StrokeSpec(id: "k_hua_2", name: "竖",
                       points: [.init(x: 0.32, y: 0.18), .init(x: 0.32, y: 0.38)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["草字头左竖"], direction: "↓"),
            StrokeSpec(id: "k_hua_3", name: "竖",
                       points: [.init(x: 0.68, y: 0.18), .init(x: 0.68, y: 0.38)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["草字头右竖"], direction: "↓"),
            StrokeSpec(id: "k_hua_4", name: "撇",
                       points: [.init(x: 0.40, y: 0.44),
                                .init(x: 0.22, y: 0.84)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["长撇"], direction: "↙"),
            StrokeSpec(id: "k_hua_5", name: "竖",
                       points: [.init(x: 0.44, y: 0.56), .init(x: 0.44, y: 0.82)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间一竖"], direction: "↓"),
            StrokeSpec(id: "k_hua_6", name: "横",
                       points: [.init(x: 0.44, y: 0.56), .init(x: 0.80, y: 0.56)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["横一笔"], direction: "→"),
            StrokeSpec(id: "k_hua_7", name: "竖弯钩",
                       points: [.init(x: 0.70, y: 0.44),
                                .init(x: 0.70, y: 0.80),
                                .init(x: 0.84, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["竖弯钩"], direction: "↓↗")
        ]
    )

    static let 草 = CharacterDef(
        id: "kid:草", glyph: "草", level: 0,
        title: "草", subtitle: "小草绿油油",
        strokes: [
            StrokeSpec(id: "k_cao_1", name: "横",
                       points: [.init(x: 0.18, y: 0.22), .init(x: 0.82, y: 0.22)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["草字头一横"], direction: "→"),
            StrokeSpec(id: "k_cao_2", name: "竖",
                       points: [.init(x: 0.32, y: 0.14), .init(x: 0.32, y: 0.30)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["草字头左竖"], direction: "↓"),
            StrokeSpec(id: "k_cao_3", name: "竖",
                       points: [.init(x: 0.68, y: 0.14), .init(x: 0.68, y: 0.30)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["草字头右竖"], direction: "↓"),
            StrokeSpec(id: "k_cao_4", name: "竖",
                       points: [.init(x: 0.26, y: 0.38), .init(x: 0.26, y: 0.64)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["日字左竖"], direction: "↓"),
            StrokeSpec(id: "k_cao_5", name: "横折",
                       points: [.init(x: 0.26, y: 0.38),
                                .init(x: 0.74, y: 0.38),
                                .init(x: 0.74, y: 0.64)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["日字横折"], direction: "→↓"),
            StrokeSpec(id: "k_cao_6", name: "横",
                       points: [.init(x: 0.26, y: 0.52), .init(x: 0.74, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["日字中横"], direction: "→"),
            StrokeSpec(id: "k_cao_7", name: "横",
                       points: [.init(x: 0.14, y: 0.72), .init(x: 0.86, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["下面长横"], direction: "→"),
            StrokeSpec(id: "k_cao_8", name: "竖",
                       points: [.init(x: 0.50, y: 0.64), .init(x: 0.50, y: 0.88)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["最后一长竖"], direction: "↓")
        ]
    )

    static let 鱼 = CharacterDef(
        id: "kid:鱼", glyph: "鱼", level: 0,
        title: "鱼", subtitle: "水里游的鱼",
        strokes: [
            StrokeSpec(id: "k_yu2_1", name: "撇",
                       points: [.init(x: 0.52, y: 0.12),
                                .init(x: 0.34, y: 0.26)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["先写一撇"], direction: "↙"),
            StrokeSpec(id: "k_yu2_2", name: "横撇",
                       points: [.init(x: 0.34, y: 0.26),
                                .init(x: 0.66, y: 0.26),
                                .init(x: 0.50, y: 0.38)],
                       widthStart: 0.05, widthEnd: 0.03,
                       tips: ["横撇"], direction: "→↙"),
            StrokeSpec(id: "k_yu2_3", name: "竖",
                       points: [.init(x: 0.30, y: 0.38), .init(x: 0.30, y: 0.66)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["田字左竖"], direction: "↓"),
            StrokeSpec(id: "k_yu2_4", name: "横折",
                       points: [.init(x: 0.30, y: 0.38),
                                .init(x: 0.70, y: 0.38),
                                .init(x: 0.70, y: 0.66)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["田字横折"], direction: "→↓"),
            StrokeSpec(id: "k_yu2_5", name: "横",
                       points: [.init(x: 0.30, y: 0.52), .init(x: 0.70, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["田中一横"], direction: "→"),
            StrokeSpec(id: "k_yu2_6", name: "横",
                       points: [.init(x: 0.30, y: 0.66), .init(x: 0.70, y: 0.66)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["田封底一横"], direction: "→"),
            StrokeSpec(id: "k_yu2_7", name: "长横",
                       points: [.init(x: 0.14, y: 0.82), .init(x: 0.86, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横托底"], direction: "→")
        ]
    )

    // ─── Pack 3 · 身体 ──────────────────────────────

    static let 头 = CharacterDef(
        id: "kid:头", glyph: "头", level: 0,
        title: "头", subtitle: "我的小脑袋",
        strokes: [
            StrokeSpec(id: "k_tou_1", name: "点",
                       points: [.init(x: 0.30, y: 0.20), .init(x: 0.36, y: 0.32)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["左上一点"], direction: "●"),
            StrokeSpec(id: "k_tou_2", name: "点",
                       points: [.init(x: 0.68, y: 0.20), .init(x: 0.62, y: 0.32)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["右上一点"], direction: "●"),
            StrokeSpec(id: "k_tou_3", name: "长横",
                       points: [.init(x: 0.16, y: 0.48), .init(x: 0.84, y: 0.48)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["中间长横"], direction: "→"),
            StrokeSpec(id: "k_tou_4", name: "撇",
                       points: [.init(x: 0.52, y: 0.48),
                                .init(x: 0.22, y: 0.84)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["左撇"], direction: "↙"),
            StrokeSpec(id: "k_tou_5", name: "点",
                       points: [.init(x: 0.62, y: 0.58), .init(x: 0.78, y: 0.82)],
                       widthStart: 0.03, widthEnd: 0.10,
                       tips: ["右下一点"], direction: "●")
        ]
    )

    static let 耳 = CharacterDef(
        id: "kid:耳", glyph: "耳", level: 0,
        title: "耳", subtitle: "像一只耳朵",
        strokes: [
            StrokeSpec(id: "k_er_1", name: "横",
                       points: [.init(x: 0.24, y: 0.22), .init(x: 0.76, y: 0.22)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["先写一横"], direction: "→"),
            StrokeSpec(id: "k_er_2", name: "竖",
                       points: [.init(x: 0.30, y: 0.22), .init(x: 0.30, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["左竖"], direction: "↓"),
            StrokeSpec(id: "k_er_3", name: "竖",
                       points: [.init(x: 0.70, y: 0.22), .init(x: 0.70, y: 0.78)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["右竖"], direction: "↓"),
            StrokeSpec(id: "k_er_4", name: "横",
                       points: [.init(x: 0.30, y: 0.42), .init(x: 0.70, y: 0.42)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间一横"], direction: "→"),
            StrokeSpec(id: "k_er_5", name: "横",
                       points: [.init(x: 0.30, y: 0.60), .init(x: 0.70, y: 0.60)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间一横"], direction: "→"),
            StrokeSpec(id: "k_er_6", name: "长横",
                       points: [.init(x: 0.14, y: 0.80), .init(x: 0.86, y: 0.80)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    static let 目 = CharacterDef(
        id: "kid:目", glyph: "目", level: 0,
        title: "目", subtitle: "像一只眼睛",
        strokes: [
            StrokeSpec(id: "k_mu2_1", name: "竖",
                       points: [.init(x: 0.30, y: 0.16), .init(x: 0.30, y: 0.84)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写左竖"], direction: "↓"),
            StrokeSpec(id: "k_mu2_2", name: "横折",
                       points: [.init(x: 0.30, y: 0.16),
                                .init(x: 0.70, y: 0.16),
                                .init(x: 0.70, y: 0.84)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["横折包一包"], direction: "→↓"),
            StrokeSpec(id: "k_mu2_3", name: "横",
                       points: [.init(x: 0.30, y: 0.38), .init(x: 0.70, y: 0.38)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["里面一横"], direction: "→"),
            StrokeSpec(id: "k_mu2_4", name: "横",
                       points: [.init(x: 0.30, y: 0.60), .init(x: 0.70, y: 0.60)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["里面一横"], direction: "→"),
            StrokeSpec(id: "k_mu2_5", name: "横",
                       points: [.init(x: 0.30, y: 0.84), .init(x: 0.70, y: 0.84)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["封底一横"], direction: "→")
        ]
    )

    static let 手 = CharacterDef(
        id: "kid:手", glyph: "手", level: 0,
        title: "手", subtitle: "我的小手手",
        strokes: [
            StrokeSpec(id: "k_shou_1", name: "撇",
                       points: [.init(x: 0.70, y: 0.18),
                                .init(x: 0.22, y: 0.32)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["先写一短撇"], direction: "↙"),
            StrokeSpec(id: "k_shou_2", name: "横",
                       points: [.init(x: 0.18, y: 0.38), .init(x: 0.82, y: 0.38)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["上面一横"], direction: "→"),
            StrokeSpec(id: "k_shou_3", name: "横",
                       points: [.init(x: 0.14, y: 0.58), .init(x: 0.86, y: 0.58)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["中间长横"], direction: "→"),
            StrokeSpec(id: "k_shou_4", name: "竖钩",
                       points: [.init(x: 0.50, y: 0.24),
                                .init(x: 0.50, y: 0.82),
                                .init(x: 0.40, y: 0.74)],
                       widthStart: 0.07, widthEnd: 0.03,
                       tips: ["中间一竖钩"], direction: "↓↖")
        ]
    )

    static let 足 = CharacterDef(
        id: "kid:足", glyph: "足", level: 0,
        title: "足", subtitle: "我的小脚丫",
        strokes: [
            StrokeSpec(id: "k_zu_1", name: "竖",
                       points: [.init(x: 0.32, y: 0.18), .init(x: 0.32, y: 0.52)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["口字左竖"], direction: "↓"),
            StrokeSpec(id: "k_zu_2", name: "横折",
                       points: [.init(x: 0.32, y: 0.18),
                                .init(x: 0.68, y: 0.18),
                                .init(x: 0.68, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["口字横折"], direction: "→↓"),
            StrokeSpec(id: "k_zu_3", name: "横",
                       points: [.init(x: 0.32, y: 0.52), .init(x: 0.68, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["口字封底"], direction: "→"),
            StrokeSpec(id: "k_zu_4", name: "竖",
                       points: [.init(x: 0.42, y: 0.52), .init(x: 0.42, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["下边一竖"], direction: "↓"),
            StrokeSpec(id: "k_zu_5", name: "横",
                       points: [.init(x: 0.16, y: 0.72), .init(x: 0.60, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["下边一横"], direction: "→"),
            StrokeSpec(id: "k_zu_6", name: "撇",
                       points: [.init(x: 0.50, y: 0.60),
                                .init(x: 0.28, y: 0.86)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["一撇"], direction: "↙"),
            StrokeSpec(id: "k_zu_7", name: "捺",
                       points: [.init(x: 0.50, y: 0.66),
                                .init(x: 0.84, y: 0.86)],
                       widthStart: 0.03, widthEnd: 0.11,
                       tips: ["一捺"], direction: "↘")
        ]
    )

    static let 心 = CharacterDef(
        id: "kid:心", glyph: "心", level: 0,
        title: "心", subtitle: "爱心一颗",
        strokes: [
            StrokeSpec(id: "k_xin_1", name: "点",
                       points: [.init(x: 0.22, y: 0.38), .init(x: 0.28, y: 0.52)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["左点"], direction: "●"),
            StrokeSpec(id: "k_xin_2", name: "卧钩",
                       points: [.init(x: 0.30, y: 0.56),
                                .init(x: 0.50, y: 0.80),
                                .init(x: 0.78, y: 0.70),
                                .init(x: 0.70, y: 0.56)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["卧钩像小船"], direction: "↘↗"),
            StrokeSpec(id: "k_xin_3", name: "点",
                       points: [.init(x: 0.48, y: 0.38), .init(x: 0.52, y: 0.52)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["中间一点"], direction: "●"),
            StrokeSpec(id: "k_xin_4", name: "点",
                       points: [.init(x: 0.72, y: 0.30), .init(x: 0.78, y: 0.46)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["右上一点"], direction: "●")
        ]
    )

    // ─── Pack 4 · 动物 ──────────────────────────────

    static let 牛 = CharacterDef(
        id: "kid:牛", glyph: "牛", level: 0,
        title: "牛", subtitle: "哞哞的小牛",
        strokes: [
            StrokeSpec(id: "k_niu_1", name: "撇",
                       points: [.init(x: 0.52, y: 0.20),
                                .init(x: 0.28, y: 0.40)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["先写一撇"], direction: "↙"),
            StrokeSpec(id: "k_niu_2", name: "短横",
                       points: [.init(x: 0.28, y: 0.40), .init(x: 0.72, y: 0.40)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["上面短横"], direction: "→"),
            StrokeSpec(id: "k_niu_3", name: "长横",
                       points: [.init(x: 0.14, y: 0.60), .init(x: 0.86, y: 0.60)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["下面长横"], direction: "→"),
            StrokeSpec(id: "k_niu_4", name: "竖",
                       points: [.init(x: 0.52, y: 0.32), .init(x: 0.52, y: 0.86)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["最后一长竖"], direction: "↓")
        ]
    )

    static let 羊 = CharacterDef(
        id: "kid:羊", glyph: "羊", level: 0,
        title: "羊", subtitle: "咩咩的小羊",
        strokes: [
            StrokeSpec(id: "k_yang_1", name: "点",
                       points: [.init(x: 0.36, y: 0.18), .init(x: 0.30, y: 0.30)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["左点（羊角）"], direction: "●"),
            StrokeSpec(id: "k_yang_2", name: "撇",
                       points: [.init(x: 0.64, y: 0.18), .init(x: 0.70, y: 0.30)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["右撇（羊角）"], direction: "↙"),
            StrokeSpec(id: "k_yang_3", name: "横",
                       points: [.init(x: 0.24, y: 0.38), .init(x: 0.76, y: 0.38)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["第一横"], direction: "→"),
            StrokeSpec(id: "k_yang_4", name: "横",
                       points: [.init(x: 0.20, y: 0.54), .init(x: 0.80, y: 0.54)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["第二横"], direction: "→"),
            StrokeSpec(id: "k_yang_5", name: "横",
                       points: [.init(x: 0.14, y: 0.70), .init(x: 0.86, y: 0.70)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["第三横最长"], direction: "→"),
            StrokeSpec(id: "k_yang_6", name: "竖",
                       points: [.init(x: 0.50, y: 0.38), .init(x: 0.50, y: 0.88)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["中间一长竖"], direction: "↓")
        ]
    )

    static let 马 = CharacterDef(
        id: "kid:马", glyph: "马", level: 0,
        title: "马", subtitle: "小马跑起来",
        strokes: [
            StrokeSpec(id: "k_ma_1", name: "横折",
                       points: [.init(x: 0.30, y: 0.24),
                                .init(x: 0.70, y: 0.24),
                                .init(x: 0.70, y: 0.46)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["横折一下"], direction: "→↓"),
            StrokeSpec(id: "k_ma_2", name: "竖折折钩",
                       points: [.init(x: 0.30, y: 0.24),
                                .init(x: 0.30, y: 0.48),
                                .init(x: 0.78, y: 0.48),
                                .init(x: 0.78, y: 0.72),
                                .init(x: 0.64, y: 0.64)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["竖折折钩一笔写"], direction: "↓→↓↖"),
            StrokeSpec(id: "k_ma_3", name: "长横",
                       points: [.init(x: 0.14, y: 0.76), .init(x: 0.86, y: 0.76)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    static let 鸟 = CharacterDef(
        id: "kid:鸟", glyph: "鸟", level: 0,
        title: "鸟", subtitle: "天上飞的鸟",
        strokes: [
            StrokeSpec(id: "k_niao_1", name: "撇",
                       points: [.init(x: 0.56, y: 0.14),
                                .init(x: 0.34, y: 0.28)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["先写一撇"], direction: "↙"),
            StrokeSpec(id: "k_niao_2", name: "横折钩",
                       points: [.init(x: 0.34, y: 0.28),
                                .init(x: 0.72, y: 0.28),
                                .init(x: 0.72, y: 0.48),
                                .init(x: 0.60, y: 0.40)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["横折钩画头"], direction: "→↓↖"),
            StrokeSpec(id: "k_niao_3", name: "点",
                       points: [.init(x: 0.58, y: 0.36), .init(x: 0.62, y: 0.42)],
                       widthStart: 0.03, widthEnd: 0.06,
                       tips: ["眼睛一点"], direction: "●"),
            StrokeSpec(id: "k_niao_4", name: "竖折折钩",
                       points: [.init(x: 0.34, y: 0.40),
                                .init(x: 0.34, y: 0.62),
                                .init(x: 0.78, y: 0.62),
                                .init(x: 0.78, y: 0.78),
                                .init(x: 0.62, y: 0.72)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["竖折折钩"], direction: "↓→↓↖"),
            StrokeSpec(id: "k_niao_5", name: "长横",
                       points: [.init(x: 0.14, y: 0.84), .init(x: 0.86, y: 0.84)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    static let 虫 = CharacterDef(
        id: "kid:虫", glyph: "虫", level: 0,
        title: "虫", subtitle: "小小虫子爬",
        strokes: [
            StrokeSpec(id: "k_chong_1", name: "竖",
                       points: [.init(x: 0.50, y: 0.16), .init(x: 0.50, y: 0.58)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写一竖"], direction: "↓"),
            StrokeSpec(id: "k_chong_2", name: "横折",
                       points: [.init(x: 0.30, y: 0.30),
                                .init(x: 0.70, y: 0.30),
                                .init(x: 0.70, y: 0.58)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["口字横折"], direction: "→↓"),
            StrokeSpec(id: "k_chong_3", name: "横",
                       points: [.init(x: 0.30, y: 0.30), .init(x: 0.30, y: 0.58)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["口字左竖"], direction: "↓"),
            StrokeSpec(id: "k_chong_4", name: "横",
                       points: [.init(x: 0.30, y: 0.58), .init(x: 0.70, y: 0.58)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["口字封底"], direction: "→"),
            StrokeSpec(id: "k_chong_5", name: "长横",
                       points: [.init(x: 0.14, y: 0.74), .init(x: 0.86, y: 0.74)],
                       widthStart: 0.07, widthEnd: 0.07,
                       tips: ["下面长横"], direction: "→"),
            StrokeSpec(id: "k_chong_6", name: "点",
                       points: [.init(x: 0.66, y: 0.78), .init(x: 0.78, y: 0.88)],
                       widthStart: 0.03, widthEnd: 0.09,
                       tips: ["右下一点"], direction: "●")
        ]
    )

    static let 兔 = CharacterDef(
        id: "kid:兔", glyph: "兔", level: 0,
        title: "兔", subtitle: "蹦蹦跳的小兔",
        strokes: [
            StrokeSpec(id: "k_tu2_1", name: "撇",
                       points: [.init(x: 0.50, y: 0.14),
                                .init(x: 0.34, y: 0.24)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["先写一撇"], direction: "↙"),
            StrokeSpec(id: "k_tu2_2", name: "竖",
                       points: [.init(x: 0.34, y: 0.24), .init(x: 0.34, y: 0.52)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["左竖"], direction: "↓"),
            StrokeSpec(id: "k_tu2_3", name: "横折",
                       points: [.init(x: 0.34, y: 0.24),
                                .init(x: 0.68, y: 0.24),
                                .init(x: 0.68, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["横折一下"], direction: "→↓"),
            StrokeSpec(id: "k_tu2_4", name: "横",
                       points: [.init(x: 0.34, y: 0.40), .init(x: 0.68, y: 0.40)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["中间一横"], direction: "→"),
            StrokeSpec(id: "k_tu2_5", name: "横",
                       points: [.init(x: 0.34, y: 0.52), .init(x: 0.68, y: 0.52)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["封底一横"], direction: "→"),
            StrokeSpec(id: "k_tu2_6", name: "撇",
                       points: [.init(x: 0.40, y: 0.52),
                                .init(x: 0.22, y: 0.82)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["长撇"], direction: "↙"),
            StrokeSpec(id: "k_tu2_7", name: "竖弯钩",
                       points: [.init(x: 0.56, y: 0.52),
                                .init(x: 0.56, y: 0.80),
                                .init(x: 0.84, y: 0.80),
                                .init(x: 0.82, y: 0.70)],
                       widthStart: 0.06, widthEnd: 0.03,
                       tips: ["竖弯钩像尾巴"], direction: "↓→↑"),
            StrokeSpec(id: "k_tu2_8", name: "点",
                       points: [.init(x: 0.74, y: 0.36), .init(x: 0.84, y: 0.46)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["右上一点"], direction: "●")
        ]
    )

    // ─── Pack 5 · 动作方位 ──────────────────────────────

    static let 左 = CharacterDef(
        id: "kid:左", glyph: "左", level: 0,
        title: "左", subtitle: "左边的左",
        strokes: [
            StrokeSpec(id: "k_zuo_1", name: "横",
                       points: [.init(x: 0.20, y: 0.34), .init(x: 0.74, y: 0.34)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["先写一横"], direction: "→"),
            StrokeSpec(id: "k_zuo_2", name: "撇",
                       points: [.init(x: 0.52, y: 0.22),
                                .init(x: 0.18, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["再写长撇"], direction: "↙"),
            StrokeSpec(id: "k_zuo_3", name: "横",
                       points: [.init(x: 0.30, y: 0.58), .init(x: 0.80, y: 0.58)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["工字上横"], direction: "→"),
            StrokeSpec(id: "k_zuo_4", name: "竖",
                       points: [.init(x: 0.54, y: 0.58), .init(x: 0.54, y: 0.80)],
                       widthStart: 0.06, widthEnd: 0.05,
                       tips: ["工字中竖"], direction: "↓"),
            StrokeSpec(id: "k_zuo_5", name: "长横",
                       points: [.init(x: 0.22, y: 0.82), .init(x: 0.86, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    static let 右 = CharacterDef(
        id: "kid:右", glyph: "右", level: 0,
        title: "右", subtitle: "右边的右",
        strokes: [
            StrokeSpec(id: "k_you_1", name: "横",
                       points: [.init(x: 0.20, y: 0.34), .init(x: 0.74, y: 0.34)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["先写一横"], direction: "→"),
            StrokeSpec(id: "k_you_2", name: "撇",
                       points: [.init(x: 0.52, y: 0.22),
                                .init(x: 0.18, y: 0.82)],
                       widthStart: 0.07, widthEnd: 0.02,
                       tips: ["再写长撇"], direction: "↙"),
            StrokeSpec(id: "k_you_3", name: "竖",
                       points: [.init(x: 0.34, y: 0.56), .init(x: 0.34, y: 0.82)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["口字左竖"], direction: "↓"),
            StrokeSpec(id: "k_you_4", name: "横折",
                       points: [.init(x: 0.34, y: 0.56),
                                .init(x: 0.80, y: 0.56),
                                .init(x: 0.80, y: 0.82)],
                       widthStart: 0.05, widthEnd: 0.05,
                       tips: ["口字横折"], direction: "→↓"),
            StrokeSpec(id: "k_you_5", name: "横",
                       points: [.init(x: 0.34, y: 0.82), .init(x: 0.80, y: 0.82)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["口字封底"], direction: "→")
        ]
    )

    static let 入 = CharacterDef(
        id: "kid:入", glyph: "入", level: 0,
        title: "入", subtitle: "走进来",
        strokes: [
            StrokeSpec(id: "k_ru_1", name: "撇",
                       points: [.init(x: 0.56, y: 0.20),
                                .init(x: 0.46, y: 0.46),
                                .init(x: 0.18, y: 0.84)],
                       widthStart: 0.08, widthEnd: 0.02,
                       tips: ["左边长撇"], direction: "↙"),
            StrokeSpec(id: "k_ru_2", name: "捺",
                       points: [.init(x: 0.46, y: 0.46),
                                .init(x: 0.82, y: 0.84)],
                       widthStart: 0.03, widthEnd: 0.11,
                       tips: ["右边一捺"], direction: "↘")
        ]
    )

    static let 出 = CharacterDef(
        id: "kid:出", glyph: "出", level: 0,
        title: "出", subtitle: "走出去",
        strokes: [
            StrokeSpec(id: "k_chu_1", name: "竖",
                       points: [.init(x: 0.50, y: 0.14), .init(x: 0.50, y: 0.86)],
                       widthStart: 0.07, widthEnd: 0.06,
                       tips: ["先写中间长竖"], direction: "↓"),
            StrokeSpec(id: "k_chu_2", name: "竖折",
                       points: [.init(x: 0.34, y: 0.30),
                                .init(x: 0.34, y: 0.58),
                                .init(x: 0.66, y: 0.58)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["上半竖折"], direction: "↓→"),
            StrokeSpec(id: "k_chu_3", name: "竖",
                       points: [.init(x: 0.66, y: 0.32), .init(x: 0.66, y: 0.58)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["上半右竖"], direction: "↓"),
            StrokeSpec(id: "k_chu_4", name: "竖折",
                       points: [.init(x: 0.22, y: 0.58),
                                .init(x: 0.22, y: 0.86),
                                .init(x: 0.78, y: 0.86)],
                       widthStart: 0.07, widthEnd: 0.07,
                       tips: ["下半竖折"], direction: "↓→"),
            StrokeSpec(id: "k_chu_5", name: "竖",
                       points: [.init(x: 0.78, y: 0.58), .init(x: 0.78, y: 0.86)],
                       widthStart: 0.06, widthEnd: 0.06,
                       tips: ["下半右竖"], direction: "↓")
        ]
    )

    static let 立 = CharacterDef(
        id: "kid:立", glyph: "立", level: 0,
        title: "立", subtitle: "站得直直的",
        strokes: [
            StrokeSpec(id: "k_li_1", name: "点",
                       points: [.init(x: 0.48, y: 0.18), .init(x: 0.52, y: 0.28)],
                       widthStart: 0.03, widthEnd: 0.08,
                       tips: ["上面一点"], direction: "●"),
            StrokeSpec(id: "k_li_2", name: "横",
                       points: [.init(x: 0.24, y: 0.36), .init(x: 0.76, y: 0.36)],
                       widthStart: 0.06, widthEnd: 0.07,
                       tips: ["上面一横"], direction: "→"),
            StrokeSpec(id: "k_li_3", name: "点",
                       points: [.init(x: 0.30, y: 0.50), .init(x: 0.24, y: 0.64)],
                       widthStart: 0.03, widthEnd: 0.07,
                       tips: ["左点"], direction: "●"),
            StrokeSpec(id: "k_li_4", name: "撇",
                       points: [.init(x: 0.70, y: 0.50), .init(x: 0.76, y: 0.64)],
                       widthStart: 0.06, widthEnd: 0.02,
                       tips: ["右撇"], direction: "↙"),
            StrokeSpec(id: "k_li_5", name: "长横",
                       points: [.init(x: 0.14, y: 0.80), .init(x: 0.86, y: 0.80)],
                       widthStart: 0.07, widthEnd: 0.08,
                       tips: ["最后长横"], direction: "→")
        ]
    )

    // ─── 分组 ──────────────────────────────────────

    static let groups: [(title: String, chars: [CharacterDef])] = [
        ("数字续 · 四五六七九", [四, 五, 六, 七, 九]),
        ("自然 · 天雨云雪风花草鱼", [天, 雨, 云, 雪, 风, 花, 草, 鱼]),
        ("身体 · 头耳目手足心", [头, 耳, 目, 手, 足, 心]),
        ("动物 · 牛羊马鸟虫兔", [牛, 羊, 马, 鸟, 虫, 兔]),
        ("动作方位 · 左右入出立", [左, 右, 入, 出, 立])
    ]

    /// 扁平全部 30 字，按学习顺序
    static var all: [CharacterDef] {
        groups.flatMap { $0.chars }
    }

    // ─── 元数据：pinyin / emoji / meaning / sticker / cheer ─────

    static let meta: [String: KidsCharacters.Meta] = [
        // Pack 1 · 数字续
        "kid:四": .init(pinyin: "sì",   emoji: "4️⃣", meaning: "四季",   sticker: "🍀", cheer: nil),
        "kid:五": .init(pinyin: "wǔ",   emoji: "5️⃣", meaning: "五指",   sticker: "🖐️", cheer: "五个手指头!"),
        "kid:六": .init(pinyin: "liù",  emoji: "6️⃣", meaning: "六月",   sticker: "🎲", cheer: nil),
        "kid:七": .init(pinyin: "qī",   emoji: "7️⃣", meaning: "七彩",   sticker: "🌈", cheer: nil),
        "kid:九": .init(pinyin: "jiǔ",  emoji: "9️⃣", meaning: "九州",   sticker: "🎐", cheer: nil),

        // Pack 2 · 自然
        "kid:天": .init(pinyin: "tiān", emoji: "🌤️", meaning: "天空",   sticker: "☁️", cheer: "天好蓝啊!"),
        "kid:雨": .init(pinyin: "yǔ",   emoji: "🌧️", meaning: "下雨",   sticker: "☔", cheer: "下雨啦~"),
        "kid:云": .init(pinyin: "yún",  emoji: "☁️",  meaning: "白云",   sticker: "☁️", cheer: nil),
        "kid:雪": .init(pinyin: "xuě",  emoji: "❄️",  meaning: "雪花",   sticker: "⛄", cheer: "雪花飘啦!"),
        "kid:风": .init(pinyin: "fēng", emoji: "🌬️", meaning: "刮风",   sticker: "🍃", cheer: nil),
        "kid:花": .init(pinyin: "huā",  emoji: "🌸",  meaning: "小花",   sticker: "🌷", cheer: "🌸 花开啦!"),
        "kid:草": .init(pinyin: "cǎo",  emoji: "🌱",  meaning: "小草",   sticker: "🍀", cheer: nil),
        "kid:鱼": .init(pinyin: "yú",   emoji: "🐟",  meaning: "小鱼",   sticker: "🐠", cheer: "鱼儿游啊游~"),

        // Pack 3 · 身体
        "kid:头": .init(pinyin: "tóu",  emoji: "🧠",  meaning: "脑袋",   sticker: "👶", cheer: nil),
        "kid:耳": .init(pinyin: "ěr",   emoji: "👂",  meaning: "耳朵",   sticker: "👂", cheer: nil),
        "kid:目": .init(pinyin: "mù",   emoji: "👁️", meaning: "眼睛",   sticker: "👀", cheer: "眼睛亮晶晶!"),
        "kid:手": .init(pinyin: "shǒu", emoji: "✋",  meaning: "小手",   sticker: "🙌", cheer: nil),
        "kid:足": .init(pinyin: "zú",   emoji: "🦶",  meaning: "脚丫",   sticker: "👣", cheer: nil),
        "kid:心": .init(pinyin: "xīn",  emoji: "❤️",  meaning: "爱心",   sticker: "💖", cheer: "爱心满满!"),

        // Pack 4 · 动物
        "kid:牛": .init(pinyin: "niú",  emoji: "🐄",  meaning: "小牛",   sticker: "🐄", cheer: nil),
        "kid:羊": .init(pinyin: "yáng", emoji: "🐑",  meaning: "小羊",   sticker: "🐑", cheer: "咩咩叫~"),
        "kid:马": .init(pinyin: "mǎ",   emoji: "🐴",  meaning: "小马",   sticker: "🐎", cheer: nil),
        "kid:鸟": .init(pinyin: "niǎo", emoji: "🐦",  meaning: "小鸟",   sticker: "🐤", cheer: "小鸟飞高高!"),
        "kid:虫": .init(pinyin: "chóng",emoji: "🐛",  meaning: "虫子",   sticker: "🐞", cheer: nil),
        "kid:兔": .init(pinyin: "tù",   emoji: "🐰",  meaning: "小兔",   sticker: "🐇", cheer: "蹦蹦跳跳~"),

        // Pack 5 · 动作方位
        "kid:左": .init(pinyin: "zuǒ",  emoji: "⬅️",  meaning: "左边",   sticker: "👈", cheer: nil),
        "kid:右": .init(pinyin: "yòu",  emoji: "➡️",  meaning: "右边",   sticker: "👉", cheer: nil),
        "kid:入": .init(pinyin: "rù",   emoji: "🚪",  meaning: "进入",   sticker: "🚶", cheer: nil),
        "kid:出": .init(pinyin: "chū",  emoji: "🏃",  meaning: "出去",   sticker: "🚀", cheer: "出发咯!"),
        "kid:立": .init(pinyin: "lì",   emoji: "🧍",  meaning: "站立",   sticker: "🗿", cheer: nil)
    ]

    static func metaFor(_ id: String) -> KidsCharacters.Meta? { meta[id] }
}
