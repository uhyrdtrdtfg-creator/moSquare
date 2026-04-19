import SwiftUI

/// 家长周报 · 需要家长锁验证后才能查看详情和修改限制
struct ParentReportView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var isUnlocked: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                if isUnlocked {
                    reportContent
                } else {
                    ParentLockGate(onUnlock: { isUnlocked = true })
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Report content

    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                topBar
                weekSummary
                dailyChart
                masteredList
                weakList
                limitSettings
                totalStats
                Color.clear.frame(height: 12)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                    Text("返回")
                }.foregroundColor(Theme.accent)
            }.buttonStyle(.plain)
            Spacer()
            Text("家 长 周 报")
                .font(.system(size: 20, weight: .black, design: .serif))
                .tracking(6)
            Spacer()
            Color.clear.frame(width: 60)
        }
    }

    // MARK: - 1. Week summary (dark card)

    private var weekSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本 周 概 览")
                .font(.system(size: 12, weight: .semibold)).tracking(3)
                .foregroundColor(.white.opacity(0.75))
            HStack(spacing: 20) {
                statBlock(value: "\(app.thisWeekMinutes)", unit: "分钟", label: "练字时长")
                statBlock(value: "\(app.doneStrokeIDs.count)", unit: "个", label: "掌握字")
                statBlock(value: "\(app.stickerCount)", unit: "枚", label: "贴纸")
                statBlock(value: "\(app.streakDays)", unit: "天", label: "连续签到")
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [Theme.ink, Color(red: 0.2, green: 0.2, blue: 0.25)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statBlock(value: String, unit: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(unit).font(.system(size: 11)).foregroundColor(.white.opacity(0.7))
            }
            Text(label).font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - 2. Daily chart

    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("近 7 天练字时长")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.muted)
            let stats = app.last7DaysStats
            let maxMin = max(1, (stats.map(\.minutes).max() ?? 1))
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(stats.indices, id: \.self) { i in
                    let s = stats[i]
                    VStack(spacing: 4) {
                        Text("\(s.minutes)")
                            .font(.system(size: 10, weight: .bold)).foregroundColor(Theme.accent)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.6)],
                                                 startPoint: .top, endPoint: .bottom))
                            .frame(height: max(4, 120 * CGFloat(s.minutes) / CGFloat(maxMin)))
                        Text(shortWeekday(key: s.dateKey))
                            .font(.system(size: 10)).foregroundColor(Theme.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14).background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func shortWeekday(key: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: key) {
            let wd = Calendar.current.component(.weekday, from: d)
            let names = ["日", "一", "二", "三", "四", "五", "六"]
            return names[wd - 1]
        }
        return ""
    }

    // MARK: - 3. Mastered list

    private var doneKidChars: [CharacterDef] {
        KidsCharacters.all.filter { app.doneStrokeIDs.contains($0.id) }
    }

    private var masteredList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("已掌握的字 (\(doneKidChars.count))")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.muted)
            if doneKidChars.isEmpty {
                Text("还没有掌握的字，鼓励孩子开始练习吧")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.muted.opacity(0.7))
                    .padding(.vertical, 12)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                          spacing: 8) {
                    ForEach(doneKidChars.prefix(18), id: \.id) { c in masteredCell(for: c) }
                }
            }
        }
        .padding(14).background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func masteredCell(for c: CharacterDef) -> some View {
        VStack(spacing: 2) {
            Text(c.glyph).font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(Theme.ink)
            if let m = KidsCharacters.metaFor(c.id) {
                Text(m.pinyin).font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.accent)
            }
            if let best = app.bestScores[c.id] {
                Text("\(best)").font(.system(size: 9)).foregroundColor(Theme.muted)
            }
        }
        .frame(maxWidth: .infinity).padding(.vertical, 6)
        .background(Color(red: 1.0, green: 0.96, blue: 0.88))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - 4. Weak list

    private var weakList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("需要加强的字")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.muted)
                Spacer()
                Text("分数 < 70")
                    .font(.system(size: 10)).foregroundColor(Theme.muted.opacity(0.7))
            }
            let weaks = app.weakCharIDs.prefix(6)
            if weaks.isEmpty {
                Text("👍 没有薄弱字，练得很好!")
                    .font(.system(size: 12)).foregroundColor(Theme.muted)
                    .padding(.vertical, 12)
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(weaks), id: \.self) { id in
                        if let c = KidsCharacters.all.first(where: { $0.id == id }) {
                            weakCell(for: c, id: id)
                        }
                    }
                }
            }
        }
        .padding(14).background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func weakCell(for c: CharacterDef, id: String) -> some View {
        VStack(spacing: 2) {
            Text(c.glyph).font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(Theme.accent)
            Text("\(app.bestScores[id] ?? 0) 分")
                .font(.system(size: 10, weight: .bold)).foregroundColor(Theme.accent)
        }
        .frame(width: 48, height: 58)
        .background(Theme.accent.opacity(0.10))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.accent.opacity(0.4), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - 5. Limit settings

    private var limitSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每日时长限制")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.muted)
            Text("今日已用: \(app.todayPracticeMinutes) / \(app.dailyLimitMinutes) 分钟")
                .font(.system(size: 12)).foregroundColor(Theme.ink)
            HStack(spacing: 8) {
                ForEach([10, 15, 20, 30, 45], id: \.self) { limitChip(minutes: $0) }
            }
        }
        .padding(14).background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func limitChip(minutes: Int) -> some View {
        let selected = app.dailyLimitMinutes == minutes
        return Button {
            app.dailyLimitMinutes = minutes
        } label: {
            Text("\(minutes) 分钟")
                .font(.system(size: 13, weight: selected ? .bold : .medium))
                .foregroundColor(selected ? .white : Theme.ink)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Capsule().fill(selected ? Theme.accent : Color.white))
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 6. Total stats

    private var totalStats: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("累计数据").font(.system(size: 11)).foregroundColor(Theme.muted)
                Text("\(app.totalChars) 次练习 · \(app.totalMinutes) 分钟")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Theme.ink)
            }
            Spacer()
        }
        .padding(12).background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Parent Lock (门锁)

struct ParentLockGate: View {
    let onUnlock: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var longPressHeld = false
    @State private var answer: String = ""
    @State private var question: (a: Int, b: Int)? = nil
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: {
                    HStack {
                        Image(systemName: "chevron.left.circle.fill").font(.system(size: 26))
                        Text("返回")
                    }.foregroundColor(Theme.accent)
                }.buttonStyle(.plain)
                Spacer()
            }
            .padding()

            Spacer()

            VStack(spacing: 14) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60)).foregroundColor(Theme.accent)
                Text("家 长 专 区")
                    .font(.system(size: 22, weight: .black, design: .serif)).tracking(6)
                Text("这里是给大人看的进度报告")
                    .font(.system(size: 13)).foregroundColor(Theme.muted)
            }

            if question == nil {
                longPressPad
            } else if let q = question {
                mathChallenge(q: q)
            }

            Spacer()
        }
    }

    private var longPressPad: some View {
        Button { /* handled by gesture */ } label: {
            VStack(spacing: 4) {
                Image(systemName: longPressHeld ? "hand.tap.fill" : "hand.tap")
                    .font(.system(size: 32)).foregroundColor(Theme.accent)
                Text(longPressHeld ? "继续按住..." : "长按 2 秒开始")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.accent)
            }
            .padding(30)
            .background(Theme.accent.opacity(longPressHeld ? 0.2 : 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 2.0)
                .onChanged { _ in longPressHeld = true }
                .onEnded { _ in
                    longPressHeld = false
                    question = (Int.random(in: 7...9), Int.random(in: 6...9))
                }
        )
    }

    private func mathChallenge(q: (a: Int, b: Int)) -> some View {
        VStack(spacing: 16) {
            Text("请回答:").font(.system(size: 13)).foregroundColor(Theme.muted)
            Text("\(q.a) × \(q.b) = ?")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(Theme.ink)
            TextField("答案", text: $answer)
                .keyboardType(.numberPad).multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 120, height: 56).background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if showError {
                Text("答错了，再试一次")
                    .font(.system(size: 12)).foregroundColor(Theme.accent)
            }
            Button("确 认") {
                if Int(answer) == q.a * q.b { onUnlock() }
                else { showError = true; answer = "" }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
