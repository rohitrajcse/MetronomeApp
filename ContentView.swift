import SwiftUI

struct ContentView: View {
    @StateObject private var metronome = MetronomeManager()
    @State private var isSettingsPresented = false
    @State private var isSliderHidden = false // State variable to track slider visibility

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your Pocket Metronome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                VStack {
                    Text("BPM: \(Int(metronome.bpm))")
                        .font(.headline)

                    // Show slider only if it's not hidden
                    if !isSliderHidden {
                        Slider(value: $metronome.bpm, in: 40...240, step: 1)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    withAnimation {
                        if metronome.isPlaying {
                            metronome.stopMetronome()
                            isSliderHidden = false // Show slider when stopped
                        } else {
                            metronome.startMetronome()
                            isSliderHidden = true // Hide slider when playing
                        }
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

                PulsatingCircle(isPlaying: metronome.isPlaying, bpm: metronome.bpm)
                    .padding(.top, 20)

                Spacer()
            }
            .padding()
            .navigationTitle("TempoNome")
        }
    }
}

struct PulsatingCircle: View {
    var isPlaying: Bool
    var bpm: Double
    @State private var scale: CGFloat = 1.0
    @State private var animationID = UUID()

    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 100, height: 100)
            .scaleEffect(scale)
            .id(animationID)
            .onAppear {
                if isPlaying {
                    startAnimation()
                }
            }
            .onChange(of: isPlaying) { newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
            .onChange(of: bpm) { newValue in
                if isPlaying {
                    restartAnimation(newBPM: newValue)
                }
            }
    }

    private func startAnimation() {
        let duration = 60.0 / bpm
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.0
        }
    }

    private func restartAnimation(newBPM: Double) {
        let duration = 60.0 / newBPM
        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
        animationID = UUID() // Change ID to force animation reset
    }
}
