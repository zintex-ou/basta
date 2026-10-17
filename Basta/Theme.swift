import SwiftUI

/// Visual system. Dark, warm, one bold accent — reads as "stop" without being alarming.
enum Theme {
    static let bg = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let surfaceHi = Color(red: 0.17, green: 0.17, blue: 0.20)
    static let accent = Color(red: 1.00, green: 0.42, blue: 0.24)     // coral-orange
    static let accentSoft = accent.opacity(0.18)
    static let text = Color.white
    static let textDim = Color.white.opacity(0.62)
    static let success = Color(red: 0.36, green: 0.85, blue: 0.55)

    static let radius: CGFloat = 20
    static let pad: CGFloat = 20
}

struct Card<Content: View>: View {
    var highlighted = false
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(Theme.pad)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(highlighted ? Theme.accentSoft : Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius)
                    .stroke(highlighted ? Theme.accent.opacity(0.5) : .clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
    }
}

struct PrimaryButton: View {
    let title: LocalizedStringKey
    var disabled = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(disabled ? Theme.surfaceHi : Theme.accent)
                .foregroundStyle(disabled ? Theme.textDim : .black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(disabled)
    }
}

struct SecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.textDim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}

extension View {
    func screen() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg.ignoresSafeArea())
            .foregroundStyle(Theme.text)
    }
}
