import SwiftUI

struct ContentView: View {
    @StateObject private var metronome = MetronomeManager()
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

                VStack {
                    Text("BPM: \(Int(metronome.bpm))")
                        .font(.headline)
                    Slider(value: $metronome.bpm, in: 40...240, step: 1)
                        .padding(.horizontal)
                }
                
                Picker("Time Signature", selection: $metronome.timeSignature) {
                    ForEach(timeSignatures, id: \.self) { signature in
                        Text(signature)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

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
            .navigationTitle("Home")
        }
    }
}
