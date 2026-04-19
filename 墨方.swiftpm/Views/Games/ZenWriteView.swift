import SwiftUI

/// 静心禅写 · 无评分冥想式书写
/// 玩法：
/// - 给出一段千字文（16 字）
/// - 一次写一个字，不评分、不计时
/// - 完成后把用户所有笔迹拼成一幅"作品"展示
struct ZenWriteView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    /// 千字文开篇四句
    static let passage = Array("天地玄黄宇宙洪荒日月盈昃辰宿列张")

    @State private var charIndex = 0
    @State private var strokes: [UserStroke] = []
    @State private var captures: [UIImage] = []   // 每字完成后的截图
    @State private var isOver = false

    var body: some View {
        ZStack {
            zenBackground.ignoresSafeArea()
            if isOver {
                artworkView
            } else {
                writingView
            }
        }
    }

    // ─── 背景 ────────────────────────────────────────────────────
    private var zenBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.14),
                Color(red: 0.18, green: 0.20, blue: 0.22)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    // ─── 书写界面 ────────────────────────────────────────────────
    private var writingView: some View {
        VStack(spacing: 18) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Label("退出", systemImage: "xmark")
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("禅 · 静 心 书 写")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .tracking(6)
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                Text("\(charIndex + 1) / \(Self.passage.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // 段落预览 · 已写过的字高亮
            passageStrip

            Text(String(Self.passage[charIndex]))
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundColor(.white.opacity(0.85))

            // 画布
            canvasCard

            // 操作按钮
            HStack(spacing: 12) {
                Button("清除") { strokes.removeAll() }
                    .buttonStyle(GhostButtonStyle())
                    .disabled(strokes.isEmpty)

                Button(charIndex + 1 == Self.passage.count ? "完成作品 →" : "下一字 →") {
                    advance()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(strokes.isEmpty)
            }

            Text("无评分 · 只是此刻你与墨")
                .font(.system(size: 11))
                .tracking(3)
                .foregroundColor(.white.opacity(0.35))

            Spacer()
        }
    }

    private var passageStrip: some View {
        HStack(spacing: 2) {
            ForEach(Self.passage.indices, id: \.self) { i in
                Text(String(Self.passage[i]))
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(i < charIndex
                                     ? Color(red: 0.96, green: 0.83, blue: 0.48)
                                     : (i == charIndex
                                        ? .white
                                        : .white.opacity(0.22)))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }

    private var canvasCard: some View {
        ZStack {
            Color(red: 0.98, green: 0.95, blue: 0.88)
            RiceGrid(color: Color(red: 0.69, green: 0.54, blue: 0.24).opacity(0.35),
                     dashColor: Color(red: 0.69, green: 0.54, blue: 0.24).opacity(0.18))
            InkCanvasWriter(strokes: $strokes)
        }
        .frame(maxWidth: 360, maxHeight: 360)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.69, green: 0.54, blue: 0.24).opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 14, y: 4)
        .padding(.horizontal, 30)
    }

    // ─── 动作 ────────────────────────────────────────────────────
    private func advance() {
        // 简化版：这里不做截图，仅用笔迹数量作为完成标记
        captures.append(UIImage())   // 占位
        strokes.removeAll()
        if charIndex + 1 >= Self.passage.count {
            isOver = true
        } else {
            charIndex += 1
        }
    }

    // ─── 结束作品 ────────────────────────────────────────────────
    private var artworkView: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 20)
            Text("作 品")
                .font(.system(size: 14)).tracking(6)
                .foregroundColor(.white.opacity(0.6))
            Text("千字文 · 其一")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .tracking(4)
                .foregroundColor(.white)

            // 作品以卷轴形式展示（4×4 排列）
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(54), spacing: 2), count: 4),
                spacing: 2
            ) {
                ForEach(Self.passage.indices, id: \.self) { i in
                    Text(String(Self.passage[i]))
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(Color(red: 0.10, green: 0.10, blue: 0.10))
                        .frame(width: 54, height: 54)
                        .background(Color(red: 0.98, green: 0.95, blue: 0.88))
                        .overlay(
                            Rectangle()
                                .stroke(Color(red: 0.69, green: 0.54, blue: 0.24).opacity(0.4),
                                        lineWidth: 0.5)
                        )
                }
            }
            .padding(10)
            .background(Color(red: 0.96, green: 0.93, blue: 0.85))
            .overlay(
                Rectangle()
                    .stroke(Color(red: 0.69, green: 0.54, blue: 0.24), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 20)
            .padding(.horizontal, 20)

            Text("心静则字静")
                .font(.system(size: 13, design: .serif))
                .tracking(6)
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 10)

            Spacer()

            HStack(spacing: 12) {
                Button("再来一次") {
                    charIndex = 0
                    strokes.removeAll()
                    captures.removeAll()
                    isOver = false
                }
                .buttonStyle(PrimaryButtonStyle())
                Button("返回") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.bottom, 30)
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 禅写模式用的简化书写画布（仅绘制，无评分）
// ─────────────────────────────────────────────────────────────────

private struct InkCanvasWriter: View {
    @Binding var strokes: [UserStroke]

    var body: some View {
        GeometryReader { geo in
            InkCanvasView(strokes: $strokes, canvasSize: geo.size, allowsFinger: true)
        }
    }
}
