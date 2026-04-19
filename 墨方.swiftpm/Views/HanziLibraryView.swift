import SwiftUI

/// 1800 字库浏览 · 按频率分级
/// - 启蒙 · 前 100 字（最高频 + 最简单）
/// - 初级 · 101–300 字
/// - 中级 · 301–600 字
/// - 高级 · 601–1000 字
/// - 进阶 · 1001–1800 字
/// - 其他 · 1800 之外的补充字
struct HanziLibraryView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: Int = 0
    @State private var navigatingTo: String? = nil

    struct Tier: Identifiable {
        let id: Int
        let title: String
        let range: Range<Int>      // 在 HanziPool.all 里的索引区间
        let emoji: String
    }

    private var tiers: [Tier] {
        let total = HanziPool.totalCount
        return [
            Tier(id: 0, title: "启蒙", range: 0..<min(100, total),    emoji: "🌱"),
            Tier(id: 1, title: "初级", range: min(100, total)..<min(300, total),  emoji: "🌿"),
            Tier(id: 2, title: "中级", range: min(300, total)..<min(600, total),  emoji: "🌳"),
            Tier(id: 3, title: "高级", range: min(600, total)..<min(1000, total), emoji: "🌲"),
            Tier(id: 4, title: "进阶", range: min(1000, total)..<min(1800, total),emoji: "🏔️"),
            Tier(id: 5, title: "补充", range: min(1800, total)..<total,           emoji: "🎯")
        ].filter { !$0.range.isEmpty }
    }

    private var currentTier: Tier { tiers.first { $0.id == selectedTier } ?? tiers[0] }

    private var currentChars: [HanziChar] {
        Array(HanziPool.all[currentTier.range])
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                VStack(spacing: 12) {
                    header
                    tierPicker
                    summaryStrip
                    gridScroll
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // 隐藏导航链接，通过 state 触发
                NavigationLink(
                    destination: navigatingTo.map { glyph in
                        KidPracticeSessionView(startCharID: "kid:\(glyph)")
                            .environmentObject(app)
                    },
                    isActive: Binding(
                        get: { navigatingTo != nil },
                        set: { if !$0 { navigatingTo = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }

    // ─── Header ──────────────────────────────────────────────
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                    Text("返回")
                }
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)
            Spacer()
            VStack(spacing: 2) {
                Text("🈶 字 库")
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .tracking(4)
                Text("\(HanziPool.totalCount) 字 · 按频率分级")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            Color.clear.frame(width: 60)
        }
        .padding(.top, 12)
    }

    // ─── Tier picker ─────────────────────────────────────────
    private var tierPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tiers) { t in
                    Button {
                        withAnimation { selectedTier = t.id }
                    } label: {
                        HStack(spacing: 4) {
                            Text(t.emoji).font(.system(size: 18))
                            Text(t.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .tracking(2)
                            Text("\(t.range.count)")
                                .font(.system(size: 11))
                                .opacity(0.75)
                        }
                        .foregroundColor(selectedTier == t.id ? .white : Theme.ink)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                selectedTier == t.id ? Theme.accent : Color.white
                            )
                        )
                        .overlay(
                            Capsule().stroke(
                                selectedTier == t.id ? Color.clear : Theme.line,
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // ─── Summary ─────────────────────────────────────────────
    private var summaryStrip: some View {
        let learned = currentChars.filter { app.doneStrokeIDs.contains("kid:" + $0.glyph) }.count
        let total = currentChars.count
        return HStack(spacing: 8) {
            Text("\(currentTier.emoji) \(currentTier.title)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(Theme.ink)
            Spacer()
            ProgressView(value: Double(learned), total: Double(max(total, 1)))
                .tint(Theme.accent)
                .frame(maxWidth: 180)
            Text("\(learned)/\(total)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.accent)
        }
        .padding(.vertical, 6)
    }

    // ─── Grid ────────────────────────────────────────────────
    private var gridScroll: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                      spacing: 8) {
                ForEach(currentChars) { c in
                    charCell(c).onTapGesture {
                        navigatingTo = c.glyph
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func charCell(_ c: HanziChar) -> some View {
        let done = app.doneStrokeIDs.contains("kid:" + c.glyph)
        return VStack(spacing: 3) {
            Text(c.glyph)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(done ? .white : Theme.ink)
                .frame(width: 50, height: 50)
                .background(done
                            ? Color(red: 0.85, green: 0.35, blue: 0.25)
                            : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(done ? Color.clear : Theme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(done ? 0.15 : 0.04), radius: 3, y: 1)
            Text(c.pinyin)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(Theme.gold)
                .lineLimit(1)
        }
    }
}
