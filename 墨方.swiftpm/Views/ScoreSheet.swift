import SwiftUI

/// 评分结果展示（分数 + 四维条 + 可执行建议）
struct ScoreSheet: View {
    let result: ScoreResult
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(result.total)")
                    .font(.system(size: 56, weight: .black, design: .serif))
                    .foregroundColor(result.total >= 85 ? Theme.accent : Theme.ink)
                Text("/ 100")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.muted)
                Spacer()
                Button(action: onNext) {
                    HStack(spacing: 4) {
                        Text(result.total >= 85 ? "下一笔" : "再写一次")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(filled: result.total >= 85))
            }

            // 四维条
            VStack(spacing: 6) {
                bar(label: "形", value: result.shape)
                bar(label: "顺", value: result.order)
                bar(label: "势", value: result.fluency)
                bar(label: "距", value: result.layout)
            }
            .padding(.top, 6)

            // 评语
            Text("\(result.feedback.emoji) \(result.feedback.praise)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.accent2)
                .padding(.top, 4)

            // 建议
            if !result.feedback.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(result.feedback.suggestions, id: \.self) { s in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").foregroundColor(Theme.accent)
                            Text(s)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.ink.opacity(0.75))
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func bar(label: String, value: Int) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .serif))
                .frame(width: 14)
                .foregroundColor(Theme.muted)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.line.opacity(0.5))
                    Capsule()
                        .fill(LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                }
                .frame(height: 6)
            }
            .frame(height: 6)
            Text("\(value)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.muted)
                .frame(width: 26, alignment: .trailing)
        }
    }
}
