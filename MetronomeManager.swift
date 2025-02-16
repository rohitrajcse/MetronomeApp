import AVFoundation
import CoreHaptics

@MainActor
class MetronomeManager: ObservableObject {
    @Published var isPlaying = false
    @Published var bpm: Double = 120 {
        didSet {
            updateTimer()
        }
    }
    @Published var selectedSound: String = "belt-slap-fat_A#.wav"

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var hapticEngine: CHHapticEngine?

    init() {
        setupAudio()
        setupHaptics()
    }
    
    func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: selectedSound, withExtension: nil) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    func setupHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error setting up haptic engine: \(error.localizedDescription)")
        }
    }

    func startMetronome() {
        isPlaying = true
        updateTimer()
        Task { @MainActor in
            playHaptics()
        }
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
    }
    
    private func updateTimer() {
        timer?.invalidate()
        if isPlaying {
            let interval = 60.0 / bpm
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.playClick()
                    self?.playHaptics()
                }
            }
        }
    }

    private func playClick() {
        setupAudio()
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func playHaptics() {
        if SettingsManager.shared.isVibrationEnabled, let hapticEngine = hapticEngine {
            let pattern = try? CHHapticPattern(events: [CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)], parameters: [])
            if let pattern = pattern {
                do {
                    let player = try hapticEngine.makePlayer(with: pattern)
                    try player.start(atTime: 0)
                } catch {
                    print("Haptic playback failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
