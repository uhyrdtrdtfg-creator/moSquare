import SwiftUI

/// 本周挑战 · 3 个主题任务 + 领奖
struct WeeklyMissionView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var celebratingIndex: Int? = nil  // for claim animation

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        summary
                        missionsList
                        Spacer(minLength: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            if let i = celebratingIndex {
                claimCelebrationOverlay(index: i)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                HStack {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                    Text("返回")
                }
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)

            Spacer()
            VStack(spacing: 2) {
                Text("🏅 本 周 挑 战")
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .tracking(6)
                Text(app.weeklyWeek)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.muted)
            }
            Spacer()
            Color.clear.frame(width: 60)
        }
    }

    // MARK: - Summary

    private var summary: some View {
        let totalTarget = AppState.weeklyMissions.reduce(0) { $0 + $1.target }
        let totalProgress = app.weeklyProgress.reduce(0, +)
        let claimedCount = app.weeklyClaimed.filter { $0 }.count
        _ = totalTarget
        _ = totalProgress

        return VStack(spacing: 8) {
            HStack {
                Text("本周进度")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(claimedCount) / 3 奖励已领取")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Theme.gold)
            }
            HStack(spacing: 18) {
                ForEach(0..<3, id: \.self) { i in
                    let m = AppState.weeklyMissions[i]
                    VStack(spacing: 4) {
                        Text(m.icon).font(.system(size: 22))
                        Text("\(min(app.weeklyProgress[i], m.target))/\(m.target)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(m.rewardEmoji)
                            .font(.system(size: 14))
                            .opacity(app.weeklyClaimed[i] ? 1 : 0.35)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.18, blue: 0.30),
                    Color(red: 0.25, green: 0.12, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }

    // MARK: - Missions List

    private var missionsList: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { i in
                missionCard(i)
            }
        }
    }

    private func missionCard(_ i: Int) -> some View {
        let m = AppState.weeklyMissions[i]
        let progress = min(app.weeklyProgress[i], m.target)
        let isComplete = progress >= m.target
        let isClaimed = app.weeklyClaimed[i]

        return HStack(spacing: 14) {
            // Icon circle (big)
            ZStack {
                Circle()
                    .fill(isComplete ? Theme.accent : Color.white)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(isComplete ? Color.clear : Theme.line, lineWidth: 1.5)
                    )
                Text(m.icon).font(.system(size: 24))
            }

            // Text + progress
            VStack(alignment: .leading, spacing: 4) {
                Text(m.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.ink)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.line.opacity(0.3))
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(progress) / CGFloat(max(m.target, 1)),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(progress) / \(m.target)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.muted)
                    Spacer()
                    Text("奖励: \(m.rewardEmoji) \(m.rewardLabel)")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.muted)
                }
            }

            // Claim button area
            VStack {
                if isClaimed {
                    VStack(spacing: 2) {
                        Text(m.rewardEmoji).font(.system(size: 26))
                        Text("已领取")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.accent)
                    }
                } else if isComplete {
                    Button {
                        claimReward(index: i, mission: m)
                    } label: {
                        Text("领 奖")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Theme.accent))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("继续加油")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.muted)
                }
            }
            .frame(width: 70)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Claim action

    private func claimReward(index: Int, mission: AppState.WeeklyMission) {
        app.weeklyClaim(index)
        Sound.fanfare.play()
        Speaker.shared.speak("领到\(mission.rewardLabel)")
        withAnimation(.spring()) { celebratingIndex = index }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { celebratingIndex = nil }
        }
    }

    // MARK: - Celebration Overlay

    private func claimCelebrationOverlay(index: Int) -> some View {
        let m = AppState.weeklyMissions[index]
        return ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 14) {
                Text(m.rewardEmoji)
                    .font(.system(size: 120))
                    .scaleEffect(1.0)
                Text("恭喜获得")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                Text(m.rewardLabel)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
            .padding(40)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.85), Color.black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
        .transition(.opacity)
    }
}
