import SwiftUI

struct ContentView: View {
    @StateObject private var metronome = MetronomeManager()
    @State private var isSettingsPresented = false
    @State private var isRecording = false
    @State private var recordedAudio: URL?

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
                    Slider(value: $metronome.bpm, in: 40...240, step: 1)
                        .padding(.horizontal)
                }

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

                Spacer()
            }
            .padding()
            .navigationTitle("TempoNome")
        }
    }
}

