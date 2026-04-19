import SwiftUI

/// 应用根视图
/// - 未引导：显示开蒙页 OnboardingView
/// - 已引导：主 TabView（今日 / 练字 / 书房）
struct RootView: View {
    @EnvironmentObject var app: AppState
    @State private var selected: Tab = .home

    enum Tab: Hashable { case home, practice, room }

    var body: some View {
        ZStack {
            PaperBackground()
            if !app.onboarded {
                OnboardingView()
                    .transition(.opacity)
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: app.onboarded)
    }

    private var content: some View {
        VStack(spacing: 0) {
            TopBar()
            TabView(selection: $selected) {
                HomeView(onStartPractice: { selected = .practice },
                         onOpenGame: { selected = .practice /* will open modal */ })
                    .tag(Tab.home)
                    .tabItem { Label("今日", systemImage: "sun.max.fill") }

                PracticeView()
                    .tag(Tab.practice)
                    .tabItem { Label("练字", systemImage: "pencil.tip") }

                RoomView()
                    .tag(Tab.room)
                    .tabItem { Label("书房", systemImage: "house.fill") }
            }
            .tint(Theme.accent)
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 顶部状态栏
// ─────────────────────────────────────────────────────────────────

struct TopBar: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            HStack(spacing: 6) {
                Text("墨方")
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .tracking(4)
                Text(app.isKidMode ? "小朋友" : "零基础")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .offset(y: -2)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").foregroundColor(.orange)
                Text("连续")
                Text("\(app.streakDays)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.accent)
                Text("天")
            }
            .font(.system(size: 13))
            .foregroundColor(Theme.muted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Theme.paper)
        .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)
    }
}
