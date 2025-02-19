import SwiftUI

struct ContentView: View {
    @StateObject private var metronome = MetronomeManager()
    @State private var isSettingsPresented = false
    @State private var isSliderHidden = false

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

                SHMPendulum(isPlaying: metronome.isPlaying, bpm: metronome.bpm)
                    .padding(.top, 20)

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
    @State private var offsetX: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let ballRadius: CGFloat = 20 // Radius of the ball
            let maxX = (geo.size.width / 2) - ballRadius // Maximum displacement from center

            ZStack {
                // Line for the pendulum to travel on
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 2)
                    .padding(.horizontal)

                Circle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: ballRadius * 2, height: ballRadius * 2)
                    .offset(x: offsetX)
                    .onAppear {
                        if isPlaying {
                            startAnimation(maxX: maxX)
                        }
                    }
                    .onChange(of: isPlaying) { newValue in
                        if newValue {
                            startAnimation(maxX: maxX)
                        } else {
                            stopAnimation()
                        }
                    }
                    .onChange(of: bpm) { _ in
                        if isPlaying {
                            startAnimation(maxX: maxX)
                        }
                    }
            }
        }
        .frame(height: 80) // Keep the animation area reasonable
    }

    private func startAnimation(maxX: CGFloat) {
        // Move from the left extreme to the right extreme and back
        withAnimation(Animation.easeInOut(duration: 60.0 / bpm).repeatForever(autoreverses: true)) {
            offsetX = maxX // This will make it swing from left to right
        }
    }

    private func stopAnimation() {
        offsetX = 0 // Reset to center
    }
}



