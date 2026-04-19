import Foundation
import CoreGraphics

/// 逐笔匹配器 · 用于「跟写」模式
///
/// 判断用户刚写的一笔是否对应标准笔画序列中的当前目标笔画。
/// 匹配条件（三选一全过）：
///   1. 起笔位置距离 ≤ threshold
///   2. 终笔位置距离 ≤ threshold
///   3. 主方向向量夹角 cos ≥ directionThreshold
///
/// 幼儿模式下使用宽松阈值（threshold=0.28, cos≥0.40）
/// 成人模式下使用标准阈值（threshold=0.22, cos≥0.55）
enum StrokeMatcher {

    struct Config {
        let startEndThreshold: CGFloat    // 起终点允许偏差（归一化）
        let directionThreshold: Double    // 方向向量余弦最低值
        let minPoints: Int                // 用户一笔至少要多少个采样点

        static let kid = Config(
            startEndThreshold: 0.28,
            directionThreshold: 0.40,
            minPoints: 4
        )
        static let adult = Config(
            startEndThreshold: 0.22,
            directionThreshold: 0.55,
            minPoints: 6
        )
    }

    /// 判断用户一笔是否匹配目标笔画
    /// - Parameters:
    ///   - user: 用户刚写完的一笔
    ///   - target: 标准笔画
    ///   - config: 匹配阈值配置
    /// - Returns: 匹配结果 + 失败原因（用于给出温和提示）
    static func match(
        user: UserStroke,
        target: StrokeSpec,
        config: Config = .kid
    ) -> MatchResult {
        let userPts = user.points.map { CGPoint(x: $0.x, y: $0.y) }
        let targetPts = StrokePath.sample(target.points, count: 16)

        guard userPts.count >= config.minPoints else {
            return .failed(.tooShort)
        }
        guard targetPts.count >= 2,
              let tStart = targetPts.first,
              let tEnd = targetPts.last,
              let uStart = userPts.first,
              let uEnd = userPts.last
        else {
            return .failed(.unknown)
        }

        let startDist = hypot(uStart.x - tStart.x, uStart.y - tStart.y)
        if startDist > config.startEndThreshold {
            return .failed(.wrongStart)
        }

        let endDist = hypot(uEnd.x - tEnd.x, uEnd.y - tEnd.y)
        if endDist > config.startEndThreshold {
            return .failed(.wrongEnd)
        }

        let uDir = CGPoint(x: uEnd.x - uStart.x, y: uEnd.y - uStart.y)
        let tDir = CGPoint(x: tEnd.x - tStart.x, y: tEnd.y - tStart.y)
        let uNorm = hypot(uDir.x, uDir.y)
        let tNorm = hypot(tDir.x, tDir.y)
        guard uNorm > 0.01, tNorm > 0.01 else {
            return .failed(.unknown)
        }
        let cos = Double((uDir.x * tDir.x + uDir.y * tDir.y) / (uNorm * tNorm))
        if cos < config.directionThreshold {
            return .failed(.wrongDirection)
        }

        // 算一个置信度分数（0-100）
        let startScore = 1 - min(1, startDist / config.startEndThreshold)
        let endScore = 1 - min(1, endDist / config.startEndThreshold)
        let dirScore = max(0, cos)
        let confidence = Int(((startScore + endScore + dirScore) / 3.0 * 100).rounded())

        return .matched(confidence: confidence)
    }

    enum MatchResult {
        case matched(confidence: Int)  // 0-100
        case failed(Reason)

        var isMatched: Bool {
            if case .matched = self { return true }
            return false
        }
    }

    enum Reason {
        case tooShort
        case wrongStart
        case wrongEnd
        case wrongDirection
        case unknown

        /// 面向 4-5 岁小朋友的温和提示
        var kidTip: String {
            switch self {
            case .tooShort:       return "哇，这一笔太短啦～试着画长一点"
            case .wrongStart:     return "起笔位置不太对，从箭头的起点开始"
            case .wrongEnd:       return "收笔地方差了一点点，顺着箭头到终点"
            case .wrongDirection: return "方向不对哦～看看灰色箭头指哪边"
            case .unknown:        return "再试一次，你可以的"
            }
        }
    }
}
