//
//  DesignSystem.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import SwiftUI

// MARK: - Color System
extension Color {
    static let primaryDark = Color(hex: "#1a1a2e")
    static let secondaryDark = Color(hex: "#16213e")
    static let purpleAccent = Color(hex: "#764ba2")
    static let successGreen = Color(hex: "#4caf50")
    static let errorRed = Color(hex: "#ff6b6b")
    static let streakGold = Color(hex: "#ffd700")
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct AppTypography {
    static let wordDisplay = Font.system(size: 36, weight: .bold, design: .default)
    static let wordDisplayLarge = Font.system(size: 42, weight: .bold, design: .default)
    static let score = Font.system(size: 48, weight: .bold, design: .default)
    static let title = Font.system(size: 32, weight: .bold, design: .default)
    static let subtitle = Font.system(size: 16, weight: .medium, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let button = Font.system(size: 20, weight: .bold, design: .default)
    
    // Helper function to get appropriate font size based on word length
    static func wordFont(for word: String) -> Font {
        if word.count <= 8 {
            return wordDisplayLarge
        } else if word.count <= 12 {
            return wordDisplay
        } else {
            return Font.system(size: 28, weight: .bold, design: .default)
        }
    }
}

// MARK: - Layout Constants
struct AppLayout {
    static let cardWidth: CGFloat = 320
    static let cardHeight: CGFloat = 160
    static let cornerRadius: CGFloat = 15
    static let buttonHeight: CGFloat = 60
    static let minTouchTarget: CGFloat = 44
    static let padding: CGFloat = 20
}

// MARK: - Animation Constants
struct AppAnimations {
    static let cardSwipe = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let feedback = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let standard = Animation.easeInOut(duration: 0.3)
}

// MARK: - Common Views
struct GameCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
    }
}

struct PrimaryButton: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(AppTypography.button)
            .foregroundColor(.white)
            .frame(height: AppLayout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.buttonHeight / 2)
                    .fill(color)
            )
    }
}

extension View {
    func gameCardStyle() -> some View {
        modifier(GameCard())
    }
    
    func primaryButtonStyle(color: Color = .purpleAccent) -> some View {
        modifier(PrimaryButton(color: color))
    }
}
