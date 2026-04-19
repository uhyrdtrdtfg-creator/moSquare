import SwiftUI

/// 墨方视觉语言 · 东方松弛美学
enum Theme {
    // ─── Colors ───────────────────────────────────────────────────────
    static let ink       = Color(red: 0.10, green: 0.10, blue: 0.10)  // 徽墨黑
    static let paper     = Color(red: 0.98, green: 0.97, blue: 0.94)  // 宣纸
    static let paperDark = Color(red: 0.94, green: 0.91, blue: 0.84)  // 仿古
    static let accent    = Color(red: 0.75, green: 0.22, blue: 0.17)  // 朱砂
    static let accent2   = Color(red: 0.17, green: 0.24, blue: 0.31)  // 深青
    static let muted     = Color(red: 0.54, green: 0.51, blue: 0.44)
    static let line      = Color(red: 0.85, green: 0.82, blue: 0.77)
    static let gold      = Color(red: 0.69, green: 0.54, blue: 0.24)
    static let highlight = Color(red: 0.96, green: 0.91, blue: 0.78)
}

// MARK: - Reusable UI building blocks

struct PaperBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.paperDark, Theme.paper, Theme.paperDark],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var filled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .tracking(4)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(filled ? Theme.accent : Color.clear)
            .foregroundColor(filled ? .white : Theme.ink)
            .overlay(
                Capsule().stroke(filled ? Color.clear : Theme.ink, lineWidth: 1)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .serif))
            .tracking(2)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.6))
            .foregroundColor(Theme.ink)
            .overlay(
                Capsule().stroke(Theme.line, lineWidth: 1)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
