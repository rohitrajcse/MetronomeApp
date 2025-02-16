import AVFoundation
import CoreHaptics

@MainActor // Ensure all methods in this class are executed on the main thread
class MetronomeManager: ObservableObject {
    @Published var isPlaying = false
    @Published var bpm: Double = 120 {
        didSet {
            updateTimer()
        }
    }
    @Published var timeSignature: String = "4/4"
    @Published var selectedSound: String = "belt-slap-fat_A#.wav"
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var hapticEngine: CHHapticEngine?

    init() {
        setupAudio()
        setupHaptics()
    }
    
    func setupAudio() {
        // Load the selected sound dynamically based on the selection
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
            playHaptics()  // Ensure haptic feedback plays on the main thread
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
                    self?.playClick()  // Ensure playClick() is called on the main thread
                    self?.playHaptics() // Ensure playHaptics() is called on the main thread
                }
            }
        }
    }

    private func playClick() {
        // Reload the sound each time the metronome is played
        setupAudio()
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func playHaptics() {
        // Check if vibration is enabled on the main thread
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
