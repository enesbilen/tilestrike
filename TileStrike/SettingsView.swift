import SwiftUI

struct SettingsView: View {
    let onDismiss: () -> Void

    @AppStorage(AppSettings.soundEnabledKey) private var soundEnabled = true
    @AppStorage(AppSettings.hapticsEnabledKey) private var hapticsEnabled = true
    @AppStorage(AppSettings.themeKey) private var selectedTheme = GameTheme.ember.rawValue
    @AppStorage(AppSettings.gameModeKey) private var selectedGameMode = GameMode.classic.rawValue
    @AppStorage(AppSettings.blockStyleKey) private var selectedBlockStyle = BlockStyle.classic.rawValue

    private var theme: GameTheme {
        GameTheme.current(rawValue: selectedTheme)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 14) {
                        SettingsToggleRow(
                            title: "Ses",
                            subtitle: soundEnabled ? "Oyun efektleri açık" : "Oyun efektleri kapalı",
                            systemImage: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                            accent: theme.accent,
                            isOn: $soundEnabled
                        )

                        SettingsToggleRow(
                            title: "Titreşim",
                            subtitle: hapticsEnabled ? "Dokunsal geri bildirim açık" : "Dokunsal geri bildirim kapalı",
                            systemImage: hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash",
                            accent: theme.accent,
                            isOn: $hapticsEnabled
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Oyun Modu", systemImage: "gamecontroller.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            ForEach(GameMode.allCases) { mode in
                                ModeOptionRow(
                                    mode: mode,
                                    accent: theme.accent,
                                    isSelected: mode.rawValue == selectedGameMode,
                                    onSelect: { selectedGameMode = mode.rawValue }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Görünüm", systemImage: "paintpalette.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            ForEach(GameTheme.allCases) { themeOption in
                                ThemeOptionRow(
                                    theme: themeOption,
                                    isSelected: themeOption.rawValue == selectedTheme,
                                    onSelect: { selectedTheme = themeOption.rawValue }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Blok Stili", systemImage: "square.stack.3d.up.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            ForEach(BlockStyle.allCases) { style in
                                BlockStyleOptionRow(
                                    style: style,
                                    accent: theme.accent,
                                    isSelected: style.rawValue == selectedBlockStyle,
                                    onSelect: { selectedBlockStyle = style.rawValue }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Label("TileStrike", systemImage: "square.grid.3x3.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            Text("Sürüm \(appVersion)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.55))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 26)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Ayarlar")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white.opacity(0.70))
                    .background(.white.opacity(0.10), in: Circle())
            }
            .accessibilityLabel("Kapat")
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (.some(version), .some(build)):
            return "\(version) (\(build))"
        case let (.some(version), .none):
            return version
        default:
            return "1.0"
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var accent = GameTheme.ember.accent
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.09), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))
            }

            Spacer(minLength: 12)

            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .tint(accent)
        }
        .padding(18)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct ThemeOptionRow: View {
    let theme: GameTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(theme.subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.46))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? theme.accent : .white.opacity(0.26))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(isSelected ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.accent.opacity(0.38) : .white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.title) temasını seç")
    }
}

private struct ModeOptionRow: View {
    let mode: GameMode
    let accent: Color
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(mode.subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.46))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? accent : .white.opacity(0.26))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(isSelected ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accent.opacity(0.38) : .white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.title) modunu seç")
    }
}

private struct BlockStyleOptionRow: View {
    let style: BlockStyle
    let accent: Color
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    BlockSurfaceView(
                        color: accent,
                        style: style,
                        cornerRadius: 8,
                        side: 34
                    )
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 3) {
                    Text(style.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(style.subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.46))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? accent : .white.opacity(0.26))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(isSelected ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accent.opacity(0.38) : .white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(style.title) blok stilini seç")
    }
}
