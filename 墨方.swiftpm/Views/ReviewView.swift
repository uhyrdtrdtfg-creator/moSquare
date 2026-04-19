import SwiftUI

/// 今日复习 · 间隔重复队列
struct ReviewView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if dueCharIDs.isEmpty {
                            emptyState
                        } else {
                            overviewCard
                            dueList
                            scheduleGlance
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Computed

    private var dueCharIDs: [String] {
        app.charsDueForReview()
    }

    private func findChar(id: String) -> CharacterDef? {
        KidsCharacters.all.first { $0.id == id }
            ?? KidsCharactersExtra.all.first { $0.id == id }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 26))
                    Text("返回")
                }
                .foregroundColor(Theme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("📅 今 日 复 习")
                .font(.system(size: 20, weight: .black, design: .serif))
                .tracking(6)

            Spacer()

            Color.clear.frame(width: 60)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🌟").font(.system(size: 80))
            Text("今天没有需要复习的字!")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .tracking(2)
                .foregroundColor(Theme.ink)
            Text("继续学新字吧，练过的字过几天会自动回到这里哦~")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button("返回首页") { dismiss() }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Overview card

    private var overviewCard: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 2) {
                Text("待复习")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(dueCharIDs.count)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("个字")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Spacer()
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Theme.accent, Color(red: 0.90, green: 0.40, blue: 0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Due list

    private var dueList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("需要复习的字")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.muted)
            VStack(spacing: 8) {
                ForEach(dueCharIDs, id: \.self) { id in
                    if let c = findChar(id: id) {
                        dueRow(c)
                    }
                }
            }
        }
    }

    private func dueRow(_ c: CharacterDef) -> some View {
        let meta = KidsCharacters.metaFor(c.id)
        let state = app.reviewStates[c.id]
        let lastScore = state?.lastScore ?? 0
        let reviewCount = state?.reviewCount ?? 0

        return NavigationLink {
            KidPracticeSessionView(startCharID: c.id)
                .environmentObject(app)
        } label: {
            HStack(spacing: 14) {
                Text(c.glyph)
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(Theme.ink)
                    .frame(width: 62, height: 62)
                    .background(Theme.highlight.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if let m = meta {
                            Text(m.emoji).font(.system(size: 16))
                        }
                        Text(meta?.pinyin ?? "")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.accent)
                        Text(meta?.meaning ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.muted)
                    }
                    HStack(spacing: 6) {
                        Label("\(lastScore) 分", systemImage: "star")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(lastScore >= 85 ? Theme.accent : Theme.muted)
                        Text("·").foregroundColor(Theme.muted)
                        Text("已复习 \(reviewCount) 次")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.muted)
                    }
                }
                Spacer()
                Text("去复习")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.accent))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.muted)
            }
            .padding(12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Schedule glance

    private var scheduleGlance: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("未来 7 天")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.muted)
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    scheduleDayCell(dayOffset: dayOffset)
                }
            }
        }
    }

    private func scheduleDayCell(dayOffset: Int) -> some View {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        let dateKey = AppState.dayKey(date)
        let count = app.reviewStates.values.filter { $0.nextReviewDay == dateKey }.count

        return VStack(spacing: 4) {
            Text(weekdayLabel(date))
                .font(.system(size: 10))
                .foregroundColor(Theme.muted)
            Text("\(count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(count > 0 ? Theme.accent : Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(count > 0 ? Theme.accent.opacity(0.10) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func weekdayLabel(_ d: Date) -> String {
        let names = ["日", "一", "二", "三", "四", "五", "六"]
        let wd = Calendar.current.component(.weekday, from: d)
        return names[wd - 1]
    }
}
