import Foundation
import CoreGraphics

/// 汉字笔画数据池 · 531 字 · 从 Resources/hanzi_pool.json 运行时加载
///
/// 数据源：chanind/hanzi-writer-data (MIT)
/// 格式：1024×1024 坐标空间，bottom-left origin
///
/// 原先写成 Swift 字面量 27,000+ 行，clean build 要 5 分钟；
/// 现在改成 JSON 资源，clean build 30 秒以内。
enum HanziPool {
    /// 全部字 · 首次访问时从 JSON 解码一次并缓存
    private static let pool: [HanziChar] = loadPool()

    private static func loadPool() -> [HanziChar] {
        guard let url = Bundle.main.url(forResource: "hanzi_pool", withExtension: "json") else {
            print("[HanziPool] hanzi_pool.json not found in main bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([HanziChar].self, from: data)
        } catch {
            print("[HanziPool] decode failed: \(error)")
            return []
        }
    }

    /// 按字形查找
    static func find(_ glyph: String) -> HanziChar? {
        indexByGlyph[glyph]
    }

    /// 字形 → HanziChar 索引（O(1) 查询）
    private static let indexByGlyph: [String: HanziChar] = {
        var map: [String: HanziChar] = [:]
        for c in pool { map[c.glyph] = c }
        return map
    }()

    /// 全部字（按 JSON 里的顺序）
    static var all: [HanziChar] { pool }

    /// 全部字（同 all，兼容旧接口）
    static var everything: [HanziChar] { pool }

    /// 总字数
    static var totalCount: Int { pool.count }

    /// 字形 → 拼音 便捷查询
    static var glyphToPinyin: [String: String] {
        Dictionary(uniqueKeysWithValues: pool.map { ($0.glyph, $0.pinyin) })
    }
}
