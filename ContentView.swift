import SwiftUI

struct ContentView: View {
    @StateObject private var metronome = MetronomeManager()
    @State private var isSettingsPresented = false
    @State private var isSliderHidden = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your Pocket Metronome")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )

                VStack {
                    Text("\(Int(metronome.bpm)) BPM")
                        .font(.headline)

                    if !isSliderHidden {
                        Slider(value: $metronome.bpm, in: 40...240, step: 1)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    withAnimation {
                        if metronome.isPlaying {
                            metronome.stopMetronome()
                            isSliderHidden = false
                        } else {
                            metronome.startMetronome()
                            isSliderHidden = true
                        }
                    }
                }) {
                    Text(metronome.isPlaying ? "Stop Metronome" : "Start Metronome")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(metronome.isPlaying ? Color.red : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

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
                    SettingsView(metronome: metronome)
                }

                // Sound Picker at the bottom
                VStack {
                    Text("Select Sound")
                        .font(.headline)
                        .padding(.top)

                    Picker("Sound", selection: $metronome.selectedSound) {
                        Text("Belt").tag("belt-slap-fat_A#.wav")
                        Text("Hollow Percussion").tag("hollow-percussion-hit-object.wav")
                        Text("Keyboard").tag("keyboard-click.wav")
                        Text("Tick").tag("metronome-sfx.wav")
                        Text("Percussion Hit").tag("percussion-hit-object-hit-2.wav")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: metronome.selectedSound) { _ in
                        metronome.setupAudio() // Setup audio with the new sound
                    }
                    .padding(.horizontal)

                    // 🎯 **Pulsating SHMPendulum Below Sound Picker**
                    SHMPendulum(isPlaying: metronome.isPlaying, bpm: metronome.bpm)
                        .frame(height: 100) // Adjust the height of the frame
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("TempoNome")
        }
    }
}

struct SHMPendulum: View {
    var isPlaying: Bool
    var bpm: Double
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.purple.opacity(0.7))
            .scaleEffect(scale)
            .frame(width: 80, height: 80) // Set a fixed width and height for the circle
            .onAppear {
                if isPlaying {
                    startPulsating()
                }
            }
            .onChange(of: isPlaying) { newValue in
                if newValue {
                    startPulsating()
                } else {
                    stopPulsating()
                }
            }
            .onChange(of: bpm) { _ in
                if isPlaying {
                    stopPulsating()
                    startPulsating()
                }
            }
    }

    private func startPulsating() {
        withAnimation(Animation.easeInOut(duration: 60.0 / bpm).repeatForever(autoreverses: true)) {
            scale = 1.2 // Scale up
        }
    }

    private func stopPulsating() {
        withAnimation {
            scale = 1.0 // Reset scale
        }
    }
}
