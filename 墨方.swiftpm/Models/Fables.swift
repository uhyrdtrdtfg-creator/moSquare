import SwiftUI

// ─────────────────────────────────────────────────────────────────
// MARK: - 绘本寓言 · 30 篇
// ─────────────────────────────────────────────────────────────────
//
// 每一篇 4-5 页短句，使用孩子学过的字占大多数。
// 学过的字会自动加亮、点按可听读音。
//
// 背景分两种：
//   1. image:  直接用 Resources/backgrounds 里的 CC0 PNG
//   2. drawn:  用 SwiftUI 画（夜空、下雨、下雪、屋内、池塘）
//
// 图像来源：kenney.nl · Background Elements 素材包 · CC0
// ─────────────────────────────────────────────────────────────────

enum FableScene: String, Hashable {
    case forest      // 林 (PNG)
    case hills       // 青山 (PNG)
    case castle      // 远方 (PNG)
    case desert      // 远行 (PNG)

    case night       // 夜 (SwiftUI)
    case rain        // 雨 (SwiftUI)
    case snow        // 雪 (SwiftUI)
    case home        // 屋内 (SwiftUI)
    case pond        // 池塘 (SwiftUI)
    case sunrise     // 日出 (SwiftUI)
}

struct FablePage: Hashable {
    let scene: FableScene
    let text: String
}

struct Fable: Identifiable, Hashable {
    let id: String
    let cover: String           // emoji
    let title: String
    let moral: String           // 寓意一句
    let pages: [FablePage]
}

enum FablePool {
    static let all: [Fable] = [

        .init(id: "f01", cover: "🌳", title: "守木待兔",
              moral: "心里只等，田里不长米。",
              pages: [
                .init(scene: .forest, text: "一个人坐在大木下。"),
                .init(scene: .forest, text: "一只兔子跑来，撞在木上。"),
                .init(scene: .forest, text: "人很开心，拿了兔子回家。"),
                .init(scene: .forest, text: "他天天坐在木下等。"),
                .init(scene: .forest, text: "兔子不来了，田里的草也黄了。")
              ]),

        .init(id: "f02", cover: "🐇", title: "兔子和马",
              moral: "一步一步走，也能到山上。",
              pages: [
                .init(scene: .hills, text: "兔子跑得快，马走得慢。"),
                .init(scene: .hills, text: "兔子笑马：你上不了山。"),
                .init(scene: .hills, text: "兔子坐下看花，不走了。"),
                .init(scene: .hills, text: "马一步一步往山上走。"),
                .init(scene: .hills, text: "日下山时，马上了山头。")
              ]),

        .init(id: "f03", cover: "🐑", title: "两只小羊",
              moral: "你让一步，我让一步，都过去。",
              pages: [
                .init(scene: .hills, text: "一大一小两只羊，在木桥上。"),
                .init(scene: .hills, text: "大羊说：你下！"),
                .init(scene: .hills, text: "小羊说：你下！"),
                .init(scene: .hills, text: "两只羊都不让。"),
                .init(scene: .pond,  text: "风一吹，两只羊都入水了。")
              ]),

        .init(id: "f04", cover: "🐦", title: "鸟喝水",
              moral: "心里有法子，就不怕难。",
              pages: [
                .init(scene: .forest, text: "一只鸟，口很渴。"),
                .init(scene: .forest, text: "它看见一口小水。"),
                .init(scene: .forest, text: "水很少，口够不到。"),
                .init(scene: .forest, text: "小鸟叼来石子，一个一个入水。"),
                .init(scene: .forest, text: "水上来了，小鸟喝到了。")
              ]),

        .init(id: "f05", cover: "🐴", title: "小马过水",
              moral: "自己走一走，才知道。",
              pages: [
                .init(scene: .hills, text: "小马要过水。"),
                .init(scene: .hills, text: "牛说：水小，跨一步就过。"),
                .init(scene: .hills, text: "羊说：水大，不要入！"),
                .init(scene: .pond,  text: "小马自己走入水。"),
                .init(scene: .pond,  text: "水不大不小，到马的足。")
              ]),

        .init(id: "f06", cover: "🐟", title: "小鱼看天",
              moral: "走出去，才看见大天。",
              pages: [
                .init(scene: .pond, text: "小鱼在一口小水里。"),
                .init(scene: .pond, text: "它看见天，像一口大。"),
                .init(scene: .pond, text: "小鱼说：天真小。"),
                .init(scene: .pond, text: "大鱼说：跳出来看。"),
                .init(scene: .hills, text: "小鱼一跳，天好大好大。")
              ]),

        .init(id: "f07", cover: "🌲", title: "大木和小花",
              moral: "大有大的用，小有小的美。",
              pages: [
                .init(scene: .forest, text: "山上有一棵大木。"),
                .init(scene: .forest, text: "木下有一朵小花。"),
                .init(scene: .forest, text: "大木说：我比你大。"),
                .init(scene: .forest, text: "小花说：我比你红。"),
                .init(scene: .forest, text: "风吹过，木和花都笑了。")
              ]),

        .init(id: "f08", cover: "☀️", title: "看日出",
              moral: "早起的人，看得见最美的日。",
              pages: [
                .init(scene: .night,   text: "天还黑黑的。"),
                .init(scene: .sunrise, text: "爸爸和我站在山上。"),
                .init(scene: .sunrise, text: "日出了，大大的，红红的。"),
                .init(scene: .sunrise, text: "白云也变红了。"),
                .init(scene: .sunrise, text: "爸爸看我，我们都笑了。")
              ]),

        .init(id: "f09", cover: "🏠", title: "一家人",
              moral: "一家人，心在一起。",
              pages: [
                .init(scene: .home, text: "桌上有米，有菜，有果。"),
                .init(scene: .home, text: "爸爸坐中间。"),
                .init(scene: .home, text: "妈妈坐左边，奶奶坐右边。"),
                .init(scene: .home, text: "哥哥和妹妹，一边一个。"),
                .init(scene: .home, text: "一家人，吃一口饭，笑一下。")
              ]),

        .init(id: "f10", cover: "🐣", title: "小鸟学飞",
              moral: "不试一试，不知道自己能飞。",
              pages: [
                .init(scene: .forest, text: "小鸟站在大木上。"),
                .init(scene: .forest, text: "妈妈说：跳下去，你会飞。"),
                .init(scene: .forest, text: "小鸟怕，不敢跳。"),
                .init(scene: .forest, text: "小鸟一跳，风吹来。"),
                .init(scene: .hills,  text: "小鸟飞上了天！")
              ]),

        .init(id: "f11", cover: "🌾", title: "草和大风",
              moral: "低头不是怕，是心里有数。",
              pages: [
                .init(scene: .hills, text: "大风吹来。"),
                .init(scene: .hills, text: "大木站不住，倒下了。"),
                .init(scene: .hills, text: "小草低下头。"),
                .init(scene: .hills, text: "风走了，小草又站起。"),
                .init(scene: .hills, text: "大木不见了，小草还在。")
              ]),

        .init(id: "f12", cover: "🐄", title: "牛羊争草",
              moral: "争来争去，自己吃不到。",
              pages: [
                .init(scene: .hills, text: "田里有一片青草。"),
                .init(scene: .hills, text: "牛说：草是我的。"),
                .init(scene: .hills, text: "羊说：不，是我的。"),
                .init(scene: .hills, text: "两个不吃了，站着看。"),
                .init(scene: .hills, text: "兔子跑来，吃了草。")
              ]),

        .init(id: "f13", cover: "🐛", title: "小虫上山",
              moral: "小小的虫，也能上大山。",
              pages: [
                .init(scene: .hills, text: "小虫很小，山很大。"),
                .init(scene: .hills, text: "小虫一步一步爬。"),
                .init(scene: .hills, text: "一天，两天，三天。"),
                .init(scene: .hills, text: "十天，小虫到了山上。"),
                .init(scene: .hills, text: "立在山头，心里好大。")
              ]),

        .init(id: "f14", cover: "🌸", title: "红花白花",
              moral: "各有各的美。",
              pages: [
                .init(scene: .forest, text: "一朵红花，一朵白花。"),
                .init(scene: .forest, text: "红花说：我最红！"),
                .init(scene: .forest, text: "白花说：我最白！"),
                .init(scene: .forest, text: "小虫飞来：你们都很美。"),
                .init(scene: .forest, text: "红的红，白的白，都是花。")
              ]),

        .init(id: "f15", cover: "🐰", title: "兔子吃菜",
              moral: "门口的花和菜，是家的心。",
              pages: [
                .init(scene: .home, text: "家的门口，有一片菜。"),
                .init(scene: .home, text: "兔子跑来吃菜。"),
                .init(scene: .home, text: "爸爸出门，看见兔子。"),
                .init(scene: .hills, text: "兔子跑了，跑入山。"),
                .init(scene: .home, text: "爸爸笑：兔子也爱菜。")
              ]),

        .init(id: "f16", cover: "🐠", title: "小鱼的家",
              moral: "家，是最好的地方。",
              pages: [
                .init(scene: .pond, text: "小鱼在大水里。"),
                .init(scene: .pond, text: "它看见天上的日。"),
                .init(scene: .pond, text: "小鱼跳出水，想看日。"),
                .init(scene: .pond, text: "水外好冷，小鱼不能走。"),
                .init(scene: .pond, text: "小鱼跳回水里，家最好。")
              ]),

        .init(id: "f17", cover: "👫", title: "哥哥和妹妹",
              moral: "有哥哥在，妹妹不怕。",
              pages: [
                .init(scene: .hills, text: "哥哥大，走得快。"),
                .init(scene: .hills, text: "妹妹小，走得慢。"),
                .init(scene: .hills, text: "哥哥走远了，不见妹妹。"),
                .init(scene: .hills, text: "回头一看，妹妹坐下哭。"),
                .init(scene: .hills, text: "哥哥跑回来，拉妹妹的手。")
              ]),

        .init(id: "f18", cover: "✋", title: "爸爸的手",
              moral: "爸爸的手，是家。",
              pages: [
                .init(scene: .home, text: "爸爸的手大，我的手小。"),
                .init(scene: .home, text: "爸爸的手能开门。"),
                .init(scene: .home, text: "爸爸的手能做饭。"),
                .init(scene: .home, text: "爸爸的手拉我走。"),
                .init(scene: .home, text: "我的手在爸爸的手里，不怕。")
              ]),

        .init(id: "f19", cover: "❤️", title: "妈妈的心",
              moral: "妈妈的心，最大最暖。",
              pages: [
                .init(scene: .home, text: "我病了，不想吃饭。"),
                .init(scene: .home, text: "妈妈不坐，也不走。"),
                .init(scene: .home, text: "妈妈看我，一天一夜。"),
                .init(scene: .home, text: "我好了，妈妈笑了。"),
                .init(scene: .home, text: "妈妈的心里，只有我。")
              ]),

        .init(id: "f20", cover: "🌼", title: "奶奶的花",
              moral: "爱花的人，心也年轻。",
              pages: [
                .init(scene: .home, text: "家的门口，有一朵红花。"),
                .init(scene: .home, text: "奶奶天天看花。"),
                .init(scene: .home, text: "花开了，花也谢了。"),
                .init(scene: .home, text: "奶奶老了，心不老。"),
                .init(scene: .home, text: "花再开时，奶奶又笑了。")
              ]),

        .init(id: "f21", cover: "🌧️", title: "雨下到山上",
              moral: "雨是草的饭。",
              pages: [
                .init(scene: .rain, text: "天上有黑云。"),
                .init(scene: .rain, text: "云里有雨。"),
                .init(scene: .rain, text: "雨下到山上。"),
                .init(scene: .rain, text: "山上的草都绿了。"),
                .init(scene: .rain, text: "小花也开了。")
              ]),

        .init(id: "f22", cover: "❄️", title: "下雪了",
              moral: "冬天有冬天的美。",
              pages: [
                .init(scene: .snow, text: "天上下雪，一片白。"),
                .init(scene: .snow, text: "山白了，木也白了。"),
                .init(scene: .snow, text: "小鸟在雪上走。"),
                .init(scene: .snow, text: "留下一串小小的足。"),
                .init(scene: .snow, text: "雪是天上的花。")
              ]),

        .init(id: "f23", cover: "☁️", title: "风吹云走",
              moral: "天天的天，不一样。",
              pages: [
                .init(scene: .hills, text: "天上的云，白白的。"),
                .init(scene: .hills, text: "风一吹，云走了。"),
                .init(scene: .hills, text: "云跑到山的那一边。"),
                .init(scene: .hills, text: "天上只有一个日。"),
                .init(scene: .hills, text: "风，是天上的手。")
              ]),

        .init(id: "f24", cover: "🚪", title: "大门和小门",
              moral: "大有大的用，小有小的好。",
              pages: [
                .init(scene: .home, text: "家有两个门。"),
                .init(scene: .home, text: "大门在前，小门在后。"),
                .init(scene: .home, text: "爸爸走大门，出门上山。"),
                .init(scene: .home, text: "妹妹走小门。"),
                .init(scene: .home, text: "小门外有一朵花，妹妹笑了。")
              ]),

        .init(id: "f25", cover: "🌕", title: "月下的小兔",
              moral: "夜里有月，心里不怕。",
              pages: [
                .init(scene: .night, text: "月上来了，圆圆的。"),
                .init(scene: .night, text: "山下有一只小兔。"),
                .init(scene: .night, text: "兔子看月。"),
                .init(scene: .night, text: "月里好像也有一只兔。"),
                .init(scene: .night, text: "夜里有月，一个人也不怕。")
              ]),

        .init(id: "f26", cover: "🔥", title: "小小的火",
              moral: "小小的光，也是光。",
              pages: [
                .init(scene: .home, text: "家里有一点小火。"),
                .init(scene: .home, text: "风一吹，火要灭。"),
                .init(scene: .home, text: "妹妹用手挡风。"),
                .init(scene: .home, text: "小火又红，又亮。"),
                .init(scene: .home, text: "小火也能照亮家。")
              ]),

        .init(id: "f27", cover: "☁️", title: "白云和黑云",
              moral: "不要只看外面。",
              pages: [
                .init(scene: .hills, text: "白云在天上走。"),
                .init(scene: .rain,  text: "黑云也跑来了。"),
                .init(scene: .rain,  text: "白云说：你黑，走开！"),
                .init(scene: .rain,  text: "黑云说：我下雨，米才长。"),
                .init(scene: .rain,  text: "白不全是好，黑不全是坏。")
              ]),

        .init(id: "f28", cover: "🐑", title: "三只小羊",
              moral: "爸爸爱每一个。",
              pages: [
                .init(scene: .hills, text: "大羊，中羊，小羊。"),
                .init(scene: .hills, text: "大羊吃草。"),
                .init(scene: .hills, text: "中羊喝水。"),
                .init(scene: .hills, text: "小羊坐下看花。"),
                .init(scene: .hills, text: "爸爸羊说：你们都是我的心。")
              ]),

        .init(id: "f29", cover: "🚶", title: "走出家门",
              moral: "走出去，看大大的世界。",
              pages: [
                .init(scene: .home,   text: "我走出家门。"),
                .init(scene: .hills,  text: "看见天，天好大。"),
                .init(scene: .hills,  text: "看见山，山好高。"),
                .init(scene: .pond,   text: "看见水，水好长。"),
                .init(scene: .desert, text: "走出去，有大大的世界。")
              ]),

        .init(id: "f30", cover: "🍎", title: "树上的红果",
              moral: "听爸爸的话，果才甜。",
              pages: [
                .init(scene: .forest, text: "大木上有一个红果。"),
                .init(scene: .forest, text: "爸爸说：果不红，不能吃。"),
                .init(scene: .forest, text: "哥哥不听，上木去。"),
                .init(scene: .forest, text: "红果入口，酸酸的。"),
                .init(scene: .forest, text: "听爸爸的话，吃的果才甜。")
              ])
    ]
}
