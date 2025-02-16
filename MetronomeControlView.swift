import SwiftUI

struct MetronomeControlView: View {
    @ObservedObject var metronome: MetronomeManager
    
    var body: some View {
        VStack {
            Text("Metronome Control")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("BPM: \(Int(metronome.bpm))")
                .font(.headline)
            
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
