import SwiftUI

// MARK: - Outfit option model

struct OutfitOption {
    let key: String
    let emoji: String
    let label: String
    let unlockStageIdx: Int
}

enum AllOutfits {
    static let list: [OutfitOption] = [
        .init(key: "default", emoji: "✨", label: "原装",  unlockStageIdx: 0),
        .init(key: "scarf",   emoji: "🧣", label: "围巾",  unlockStageIdx: 1),
        .init(key: "hat",     emoji: "🎩", label: "帽子",  unlockStageIdx: 2),
        .init(key: "bow",     emoji: "🎀", label: "领结",  unlockStageIdx: 3),
        .init(key: "crown",   emoji: "👑", label: "皇冠",  unlockStageIdx: 4),
        .init(key: "halo",    emoji: "😇", label: "光环",  unlockStageIdx: 5)
    ]
}

// MARK: - Virtual Pet View

struct VirtualPetView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var bubbleText: String? = nil
    @State private var petBounce: Bool = false
    @State private var showRename: Bool = false
    @State private var newName: String = ""
    @State private var showOutfitPicker: Bool = false

    var body: some View {
        ZStack {
            petBackground
            VStack(spacing: 14) {
                topBar
                stageInfo
                Spacer(minLength: 0)
                petArea
                Spacer(minLength: 0)
                statsRow
                actionButtons
                outfitRow
            }
            .padding(20)

            if let bubble = bubbleText {
                speechBubbleOverlay(bubble)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            app.unlockOutfitIfReached()
            greetPet()
        }
        .alert("给墨墨起个名字", isPresented: $showRename) {
            TextField("名字", text: $newName)
            Button("取消", role: .cancel) { }
            Button("好") {
                let trimmed = newName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { app.petName = trimmed }
            }
        }
    }

    // MARK: - Background

    private var petBackground: some View {
        LinearGradient(colors: [
            Color(red: 0.72, green: 0.85, blue: 0.96),
            Color(red: 0.98, green: 0.92, blue: 0.88),
            Color(red: 0.94, green: 0.92, blue: 0.76)
        ], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 24))
                    Text("返回")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Theme.ink)
            }
            Spacer()
            Text("🏡 \(app.petName) 的小屋")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Theme.ink)
            Spacer()
            Button {
                newName = app.petName
                showRename = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.accent)
            }
        }
    }

    // MARK: - Stage Info

    private var stageInfo: some View {
        HStack(spacing: 8) {
            Text(app.petStage.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(Theme.ink)
            Text("·")
                .foregroundColor(Theme.muted)
            Text(app.petStage.tagline)
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
            Text(app.petMood)
                .font(.system(size: 22))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.6)))
    }

    // MARK: - Pet Area

    private var petArea: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: 240, height: 30)
                .offset(y: 120)
            ZStack {
                Text(app.petStage.emoji)
                    .font(.system(size: 140))
                    .scaleEffect(petBounce ? 1.12 : 1.0)
                    .rotationEffect(.degrees(petBounce ? 4 : 0))
                outfitOverlay
            }
        }
        .frame(height: 240)
        .contentShape(Rectangle())
        .onTapGesture { tapPet() }
    }

    private var outfitOverlay: some View {
        Group {
            switch app.petOutfit {
            case "scarf":
                Text("🧣")
                    .font(.system(size: 54))
                    .offset(x: 0, y: 36)
            case "hat":
                Text("🎩")
                    .font(.system(size: 54))
                    .offset(x: 0, y: -62)
            case "bow":
                Text("🎀")
                    .font(.system(size: 46))
                    .offset(x: 0, y: -48)
            case "crown":
                Text("👑")
                    .font(.system(size: 58))
                    .offset(x: 0, y: -70)
            case "halo":
                ZStack {
                    Text("✨").font(.system(size: 34)).offset(x: -60, y: -60)
                    Text("✨").font(.system(size: 34)).offset(x: 60, y: -40)
                    Text("⭕️").font(.system(size: 60)).opacity(0.5).offset(x: 0, y: -78)
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            // food bar
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("🍎").font(.system(size: 14))
                    Text("饱食")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.muted)
                    Spacer()
                    Text("\(app.petFood)/100")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.line.opacity(0.4))
                            .frame(height: 10)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.3),
                                         Color(red: 1.0, green: 0.4, blue: 0.2)],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(app.petFood) / 100, height: 10)
                    }
                }
                .frame(height: 10)
            }

            // exp bar
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("⭐").font(.system(size: 14))
                    Text("经验")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.muted)
                    Spacer()
                    Text("\(app.petExp)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.line.opacity(0.4))
                            .frame(height: 10)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Theme.gold, Theme.accent],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * expProgress, height: 10)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var expProgress: CGFloat {
        guard let next = app.petNextStage else { return 1.0 }
        let lo = app.petStage.minExp
        let hi = next.minExp
        let e = app.petExp
        guard hi > lo else { return 1.0 }
        return max(0, min(1, CGFloat(e - lo) / CGFloat(hi - lo)))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                feedAction()
            } label: {
                HStack(spacing: 4) {
                    Text("🍎")
                    Text("喂一口")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(app.petFood >= 100)

            Button {
                playAction()
            } label: {
                HStack(spacing: 4) {
                    Text("🎾")
                    Text("陪玩")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .buttonStyle(PrimaryButtonStyle(filled: false))
        }
    }

    // MARK: - Outfit Row

    private var outfitRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AllOutfits.list, id: \.key) { o in
                    outfitChip(o)
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.vertical, 4)
    }

    private func outfitChip(_ o: OutfitOption) -> some View {
        let owned = app.petOutfitsOwned.contains(o.key)
        let isCurrent = app.petOutfit == o.key
        return Button {
            if owned {
                app.equipOutfit(o.key)
                Sound.sticker.play()
                flashBubble("好看吗?")
            } else {
                flashBubble("练字升级后解锁~")
            }
        } label: {
            VStack(spacing: 2) {
                Text(o.emoji)
                    .font(.system(size: 24))
                    .opacity(owned ? 1 : 0.35)
                Text(o.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(owned ? Theme.ink : Theme.muted)
                if !owned {
                    Text("🔒").font(.system(size: 9))
                }
            }
            .frame(width: 54, height: 62)
            .background(isCurrent ? Theme.accent.opacity(0.15) : Color.white.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrent ? Theme.accent : Theme.line,
                            lineWidth: isCurrent ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func feedAction() {
        guard app.petFood < 100 else {
            flashBubble("已经饱啦~")
            return
        }
        app.manualFeedPet()
        Sound.success.play()
        petJiggle()
        flashBubble("好吃! 谢谢!")
    }

    private func playAction() {
        Sound.sticker.play()
        petJiggle()
        let phrases = ["咿呀!", "好开心!", "再来嘛~", "嘻嘻~", "抱抱!", "你真好!"]
        let picked = phrases.randomElement() ?? "嘿嘿!"
        flashBubble(picked)
        Speaker.shared.speak(picked)
    }

    private func tapPet() {
        petJiggle()
        Sound.success.play()
        let phrases = ["嗨!", "你好呀!", "嘻嘻!", "点我干嘛~", "hi!"]
        flashBubble(phrases.randomElement() ?? "嗨!")
    }

    private func petJiggle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            petBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                petBounce = false
            }
        }
    }

    private func flashBubble(_ text: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            bubbleText = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { bubbleText = nil }
        }
    }

    private func greetPet() {
        let greetings = [
            "\(app.petName)在等你呢~",
            "欢迎回来! \(app.petName)想你了",
            "一起练字吧!"
        ]
        flashBubble(greetings.randomElement() ?? "嗨~")
    }

    private func speechBubbleOverlay(_ text: String) -> some View {
        VStack {
            Spacer()
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
            }
            .offset(y: -280)
            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
        .allowsHitTesting(false)
    }
}
