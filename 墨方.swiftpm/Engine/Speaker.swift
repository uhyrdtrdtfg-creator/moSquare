import SwiftUI
import AVFoundation
import AudioToolbox

/// 语音 + 音效服务（幼儿模式用）
///
/// ## 声音自然度的三个档次（iOS 会按设备可用度自动回落）
/// 1. **Premium / Siri Neural**：需用户在 设置 → 辅助功能 → 朗读内容 → 声音 → 中文
///    里下载"Siri 声音 1/2"或"增强版声音"后才可用。音质接近真人。
/// 2. **Enhanced**：同上路径可下载的"增强版"，比默认好不少。
/// 3. **Default (compact)**：iOS 预装的 Ting-Ting，较生硬；未下载上述声音时回落到这里。
///
/// 我们的策略：**自动选择设备上质量最高的中文语音**。
@MainActor
final class Speaker {
    static let shared = Speaker()

    private let synth = AVSpeechSynthesizer()
    private var mp3Player: AVAudioPlayer?

    /// 缓存选中的中文语音（避免每次朗读都遍历）
    private lazy var chineseVoice: AVSpeechSynthesisVoice? = Self.bestChineseVoice()

    private init() {
        configureAudioSession()
    }

    /// 朗读中文
    /// - 策略：如果文本是**单个汉字**且 bundle 里有对应 MP3（晓晓神经网络预生成），
    ///   优先播 MP3（音质最高）；否则用系统 TTS。
    func speak(_ text: String, rate: Float = 0.42) {
        // 停掉上一次
        synth.stopSpeaking(at: .immediate)
        mp3Player?.stop()
        mp3Player = nil

        // 先看是不是单个字 + 是否有 MP3
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.count == 1,
           let url = audioURL(for: trimmed) {
            playMP3(at: url)
            return
        }

        // 回落：系统 TTS
        let utter = AVSpeechUtterance(string: text)
        utter.voice = chineseVoice ?? AVSpeechSynthesisVoice(language: "zh-CN")
        utter.rate = rate
        utter.pitchMultiplier = 1.08
        utter.volume = 1.0
        synth.speak(utter)
    }

    /// 单字 MP3 查找（bundle 里的 Resources/audio/<字>.mp3）
    private func audioURL(for char: String) -> URL? {
        // Swift Package 资源：用 char 作文件名，扩展名 mp3
        // subdirectory "audio" 因 Package.swift 使用 .process("Resources") 保留目录结构
        Bundle.main.url(forResource: char, withExtension: "mp3", subdirectory: "audio")
            ?? Bundle.main.url(forResource: char, withExtension: "mp3")
    }

    private func playMP3(at url: URL) {
        do {
            mp3Player = try AVAudioPlayer(contentsOf: url)
            mp3Player?.prepareToPlay()
            mp3Player?.play()
        } catch {
            print("[Speaker] MP3 playback failed for \(url.lastPathComponent): \(error)")
            // 失败时回落到 TTS
            let utter = AVSpeechUtterance(string: url.deletingPathExtension().lastPathComponent)
            utter.voice = chineseVoice
            synth.speak(utter)
        }
    }

    /// 让用户手动指定某个 voice identifier（未来接"音色选择"时用）
    func setVoice(identifier: String) {
        if let v = AVSpeechSynthesisVoice(identifier: identifier) {
            chineseVoice = v
        }
    }

    /// 当前正在用的声音描述（用于 Debug / 家长设置里显示）
    var currentVoiceDescription: String {
        guard let v = chineseVoice else { return "系统默认" }
        let quality: String
        switch v.quality {
        case .premium:  quality = "Siri 神经网络"
        case .enhanced: quality = "增强版"
        default:        quality = "标准版"
        }
        return "\(v.name) · \(quality)"
    }

    /// 立即停止
    func stop() {
        synth.stopSpeaking(at: .immediate)
        mp3Player?.stop()
        mp3Player = nil
    }

    // ─── 核心：挑最好的中文声音 ──────────────────────────────
    //
    // 优先级：
    //  1. Siri Personality 声线（iOS 16+ 神经网络，最自然）
    //  2. Premium（高清神经网络）
    //  3. Enhanced（增强版）
    //  4. zh-CN 默认（Ting-Ting compact，最生硬）
    //
    static func bestChineseVoice() -> AVSpeechSynthesisVoice? {
        let all = AVSpeechSynthesisVoice.speechVoices()

        // 只看中文（大陆普通话）
        let chinese = all.filter { v in
            v.language.hasPrefix("zh-CN") ||
            v.language.hasPrefix("cmn")
        }

        if chinese.isEmpty {
            return AVSpeechSynthesisVoice(language: "zh-CN")
        }

        // 按质量排名
        func rank(_ v: AVSpeechSynthesisVoice) -> Int {
            // Siri 神经网络声线排最高（identifier 含 "siri"）
            if v.identifier.lowercased().contains("siri") { return 100 }
            switch v.quality {
            case .premium:  return 80
            case .enhanced: return 60
            default:        return 20
            }
        }

        let sorted = chinese.sorted { rank($0) > rank($1) }

        #if DEBUG
        print("[Speaker] 可用中文语音 (\(sorted.count)):")
        for v in sorted {
            print("  \(rank(v)) · \(v.name) · \(v.identifier) · quality=\(v.quality.rawValue)")
        }
        if let chosen = sorted.first {
            print("[Speaker] 选中: \(chosen.name)")
        }
        #endif

        return sorted.first
    }

    // ─── 音频会话配置（避免被其它 app 音乐静默） ─────────────
    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Speaker] AVAudioSession setup failed: \(error)")
        }
        #endif
    }

    /// 返回所有可用中文声音（供"音色选择"设置用）
    static func availableChineseVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("zh-CN") || $0.language.hasPrefix("cmn") }
            .sorted { lhs, rhs in
                // Siri/premium/enhanced 排前面
                let la = lhs.identifier.lowercased().contains("siri") ? 3 :
                         (lhs.quality == .premium ? 2 :
                          (lhs.quality == .enhanced ? 1 : 0))
                let ra = rhs.identifier.lowercased().contains("siri") ? 3 :
                         (rhs.quality == .premium ? 2 :
                          (rhs.quality == .enhanced ? 1 : 0))
                return la > ra
            }
    }
}

/// 轻量音效（系统内置，免资源文件）
enum Sound {
    case success      // 笔画过关：上扬"叮"
    case fanfare      // 整字完成：愉悦长音
    case fail         // 写错：低沉音
    case pop          // UI 点击
    case sticker      // 解锁贴纸

    private var systemID: SystemSoundID {
        switch self {
        case .success:  return 1057   // Tink (上扬)
        case .fanfare:  return 1025   // Tweet
        case .fail:     return 1053   // Bassism (下沉)
        case .pop:      return 1104   // SimToolkitGeneralBeep
        case .sticker:  return 1322   // NewMail
        }
    }

    func play() {
        AudioServicesPlaySystemSound(systemID)
    }
}
