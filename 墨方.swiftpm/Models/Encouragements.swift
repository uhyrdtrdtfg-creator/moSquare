import Foundation

/// 幼儿鼓励词库 · 每次随机选一条，让反馈永远新鲜
enum Encouragements {

    /// 写对一笔后的小鼓励（短 · 活泼）
    static let perStroke: [String] = [
        "✨ 太棒了!",
        "👍 好厉害!",
        "🎯 写得准!",
        "🌟 完美!",
        "💫 真稳!",
        "🎉 棒棒的!",
        "🌈 漂亮!",
        "👏 加油加油!",
        "🦋 轻巧!",
        "🌸 柔美!",
        "🍀 运气好!",
        "💎 闪闪的!",
        "🐣 好可爱!",
        "🌻 真亮!",
        "🐱 喵呜~真棒!"
    ]

    /// 连击 3+ 时特别激动
    static let onStreak: [String] = [
        "🔥 连赢啦!",
        "🚀 冲冲冲!",
        "⭐ 一路顺!",
        "💪 小书法家!",
        "🏆 超级棒!",
        "🌟 停不下来!"
    ]

    /// 整字完成时的庆祝（长一点、带仪式感）
    static let perCharacter: [String] = [
        "🎉 你写完整个字啦!",
        "🎊 好厉害!这个字你会了!",
        "👏 小书法家来啦!",
        "🌟 这是你的作品!",
        "🏆 写得真好看!",
        "💖 我为你骄傲!",
        "🌈 又学会一个字!",
        "🎁 完成任务!",
        "🦄 魔法般完美!",
        "🎈 再来一个嘛?"
    ]

    /// 失败后的温和打气（不羞辱、不责备）
    static let onFail: [String] = [
        "没关系，再试一次～",
        "差一点点啦，加油!",
        "哎呀，再来一次!",
        "好的，慢慢来~",
        "没事的，谁都要练习的~",
        "休息一下，再来试试?"
    ]

    /// 随机抽取
    static func randomPerStroke() -> String { perStroke.randomElement() ?? "👍 真棒!" }
    static func randomOnStreak() -> String { onStreak.randomElement() ?? "🔥 连赢!" }
    static func randomPerCharacter() -> String { perCharacter.randomElement() ?? "🎉 完成啦!" }
    static func randomOnFail() -> String { onFail.randomElement() ?? "再来一次~" }
}
