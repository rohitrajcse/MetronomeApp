import SwiftUI

struct SettingsView: View {
    @ObservedObject var metronome: MetronomeManager
    @State private var isVibrationEnabled = false
    @State private var isDarkModeEnabled = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound Settings")
                            .font(.headline)
                            .padding(.bottom, 5)) {
                    
                    // Picker with improved UI
                    Picker("Sound", selection: $metronome.selectedSound) {
                        Text("Belt").tag("belt-slap-fat_A#.wav")
                        Text("Hollow Percussion").tag("hollow-percussion-hit-object.wav")
                        Text("Keyboard").tag("keyboard-click.wav")
                        Text("Tick").tag("metronome-sfx.wav")
                        Text("Percussion Hit").tag("percussion-hit-object-hit-2.wav")
                    }
                    .pickerStyle(MenuPickerStyle()) // Changed to a Menu style for better UI
                    .font(.title3) // Increased font size for readability
                    .padding(.horizontal)
                    .onChange(of: metronome.selectedSound) { _ in
                        metronome.setupAudio() // Reload new sound based on selection
                    }
                    
                    Toggle("Vibration", isOn: $isVibrationEnabled)
                        .padding(.top)
                        .font(.title3) // Increased font size for toggle
                }
                
                Section(header: Text("Appearance")
                            .font(.headline)
                            .padding(.bottom, 5)) {
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
                        .font(.title3) // Increased font size for toggle
                }
            }
            .navigationTitle("Settings")
        }
    }
}
