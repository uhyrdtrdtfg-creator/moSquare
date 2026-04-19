import SwiftUI

/// 零基础开蒙引导：一屏欢迎 + 身份选择 + 第一笔体验
/// 核心目标：让用户第一次就能"写下一笔"并感到舒服
struct OnboardingView: View {
    @EnvironmentObject var app: AppState
    @State private var step: Step = .welcome
    @State private var firstStrokes: [UserStroke] = []
    @State private var firstCompletedCount: Int = 0

    enum Step { case welcome, chooseWho, tryFirst, done }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.10, blue: 0.10),
                         Color(red: 0.22, green: 0.22, blue: 0.22)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            switch step {
            case .welcome:   welcomeScreen
            case .chooseWho: chooseWhoScreen
            case .tryFirst:  firstStrokeScreen
            case .done:      doneScreen
            }
        }
        .foregroundColor(.white)
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // ─── 欢迎屏 ──────────────────────────────────────────────────
    private var welcomeScreen: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("墨方")
                .font(.system(size: 80, weight: .black, design: .serif))
                .tracking(20)
                .foregroundColor(.white)
            Text("M O   S Q U A R E")
                .font(.system(size: 12, weight: .regular))
                .tracking(6)
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 40)

            Text("零 基 础 练 字 · 从 第 一 笔 开 始")
                .font(.system(size: 15, design: .serif))
                .tracking(4)
                .foregroundColor(.white.opacity(0.75))

            Spacer()

            Button("开 始 →") {
                step = .chooseWho
            }
            .buttonStyle(PrimaryButtonStyle(filled: true))
            .padding(.bottom, 60)
        }
    }

    // ─── 身份选择 ────────────────────────────────────────────────
    private var chooseWhoScreen: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("谁 来 练 字 ?")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .tracking(6)

            Text("我们会根据不同情况调整难度和引导")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.65))
                .padding(.bottom, 28)

            VStack(spacing: 14) {
                roleCard(
                    emoji: "🧒",
                    title: "小朋友（4-5 岁）",
                    desc: "大格子 · 跟着提示一笔一笔写 · 写对才出现下一笔",
                    bg: LinearGradient(colors: [
                        Color(red: 0.85, green: 0.35, blue: 0.25),
                        Color(red: 0.95, green: 0.55, blue: 0.30)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    app.setMode(.kid)
                    step = .tryFirst
                }

                roleCard(
                    emoji: "🙋",
                    title: "我已经会写字",
                    desc: "从基本笔画开始，练出好看的字 · 带 AI 评分",
                    bg: LinearGradient(colors: [
                        Color(red: 0.22, green: 0.34, blue: 0.52),
                        Color(red: 0.14, green: 0.20, blue: 0.36)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    app.setMode(.adult)
                    step = .tryFirst
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Text("之后可以在「书房 → 设置」里修改")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 28)
        }
    }

    private func roleCard<Bg: ShapeStyle>(
        emoji: String, title: String, desc: String,
        bg: Bg, onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(emoji).font(.system(size: 44))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    // ─── 第一笔体验（根据身份选择走不同流程） ────────────────
    private var firstStrokeScreen: some View {
        VStack(spacing: 18) {
            Text(app.isKidMode ? "来 · 写 一 个 「一」" : "第 一 笔 · 横")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .tracking(6)
                .padding(.top, 30)
            Text(app.isKidMode
                 ? "跟着红点开始、顺着箭头画出去～"
                 : "顺着灰色笔迹写一下，不用完美")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))

            if app.isKidMode {
                // 幼儿：用逐笔描摹模式写"一"字
                PracticeCanvas(
                    character: KidsCharacters.一,
                    mode: .guided,
                    strokes: $firstStrokes,
                    onStrokeEnd: { stroke in
                        let target = KidsCharacters.一.strokes[0]
                        if StrokeMatcher.match(user: stroke, target: target, config: .kid).isMatched {
                            firstCompletedCount = 1
                            // 0.8 秒后自动进入完成页
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                app.recordAttempt(charID: "kid:一", score: 90, durationSeconds: 20)
                                step = .done
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                    app.markOnboarded()
                                }
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !firstStrokes.isEmpty {
                                    firstStrokes.removeLast()
                                }
                            }
                        }
                    },
                    guidedCompletedCount: firstCompletedCount,
                    guidedShowStandardInk: true,
                    isKidMode: true
                )
                .frame(maxWidth: 420)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            } else {
                // 成人：描红八画之首
                PracticeCanvas(
                    character: StandardStrokes.all[0],
                    mode: .trace,
                    strokes: $firstStrokes
                )
                .frame(maxWidth: 420)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }

            if app.isKidMode {
                if firstStrokes.isEmpty {
                    Text("用手指或笔在红点处按住，画一条线～")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                if firstStrokes.isEmpty {
                    Text("按住并在格子里画一条横线～")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    Button("完成，进入主界面") {
                        step = .done
                        app.recordAttempt(charID: StandardStrokes.all[0].id,
                                          score: 85, durationSeconds: 30)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            app.markOnboarded()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }

            Spacer()

            Button("跳过这一步") {
                app.markOnboarded()
            }
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.5))
            .padding(.bottom, 30)
        }
    }

    // ─── 完成屏 ───────────────────────────────────────────────────
    private var doneScreen: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🎉")
                .font(.system(size: 80))
            Text(app.isKidMode ? "你写出了第一个字！" : "你写下了人生的第一笔")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .tracking(4)
            Text(app.isKidMode
                 ? "接下来我们一起认识\n数字、人、口、山、日、月…"
                 : "接下来我们会一起走过：\n八画 → 偏旁 → 独体 → 结构 → 成字")
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 6)

            HStack(spacing: 4) {
                ForEach(0..<6) { i in
                    Capsule()
                        .fill(i == 0 ? Theme.accent : Color.white.opacity(0.15))
                        .frame(width: 30, height: 4)
                }
            }
            .padding(.top, 20)

            Spacer()
        }
    }
}
