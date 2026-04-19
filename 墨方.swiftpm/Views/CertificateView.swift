import SwiftUI
import UIKit

struct CertificateView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var savedToast: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.18, green: 0.14, blue: 0.12),
                Color(red: 0.32, green: 0.24, blue: 0.18)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                Spacer()
                if app.hasGraduatedL1 {
                    certificateScroll
                    Spacer()
                    actionButtons
                } else {
                    lockedView
                    Spacer()
                }
            }
            .padding(20)

            if let msg = savedToast {
                toastOverlay(msg)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            app.issueL1CertIfNeeded()
            if app.hasGraduatedL1 {
                Sound.fanfare.play()
                Speaker.shared.speak("恭喜完成毕业证书")
            }
        }
    }

    // MARK: - Top bar

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 26))
                    Text("关闭")
                }
                .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
            Text("🎓 毕 业 证 书")
                .font(.system(size: 20, weight: .black, design: .serif))
                .tracking(6)
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 60)
        }
    }

    // MARK: - Certificate scroll

    var certificateScroll: some View {
        VStack(spacing: 0) {
            scrollRod
            VStack(spacing: 18) {
                HStack(spacing: 4) {
                    Text("❃").foregroundColor(Theme.accent)
                    Rectangle().frame(height: 1).foregroundColor(Theme.accent.opacity(0.5))
                    Text("墨方学堂")
                        .font(.system(size: 14, design: .serif))
                        .tracking(6)
                        .foregroundColor(Theme.accent)
                    Rectangle().frame(height: 1).foregroundColor(Theme.accent.opacity(0.5))
                    Text("❃").foregroundColor(Theme.accent)
                }

                Text("毕 业 证 书")
                    .font(.system(size: 40, weight: .black, design: .serif))
                    .tracking(14)
                    .foregroundColor(Theme.ink)

                Text("CERTIFICATE  OF  COMPLETION")
                    .font(.system(size: 10, weight: .light))
                    .tracking(6)
                    .foregroundColor(Theme.muted)

                Text("兹证明")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(Theme.ink)
                    .padding(.top, 8)

                Text(app.nickname)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 4)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Theme.accent.opacity(0.4)),
                        alignment: .bottom
                    )

                Text("同学已圆满完成")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(Theme.ink)

                Text("「 幼 学 初 阶 · 一 十 九 字 」")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .tracking(3)
                    .foregroundColor(Theme.ink)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 10), spacing: 6) {
                    ForEach(KidsCharacters.all.prefix(20)) { c in
                        Text(c.glyph)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Theme.ink)
                            .frame(width: 24, height: 28)
                            .background(Color(red: 0.95, green: 0.90, blue: 0.78).opacity(0.5))
                    }
                }
                .padding(.horizontal, 30)

                Text("特 发 此 证 · 以 资 鼓 励")
                    .font(.system(size: 13, design: .serif))
                    .tracking(2)
                    .foregroundColor(Theme.ink)
                    .padding(.top, 6)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("颁发日期")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.muted)
                        Text(app.certL1IssuedDate.isEmpty ? "—" : app.certL1IssuedDate)
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundColor(Theme.ink)
                    }
                    Spacer()
                    redSeal
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("连续签到")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.muted)
                        Text("\(app.streakDays) 天")
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundColor(Theme.ink)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)

                HStack(spacing: 4) {
                    Text("❃").foregroundColor(Theme.accent)
                    Rectangle().frame(height: 1).foregroundColor(Theme.accent.opacity(0.5))
                    Text("MOSQUARE")
                        .font(.system(size: 9))
                        .tracking(4)
                        .foregroundColor(Theme.accent.opacity(0.6))
                    Rectangle().frame(height: 1).foregroundColor(Theme.accent.opacity(0.5))
                    Text("❃").foregroundColor(Theme.accent)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 30)
            .frame(maxWidth: 520)
            .background(
                LinearGradient(colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.86),
                    Color(red: 0.95, green: 0.90, blue: 0.78)
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                Rectangle()
                    .stroke(Theme.accent.opacity(0.5), lineWidth: 3)
                    .padding(8)
            )
            .overlay(
                Rectangle()
                    .stroke(Theme.accent.opacity(0.25), lineWidth: 1)
                    .padding(4)
            )
            scrollRod
        }
        .id("certificate")
    }

    var scrollRod: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient(colors: [
                Color(red: 0.55, green: 0.35, blue: 0.20),
                Color(red: 0.42, green: 0.25, blue: 0.12)
            ], startPoint: .top, endPoint: .bottom))
            .frame(height: 14)
            .frame(maxWidth: 560)
            .overlay(
                HStack {
                    Circle().fill(Theme.gold).frame(width: 10, height: 10)
                    Spacer()
                    Circle().fill(Theme.gold).frame(width: 10, height: 10)
                }
                .padding(.horizontal, 10)
            )
    }

    var redSeal: some View {
        ZStack {
            Rectangle()
                .fill(Theme.accent.opacity(0.08))
                .frame(width: 62, height: 62)
            Rectangle()
                .stroke(Theme.accent, lineWidth: 3)
                .frame(width: 62, height: 62)
            VStack(spacing: 0) {
                Text("墨")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(Theme.accent)
                Text("方")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(Theme.accent)
            }
        }
        .rotationEffect(.degrees(-4))
    }

    // MARK: - Action buttons

    var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                saveAsImage()
            } label: {
                Label("保存到相册", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(PrimaryButtonStyle())

            ShareLink(item: shareText) {
                Label("分享", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(PrimaryButtonStyle(filled: false))
            .tint(.white)
        }
    }

    var shareText: String {
        "🎓 \(app.nickname) 在墨方完成了幼学初阶 · 19 字毕业! 连续练习 \(app.streakDays) 天 · 解锁 \(app.stickerCount) 枚贴纸 🌟"
    }

    // MARK: - Locked view

    var lockedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            Text("还没毕业呢~")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .tracking(4)
                .foregroundColor(.white)
            let done = KidsCharacters.all.filter { app.doneStrokeIDs.contains($0.id) }.count
            Text("完成全部 \(KidsCharacters.all.count) 个字就能领到证书啦")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
            Text("已完成 \(done) / \(KidsCharacters.all.count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.gold)
                .padding(.top, 6)
            Button("先去练字") { dismiss() }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 20)
        }
        .padding(40)
    }

    // MARK: - Snapshot / toast

    func saveAsImage() {
        let renderer = ImageRenderer(content:
            certificateScroll
                .padding(20)
                .background(Color.black.opacity(0.9))
        )
        renderer.scale = UIScreen.main.scale
        if let img = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            Sound.sticker.play()
            showToast("✓ 已保存到相册")
        } else {
            showToast("保存失败")
        }
    }

    func showToast(_ msg: String) {
        withAnimation { savedToast = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { savedToast = nil }
        }
    }

    func toastOverlay(_ msg: String) -> some View {
        VStack {
            Spacer()
            Text(msg)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.black.opacity(0.75)))
                .padding(.bottom, 80)
        }
        .transition(.opacity)
    }
}
