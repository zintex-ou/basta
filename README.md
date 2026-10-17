# Basta — Wenig Bildschirmzeit, but for ES/IT

Native SwiftUI, iOS 17+. FamilyControls / DeviceActivity / ManagedSettings. No backend.

## Layout
- `Basta/` — app (onboarding → hard paywall → home)
- `Shared/` — models + services compiled into app, Monitor and Shield
- `BastaMonitor/` — DeviceActivityMonitor: flips modes at schedule boundaries
- `BastaShield/` — ShieldConfiguration: the blocked-app screen
- `BastaReport/` — DeviceActivityReport: today's screen time (sandboxed)
- `project.yml` — XcodeGen; `xcodegen generate` → `Basta.xcodeproj`
- `codemagic.yaml` — CI → TestFlight
- `tools/gen_strings.py` — regenerates the three `Localizable.xcstrings` (en/es/it)

## Before first CI build
1. App Store Connect → New app, bundle `com.zintex.basta`, SKU `basta`.
2. Same app → Subscriptions group "Basta Pro", product IDs exactly as in `PurchaseService.ProductID`.
3. Developer portal → Identifiers: `com.zintex.basta`, `.monitor`, `.shield`, `.report`
   each with **Family Controls** + **App Groups** (`group.com.zintex.basta`).
4. Codemagic: ASC integration name `zintex-asc`; set `APP_STORE_APPLE_ID` in `codemagic.yaml`.
5. Replace `Basta/Assets.xcassets/AppIcon.appiconset/icon.png` (placeholder).

## Local run
`xcodegen generate && open Basta.xcodeproj` — scheme Basta, StoreKit config `Basta.storekit`
(Edit Scheme → Run → Options → StoreKit Configuration). Family Controls needs a real device.
