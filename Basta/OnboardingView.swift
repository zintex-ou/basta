import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @EnvironmentObject var model: AppModel
    @State private var step = 0
    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(step + 1), total: 4)
                .tint(Theme.accent)
                .padding(.horizontal, Theme.pad)
                .padding(.top, 8)

            TabView(selection: $step) {
                hook.tag(0)
                how.tag(1)
                permission.tag(2)
                firstMode.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)
        }
        .screen()
        .familyActivityPicker(isPresented: $showPicker, selection: $selection)
    }

    // 1 — hook
    private var hook: some View {
        page(
            icon: "hand.raised.fill",
            title: "onb.hook.title",
            body: "onb.hook.body",
            cta: "onb.next"
        ) { step = 1 }
    }

    // 2 — how it works
    private var how: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Text("onb.how.title").font(.largeTitle.bold())
            featureRow("clock.fill", "onb.how.schedule")
            featureRow("mappin.circle.fill", "onb.how.place")
            featureRow("lock.fill", "onb.how.strict")
            featureRow("hand.tap.fill", "onb.how.quick")
            Spacer()
            PrimaryButton(title: "onb.next") { step = 2 }
        }
        .padding(Theme.pad)
    }

    // 3 — Screen Time permission
    private var permission: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Image(systemName: "hourglass")
                .font(.system(size: 56)).foregroundStyle(Theme.accent)
            Text("onb.perm.title").font(.largeTitle.bold())
            Text("onb.perm.body").foregroundStyle(Theme.textDim)
            Text("onb.perm.privacy").font(.footnote).foregroundStyle(Theme.textDim)
            Spacer()
            PrimaryButton(title: model.screenTimeAuthorized ? "onb.next" : "onb.perm.cta") {
                if model.screenTimeAuthorized { step = 3 } else {
                    Task { await model.requestScreenTime(); if model.screenTimeAuthorized { step = 3 } }
                }
            }
        }
        .padding(Theme.pad)
    }

    // 4 — pick distracting apps → creates first mode
    private var firstMode: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text("onb.apps.title").font(.largeTitle.bold())
            Text("onb.apps.body").foregroundStyle(Theme.textDim)
            Button { showPicker = true } label: {
                Card(highlighted: !selection.applicationTokens.isEmpty) {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                        Text(selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty
                             ? "onb.apps.pick" : "onb.apps.picked \(selection.applicationTokens.count + selection.categoryTokens.count)")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(Theme.textDim)
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer()
            PrimaryButton(title: "onb.finish",
                          disabled: selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty) {
                var m = FocusMode(name: String(localized: "mode.default.name"), icon: "bolt.fill")
                m.selection = selection
                model.add(m)
                model.onboardingDone = true
            }
        }
        .padding(Theme.pad)
    }

    private func page(icon: String, title: LocalizedStringKey, body: LocalizedStringKey,
                      cta: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Image(systemName: icon).font(.system(size: 56)).foregroundStyle(Theme.accent)
            Text(title).font(.largeTitle.bold())
            Text(body).foregroundStyle(Theme.textDim)
            Spacer()
            PrimaryButton(title: cta, action: action)
        }
        .padding(Theme.pad)
    }

    private func featureRow(_ icon: String, _ text: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).frame(width: 28).foregroundStyle(Theme.accent)
            Text(text)
        }
    }
}
