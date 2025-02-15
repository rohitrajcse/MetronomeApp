import SwiftUI
import AVFoundation

// Metronome Manager
class MetronomeManager: ObservableObject {
    @Published var isPlaying = false
    @Published var bpm: Double = 120 {
        didSet {
            updateTimer()
        }
    }
    @Published var timeSignature: String = "4/4"
    @Published var selectedSound: String = "Click" // New property for sound selection
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    init() {
        loadClickSound() // Load default sound
    }
    
    func loadClickSound() {
        let soundName = selectedSound.lowercased() // Get the current sound
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                print("\(soundName.capitalized) Audio Player successfully initialized.")
            } catch {
                print("Error loading \(soundName) sound: \(error.localizedDescription)")
            }
        } else {
            print("\(selectedSound).mp3 file not found in the bundle.")
        }
    }
    
    func startMetronome() {
        isPlaying = true
        updateTimer()
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
    }
    
    private func updateTimer() {
        timer?.invalidate()
        if isPlaying {
            let interval = 60.0 / bpm
            // Capture self weakly in the closure to avoid retain cycles
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.playClick()  // Use self? to ensure it's not deallocated
            }
        }
    }
    
    private func playClick() {
        guard let player = audioPlayer else {
            print("Audio player is not initialized.")
            return
        }
        player.stop()
        player.currentTime = 0
        player.play()
    }
}

// ContentView - Main Screen with Metronome Control
struct ContentView: View {
    @StateObject private var metronome = MetronomeManager() // Create metronome instance
    @State private var isSettingsPresented = false

    let timeSignatures = ["4/4", "3/4", "6/8"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your Pocket Metronome for Perfect Timing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                // BPM Selector
                VStack {
                    Text("BPM: \(Int(metronome.bpm))")
                        .font(.headline)
                    Slider(value: $metronome.bpm, in: 40...240, step: 1)
                        .padding(.horizontal)
                }
                
                // Time Signature Selector
                Picker("Time Signature", selection: $metronome.timeSignature) {
                    ForEach(timeSignatures, id: \.self) { signature in
                        Text(signature)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Start Metronome Button
                NavigationLink(destination: MetronomeControlView(metronome: metronome)) {
                    Text("Start Metronome")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Settings Button
                Button(action: {
                    isSettingsPresented.toggle()
                }) {
                    Text("Settings")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $isSettingsPresented) {
                    SettingsView(metronome: metronome) // Pass metronome instance
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

// Metronome Control View
struct MetronomeControlView: View {
    @ObservedObject var metronome: MetronomeManager
    
    var body: some View {
        VStack {
            Text("Metronome Control")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // BPM Display
            Text("BPM: \(Int(metronome.bpm))")
                .font(.headline)
            
            // Start/Stop Button
            Button(action: {
                if metronome.isPlaying {
                    metronome.stopMetronome()
                } else {
                    metronome.startMetronome()
                }
            }) {
                Text(metronome.isPlaying ? "Stop Metronome" : "Start Metronome")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(metronome.isPlaying ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// Settings View (Page 3)
struct SettingsView: View {
    @ObservedObject var metronome: MetronomeManager // Access metronome instance
    @State private var isVibrationEnabled = false
    @State private var isDarkModeEnabled = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound Settings")) {
                    Picker("Sound", selection: $metronome.selectedSound) {
                        Text("Click").tag("Click")
                        Text("Woodblock").tag("Woodblock")
                        Text("Drum").tag("Drum")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: metronome.selectedSound) { _ in
                        metronome.loadClickSound() // Load new sound based on selection
                    }
                    
                    Toggle("Vibration", isOn: $isVibrationEnabled)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkModeEnabled)
                        .onChange(of: isDarkModeEnabled) { value in
                            if value {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    windowScene.windows.first?.overrideUserInterfaceStyle = .dark
                                }
                            } else {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    windowScene.windows.first?.overrideUserInterfaceStyle = .light
                                }
                            }
                        }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
