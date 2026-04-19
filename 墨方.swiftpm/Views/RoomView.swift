import SwiftUI

/// 书房：段位 / 作品墙 / 勋章 / 设置
struct RoomView: View {
    @EnvironmentObject var app: AppState
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    rankCard
                    statsRow
                    if app.isKidMode {
                        stickerAlbumSection
                        kidBadgesSection
                    } else {
                        wallSection
                        badgesSection
                    }
                    settingsSection
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(PaperBackground())
            .navigationBarHidden(true)
        }
        .alert("清除所有进度？", isPresented: $showResetConfirm) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) { app.resetAll() }
        } message: {
            Text("这会清空已掌握字、最高分、连续天数。此操作不可撤销。")
        }
    }

    // ─── 段位卡 ──────────────────────────────────────────────────
    private var rankCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("段 位  ·  \(app.rankLabel)")
                .font(.system(size: 11, weight: .bold))
                .tracking(3)
                .foregroundColor(Theme.gold)
                .padding(.horizontal, 10).padding(.vertical, 3)
                .background(Theme.gold.opacity(0.15))
                .clipShape(Capsule())

            Text(app.nickname)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .tracking(2)
                .foregroundColor(.white)

            Text("已掌握 \(app.doneStrokeIDs.count)/\(StandardStrokes.all.count) 笔  ·  练字 \(app.totalChars) 次  ·  共 \(app.totalMinutes) 分钟")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Theme.accent2, Theme.ink],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // ─── 数据行 ──────────────────────────────────────────────────
    private var statsRow: some View {
        HStack(spacing: 10) {
            stat("连签", value: "\(app.streakDays)", unit: "天")
            stat("最高", value: bestString, unit: "分")
            stat("速写", value: "\(app.bestSpeedScore)", unit: "分")
        }
    }

    private var bestString: String {
        let best = app.bestScores.values.max() ?? 0
        return "\(best)"
    }

    private func stat(_ title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.system(size: 11)).tracking(2).foregroundColor(Theme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Theme.accent)
                Text(unit).font(.system(size: 11)).foregroundColor(Theme.muted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // ─── 作品墙 ──────────────────────────────────────────────────
    private var wallSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("作品墙 · L1 八画")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                      spacing: 8) {
                ForEach(StandardStrokes.all) { c in
                    wallCell(c)
                }
            }
            if app.isL1Complete || app.doneStrokeIDs.contains(where: { $0.hasPrefix("radical:") }) {
                sectionTitle("作品墙 · L2 偏旁").padding(.top, 8)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                          spacing: 8) {
                    ForEach(StandardRadicals.all) { c in
                        wallCell(c)
                    }
                }
            }
        }
    }

    private func wallCell(_ c: CharacterDef) -> some View {
        let done = app.doneStrokeIDs.contains(c.id)
        let best = app.bestScores[c.id] ?? 0
        return ZStack(alignment: .bottomTrailing) {
            ZStack {
                Color.white
                if done {
                    GuideStrokeView(strokes: c.strokes, opacity: 0.95, showArrow: false)
                } else {
                    GuideStrokeView(strokes: c.strokes, opacity: 0.12, showArrow: false)
                    Image(systemName: "lock.fill")
                        .foregroundColor(Theme.muted.opacity(0.5))
                }
            }
            .aspectRatio(3 / 4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.line, lineWidth: 1))

            if best > 0 {
                Text("\(best)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .padding(4)
            }
        }
    }

    // ─── 贴纸册（幼儿模式专属） ─────────────────────────────────
    private var stickerAlbumSection: some View {
        let allKidChars = KidsCharacters.all + KidsCharactersExtra.all + KidsCharactersPack3.all
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionTitle("贴纸册")
                Spacer()
                Text("已收集 \(app.stickerCount) / \(allKidChars.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Theme.accent.opacity(0.12)))
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5),
                spacing: 10
            ) {
                ForEach(allKidChars) { c in
                    stickerCell(c)
                }
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.95, blue: 0.85),
                        Color(red: 1.00, green: 0.88, blue: 0.80)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.95, green: 0.75, blue: 0.45).opacity(0.4), lineWidth: 1)
            )
        }
    }

    private func stickerCell(_ c: CharacterDef) -> some View {
        let unlocked = app.stickers.contains(c.id)
        let meta = KidsCharacters.metaFor(c.id)
        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(unlocked
                          ? LinearGradient(
                              colors: [Color.white, Color(red: 1.0, green: 0.92, blue: 0.78)],
                              startPoint: .top, endPoint: .bottom
                          )
                          : LinearGradient(
                              colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.22)],
                              startPoint: .top, endPoint: .bottom
                          ))
                Text(unlocked ? (meta?.sticker ?? "⭐") : "?")
                    .font(.system(size: unlocked ? 28 : 20, weight: .bold))
                    .foregroundColor(unlocked ? .primary : Theme.muted.opacity(0.6))
            }
            .frame(width: 52, height: 52)
            .overlay(
                Circle()
                    .stroke(unlocked ? Theme.accent.opacity(0.4) : Theme.line,
                            lineWidth: unlocked ? 2 : 1)
            )
            Text(c.glyph)
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .foregroundColor(unlocked ? Theme.ink : Theme.muted)
        }
    }

    // ─── 勋章 ────────────────────────────────────────────────────
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("勋章")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                      spacing: 8) {
                badge("始", desc: "第一笔",     unlocked: app.onboarded)
                badge("勤", desc: "连签 1 日",  unlocked: app.streakDays >= 1)
                badge("熟", desc: "连签 7 日",  unlocked: app.streakDays >= 7)
                badge("雅", desc: "单字 ≥95",  unlocked: (app.bestScores.values.max() ?? 0) >= 95)
                badge("速", desc: "速写 ≥20",  unlocked: app.bestSpeedScore >= 20)
                badge("察", desc: "笔顺满分",  unlocked: false)
                badge("临", desc: "完成 L1",   unlocked: app.isL1Complete)
                badge("旁", desc: "完成 L2",   unlocked: app.isL2Complete)
            }
        }
    }

    private func badge(_ ch: String, desc: String, unlocked: Bool) -> some View {
        VStack(spacing: 4) {
            Text(ch)
                .font(.system(size: 22, weight: .black, design: .serif))
                .foregroundColor(unlocked ? .white : Theme.muted)
                .frame(width: 44, height: 44)
                .background(unlocked ? Theme.accent : Color.white)
                .overlay(Circle().stroke(Theme.line, lineWidth: 1))
                .clipShape(Circle())
            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(unlocked ? Theme.ink : Theme.muted)
        }
        .frame(maxWidth: .infinity)
    }

    // ─── 幼儿勋章 ───────────────────────────────────────────────
    private var kidBadgesSection: some View {
        let kidDone = app.doneStrokeIDs.filter { $0.hasPrefix("kid:") }.count
        return VStack(alignment: .leading, spacing: 8) {
            sectionTitle("勋章")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                      spacing: 8) {
                kidBadge("🌟", desc: "第一个字",  unlocked: app.onboarded)
                kidBadge("🔥", desc: "连签 3 日",  unlocked: app.streakDays >= 3)
                kidBadge("🎯", desc: "学会 5 字",  unlocked: kidDone >= 5)
                kidBadge("🌈", desc: "学会 10 字", unlocked: kidDone >= 10)
                kidBadge("🏆", desc: "毕业",      unlocked: app.hasGraduatedL1)
                kidBadge("🧩", desc: "学会组字",  unlocked: !app.compositesLearned.isEmpty)
                kidBadge("📖", desc: "读完故事",  unlocked: !app.storiesRead.isEmpty)
                kidBadge("🐣", desc: "宠物长大",  unlocked: app.petStageIndex >= 1)
            }
        }
    }

    private func kidBadge(_ emoji: String, desc: String, unlocked: Bool) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(unlocked ? Theme.highlight : Color.white)
                .overlay(
                    Circle().stroke(unlocked ? Theme.gold : Theme.line,
                                    lineWidth: unlocked ? 2 : 1)
                )
                .clipShape(Circle())
                .opacity(unlocked ? 1 : 0.35)
            Text(desc)
                .font(.system(size: 10, weight: unlocked ? .semibold : .regular))
                .foregroundColor(unlocked ? Theme.ink : Theme.muted)
        }
        .frame(maxWidth: .infinity)
    }

    // ─── 设置 ────────────────────────────────────────────────────
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("设置")
            VStack(spacing: 0) {
                row {
                    Text("昵称")
                    Spacer()
                    TextField("新同学", text: $app.nickname)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(Theme.muted)
                        .frame(maxWidth: 160)
                }
                Divider().overlay(Theme.line)
                HStack {
                    Text("练字模式")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { app.userMode },
                        set: { app.setMode($0) }
                    )) {
                        Text("🧒 小朋友").tag(AppState.UserMode.kid)
                        Text("🙋 成人").tag(AppState.UserMode.adult)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .font(.system(size: 14))
                .foregroundColor(Theme.ink)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                Divider().overlay(Theme.line)
                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    HStack {
                        Text("清除所有进度")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(Theme.accent)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack { content() }
            .font(.system(size: 14))
            .foregroundColor(Theme.ink)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s).font(.system(size: 12)).tracking(2).foregroundColor(Theme.muted)
    }
}
