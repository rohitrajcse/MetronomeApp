import SwiftUI

struct SettingsView: View {
    @ObservedObject var metronome: MetronomeManager
    @ObservedObject var settingsManager = SettingsManager.shared

    var body: some View {
        NavigationView {
            Form {
                // Sound Settings
                Section(header: Text("Sound Settings").font(.headline).padding(.bottom, 5)) {
                    Picker("Sound", selection: $metronome.selectedSound) {
                        Text("Belt").tag("belt-slap-fat_A#.wav")
                        Text("Hollow Percussion").tag("hollow-percussion-hit-object.wav")
                        Text("Keyboard").tag("keyboard-click.wav")
                        Text("Tick").tag("metronome-sfx.wav")
                        Text("Percussion Hit").tag("percussion-hit-object-hit-2.wav")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.title3)
                    .padding(.horizontal)
                    .onChange(of: metronome.selectedSound) { _ in
                        metronome.setupAudio()
                    }
                    
                    Slider(value: $metronome.volume, in: 0...1, step: 0.1)
                        .onChange(of: metronome.volume) { _ in
                            metronome.setupAudio()
                        }
                    Text("Volume: \(Int(metronome.volume * 100))%")
                        .font(.body)
                }
                
                // Haptics Settings (Vibration Control)
                Section(header: Text("Haptics Settings").font(.headline).padding(.bottom, 5)) {
                    Toggle("Vibration", isOn: $settingsManager.isVibrationEnabled)
                        .font(.title3) // Make font size consistent with Dark Mode toggle
                }
                
                // Appearance Settings
                Section(header: Text("Appearance").font(.headline).padding(.bottom, 5)) {
                    Toggle("Dark Mode", isOn: $settingsManager.isDarkModeEnabled)
                        .font(.title3) // Ensure same font styling for consistency
                }
            }
            .navigationTitle("Settings")
        }
    }
}
