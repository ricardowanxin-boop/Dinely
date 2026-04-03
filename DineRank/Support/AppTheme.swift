import SwiftUI
import UIKit

enum AppTheme {
    static let backgroundTop = dynamicColor(light: "#FFF9F4", dark: "#151313")
    static let backgroundBottom = dynamicColor(light: "#F8F9FA", dark: "#0D1014")
    static let surface = dynamicColor(light: "#FFFFFF", dark: "#171B22")
    static let surfaceWarm = dynamicColor(light: "#FFF4EB", dark: "#241D1A")
    static let surfaceTint = dynamicColor(light: "#FFF1E7", dark: "#1B2530")
    static let divider = dynamicColor(light: "#E5E7EB", dark: "#313946")
    static let textPrimary = dynamicColor(light: "#1A1A1A", dark: "#F5F7FA")
    static let textSecondary = dynamicColor(light: "#6B7280", dark: "#C2C8D3")
    static let textTertiary = dynamicColor(light: "#9CA3AF", dark: "#8D98AA")
    static let copper = dynamicColor(light: "#FF7A50", dark: "#FF936F")
    static let copperDark = dynamicColor(light: "#E85D2A", dark: "#FF7D4F")
    static let copperSoft = dynamicColor(light: "#FFB088", dark: "#D68867")
    static let aqua = dynamicColor(light: "#7F9BB3", dark: "#A5BDD1")
    static let mint = dynamicColor(light: "#10B981", dark: "#3DD4A5")
    static let rose = dynamicColor(light: "#EF4444", dark: "#FF7A7A")
    static let warning = dynamicColor(light: "#F59E0B", dark: "#FFBF47")
    static let shadow = dynamicColor(
        light: UIColor.black.withAlphaComponent(0.08),
        dark: UIColor.black.withAlphaComponent(0.32)
    )

    static func statusTint(for status: SnapshotStatus) -> Color {
        switch status {
        case .ready:
            mint
        case .syncing:
            warning
        case .fallback:
            rose
        }
    }

    static func rankTint(for rank: AttendanceRank) -> Color {
        switch rank {
        case .newcomer:
            Color(hex: "#94A3B8")
        case .bronze:
            Color(hex: "#D98836")
        case .silver:
            Color(hex: "#BFC6D1")
        case .gold:
            Color(hex: "#F6C343")
        case .platinum:
            Color(hex: "#8ED1C7")
        case .diamond:
            Color(hex: "#87C7F3")
        case .legend:
            Color(hex: "#9B5DE5")
        }
    }
}

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [AppTheme.copperSoft.opacity(0.22), .clear],
                center: .topLeading,
                startRadius: 12,
                endRadius: 220
            )
            .offset(x: -40, y: -120)

            RadialGradient(
                colors: [Color(hex: "#FFD55C").opacity(0.18), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 180
            )
            .offset(x: 40, y: 120)
        }
        .ignoresSafeArea()
    }
}

private struct TemplateSurfaceModifier: ViewModifier {
    var highlighted: Bool

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(highlighted ? AppTheme.surfaceWarm : AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(highlighted ? AppTheme.copperSoft.opacity(0.8) : AppTheme.divider, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: highlighted ? 18 : 12, x: 0, y: highlighted ? 10 : 6)
    }
}

extension View {
    func templateSurface(highlighted: Bool = false) -> some View {
        modifier(TemplateSurfaceModifier(highlighted: highlighted))
    }
}

private extension AppTheme {
    static func dynamicColor(light: String, dark: String) -> Color {
        dynamicColor(light: UIColor(hex: light), dark: UIColor(hex: dark))
    }

    static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
