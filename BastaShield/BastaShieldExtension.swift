import ManagedSettings
import ManagedSettingsUI
import UIKit

/// The screen the user sees when opening a blocked app.
/// Localized via the extension's own Localizable.xcstrings.
final class BastaShieldExtension: ShieldConfigurationDataSource {

    private var config: ShieldConfiguration {
        let orange = UIColor(red: 1.00, green: 0.42, blue: 0.24, alpha: 1)
        let bg = UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1)
        let strict = ShieldService.isLockedByStrict()
        let subtitle = strict
            ? String(localized: "shield.subtitle.strict")
            : String(localized: "shield.subtitle")
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: bg,
            icon: UIImage(systemName: "hand.raised.fill")?.withTintColor(orange, renderingMode: .alwaysOriginal),
            title: .init(text: String(localized: "shield.title"), color: .white),
            subtitle: .init(text: subtitle, color: UIColor.white.withAlphaComponent(0.7)),
            primaryButtonLabel: .init(text: String(localized: "shield.ok"), color: .black),
            primaryButtonBackgroundColor: orange,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration { config }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { config }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { config }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { config }
}
