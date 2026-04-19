import Foundation
import CoreGraphics

// ─────────────────────────────────────────────────────────────────
// MARK: - 评分结果
// ─────────────────────────────────────────────────────────────────

struct ScoreResult {
    let total: Int      // 0..100
    let shape: Int      // 形
    let order: Int      // 顺
    let fluency: Int    // 势
    let layout: Int     // 距
    let feedback: FeedbackMessage
}

struct FeedbackMessage {
    let praise: String          // 总评，一句话
    let suggestions: [String]   // 最多 3 条可执行建议
    let emoji: String
}

// ─────────────────────────────────────────────────────────────────
// MARK: - ScoringEngine（端侧、几何特征，无需 ML）
// ─────────────────────────────────────────────────────────────────

enum ScoringEngine {

    /// 对用户书写的一组笔画评分
    /// - Parameters:
    ///   - user: 用户的笔画（归一化 0-1 坐标）
    ///   - character: 标准字形定义
    static func score(user: [UserStroke], character: CharacterDef) -> ScoreResult? {
        guard !user.isEmpty else { return nil }
        let std = character.strokes
        guard !std.isEmpty else { return nil }

        let shape   = shapeSimilarity(user: user, std: std)
        let order   = strokeOrderMatch(user: user, std: std)
        let fluency = strokeFluency(user: user)
        let layout  = layoutAccuracy(user: user, std: std)

        var total = Int((
            Double(shape)   * 0.45 +
            Double(order)   * 0.20 +
            Double(fluency) * 0.20 +
            Double(layout)  * 0.15
        ).rounded())

        // 封顶机制：如果位置/尺寸明显跑偏，总分不应虚高
        // 否则用户会误以为"写得差不多"而持续错练
        if layout < 30 { total = min(total, 55) }
        else if layout < 45 { total = min(total, 72) }
        // 单一维度塌方（如形 < 35）也不允许总分超过 68
        if shape < 35 { total = min(total, 68) }

        let fb = makeFeedback(
            total: total, shape: shape, order: order,
            fluency: fluency, layout: layout,
            userStrokeCount: user.count, stdStrokeCount: std.count
        )

        return ScoreResult(
            total: clamp(total),
            shape: clamp(shape),
            order: clamp(order),
            fluency: clamp(fluency),
            layout: clamp(layout),
            feedback: fb
        )
    }

    // ─── ① 形 Shape Similarity ──────────────────────────────────────
    /// 用原始位置的对称 Chamfer 距离评分。
    ///
    /// 为什么不做 Procrustes 对齐？
    /// 因为米字格本身就是统一的 [0,1] 坐标，"写在哪里"本身就是正确性的一部分。
    /// 原先对齐的版本会把一个"拉长很多的点"和"标准小点"都拉满归一化盒子，
    /// 导致方向对就得高分，即使长度/位置全错。
    private static func shapeSimilarity(user: [UserStroke], std: [StrokeSpec]) -> Int {
        let userPts = user.flatMap { $0.points.map { CGPoint(x: $0.x, y: $0.y) } }
        let stdPts = std.flatMap { StrokePath.sample($0.points, count: 64) }
        guard !userPts.isEmpty, !stdPts.isEmpty else { return 50 }

        // 对称 Chamfer 距离（均值最近邻）
        // d1 度量"用户每个点有多接近标准笔迹"
        // d2 度量"标准每个点有多接近用户笔迹"（防止用户漏画某段）
        let d1 = meanNearest(userPts, to: stdPts)
        let d2 = meanNearest(stdPts, to: userPts)
        let chamfer = (d1 + d2) / 2  // 典型值 0.02 ~ 0.30

        // 映射：0.00 → 100 分；0.05 → 80 分；0.15 → 40 分；≥0.25 → 0 分
        let score = Int((100 - chamfer * 400).rounded())
        return clamp(score)
    }

    private static func meanNearest(_ a: [CGPoint], to b: [CGPoint]) -> CGFloat {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        var total: CGFloat = 0
        for p in a {
            var best: CGFloat = .greatestFiniteMagnitude
            for q in b {
                let dx = p.x - q.x, dy = p.y - q.y
                let d = dx*dx + dy*dy
                if d < best { best = d }
            }
            total += sqrt(best)
        }
        return total / CGFloat(a.count)
    }

    // ─── ② 顺 Stroke Order ────────────────────────────────────────
    /// 对比用户每一笔的主方向向量与标准笔画的主方向向量
    private static func strokeOrderMatch(user: [UserStroke], std: [StrokeSpec]) -> Int {
        let expected = std.count
        let actual = user.count
        // 笔画数量惩罚（至关重要）
        let countPenalty = abs(actual - expected) * 22

        let n = min(actual, expected)
        var dirOK = 0
        for i in 0..<n {
            let uDir = directionVector(for: user[i].points.map { CGPoint(x: $0.x, y: $0.y) })
            let sDir = directionVector(
                for: StrokePath.sample(std[i].points, count: 16)
            )
            if cosineSim(uDir, sDir) > 0.7 { dirOK += 1 }
        }
        let dirScore = expected > 0 ? (dirOK * 100) / expected : 0
        return clamp(dirScore - countPenalty)
    }

    private static func directionVector(for pts: [CGPoint]) -> CGPoint {
        guard let first = pts.first, let last = pts.last, pts.count >= 2 else {
            return .init(x: 1, y: 0)
        }
        return CGPoint(x: last.x - first.x, y: last.y - first.y)
    }

    private static func cosineSim(_ a: CGPoint, _ b: CGPoint) -> Double {
        let na = sqrt(a.x * a.x + a.y * a.y)
        let nb = sqrt(b.x * b.x + b.y * b.y)
        guard na > 0.001, nb > 0.001 else { return 0 }
        return Double((a.x * b.x + a.y * b.y) / (na * nb))
    }

    // ─── ③ 势 Fluency ─────────────────────────────────────────────
    /// 速度的变异系数（越稳越高分）+ 停顿检测
    private static func strokeFluency(user: [UserStroke]) -> Int {
        var cvs: [Double] = []
        var stallCount = 0
        for s in user {
            let pts = s.points
            guard pts.count >= 4 else { continue }
            var speeds: [Double] = []
            for i in 1..<pts.count {
                let dt = max(0.001, pts[i].timeOffset - pts[i - 1].timeOffset)
                let dd = hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y)
                speeds.append(Double(dd) / dt)
                if dt > 0.4 { stallCount += 1 }
            }
            let mean = speeds.reduce(0, +) / Double(speeds.count)
            let variance = speeds.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(speeds.count)
            let cv = mean > 0.0001 ? sqrt(variance) / mean : 2
            cvs.append(cv)
        }
        let avgCV = cvs.isEmpty ? 2 : cvs.reduce(0, +) / Double(cvs.count)
        let stallRatio = min(1.0, Double(stallCount) / 4.0)
        let score = 100 - Int(avgCV * 45) - Int(stallRatio * 20)
        return clamp(score)
    }

    // ─── ④ 距 Layout ─────────────────────────────────────────────
    /// bbox 中心与标准中心的偏差 + 尺寸偏差
    private static func layoutAccuracy(user: [UserStroke], std: [StrokeSpec]) -> Int {
        let userPts = user.flatMap { $0.points.map { CGPoint(x: $0.x, y: $0.y) } }
        let stdPts = std.flatMap { StrokePath.sample($0.points, count: 32) }
        guard !userPts.isEmpty, !stdPts.isEmpty else { return 60 }

        let uBox = bbox(userPts)
        let sBox = bbox(stdPts)

        let uCx = (uBox.minX + uBox.maxX) / 2
        let uCy = (uBox.minY + uBox.maxY) / 2
        let sCx = (sBox.minX + sBox.maxX) / 2
        let sCy = (sBox.minY + sBox.maxY) / 2

        let dc = abs(uCx - sCx) + abs(uCy - sCy)          // 中心偏差
        let dsize = abs((uBox.maxX - uBox.minX) - (sBox.maxX - sBox.minX)) +
                    abs((uBox.maxY - uBox.minY) - (sBox.maxY - sBox.minY))

        let score = 100 - Int(dc * 160) - Int(dsize * 80)
        return clamp(score)
    }

    private static func bbox(_ pts: [CGPoint]) -> CGRect {
        let minX = pts.map(\.x).min() ?? 0
        let maxX = pts.map(\.x).max() ?? 1
        let minY = pts.map(\.y).min() ?? 0
        let maxY = pts.map(\.y).max() ?? 1
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    // ─── 反馈话术 ────────────────────────────────────────────────
    private static func makeFeedback(
        total: Int, shape: Int, order: Int,
        fluency: Int, layout: Int,
        userStrokeCount: Int, stdStrokeCount: Int
    ) -> FeedbackMessage {
        let praise: String
        let emoji: String
        if total >= 92      { praise = "这一笔非常漂亮，给你鼓掌 👏"; emoji = "🌟" }
        else if total >= 82 { praise = "写得很棒，继续保持"; emoji = "✨" }
        else if total >= 70 { praise = "有样子了，再练几遍就稳了"; emoji = "🌿" }
        else if total >= 55 { praise = "方向对了，细节再打磨"; emoji = "🌱" }
        else                { praise = "没关系，我们慢慢来"; emoji = "🍃" }

        var suggestions: [String] = []
        if userStrokeCount < stdStrokeCount {
            suggestions.append("好像少写了一画，我们再来一次？")
        } else if userStrokeCount > stdStrokeCount {
            suggestions.append("笔画数多了，试着一气呵成完成这一笔")
        }
        if layout < 70 {
            suggestions.append("字的位置可以再靠米字格中间一点")
        }
        if shape < 65 {
            suggestions.append("注意起笔和收笔的位置，对着灰色引导线走")
        }
        if fluency < 65 {
            suggestions.append("放慢一点，稳稳呼吸，一笔完成不要中途停顿")
        }
        if order < 70 && stdStrokeCount > 1 {
            suggestions.append("注意笔顺，按灰色箭头方向书写")
        }
        if suggestions.isEmpty && total < 90 {
            suggestions.append("继续练习，每一次都在进步")
        }
        return FeedbackMessage(
            praise: praise,
            suggestions: Array(suggestions.prefix(3)),
            emoji: emoji
        )
    }

    private static func clamp(_ v: Int) -> Int { max(0, min(100, v)) }
}
