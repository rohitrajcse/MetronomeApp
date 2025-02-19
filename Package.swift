// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "MetronomeApp",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "MetronomeApp",
            targets: ["AppModule"],
            bundleIdentifier: "com.rohitraj2.MetronomeApp",
            teamIdentifier: "82F3R6M6RD",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .note),
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .copy("Metronome_Sounds/belt-slap-fat_A#.wav"),
                .copy("Metronome_Sounds/hollow-percussion-hit-object.wav"),
                .copy("Metronome_Sounds/keyboard-click.wav"),
                .copy("Metronome_Sounds/metronome-sfx.wav"),
                .copy("Metronome_Sounds/percussion-hit-object-hit-2.wav")
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)