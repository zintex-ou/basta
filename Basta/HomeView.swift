import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model: AppModel
    @State private var editing: FocusMode?
    @State private var creating = false
    @State private var quickFor: FocusMode?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statusHeader
                    ForEach(model.modes) { mode in
                        ModeRow(mode: mode,
                                active: model.isActive(mode),
                                locked: model.strictLockedUntil != nil && model.isActive(mode),
                                onToggle: { model.toggle(mode) },
                                onQuick: { quickFor = mode },
                                onEdit: { editing = mode })
                    }
                    Button { creating = true } label: {
                        Card {
                            HStack { Image(systemName: "plus.circle.fill"); Text("home.newMode"); Spacer() }
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(Theme.pad)
            }
            .screen()
            .navigationTitle("Basta")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                }
            }
            .sheet(item: $editing) { m in ModeEditorView(mode: m) }
            .sheet(isPresented: $creating) { ModeEditorView(mode: nil) }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .confirmationDialog("home.quick.title", isPresented: Binding(get: { quickFor != nil }, set: { if !$0 { quickFor = nil } }),
                                titleVisibility: .visible) {
                ForEach([15, 30, 60, 120], id: \.self) { min in
                    Button {
                        if let m = quickFor { model.quickFocus(m, minutes: min) }
                    } label: {
                        Text("home.quick.minutes \(min)")
                    }
                }
            }
        }
    }

    private var statusHeader: some View {
        let activeCount = model.modes.filter { model.isActive($0) }.count
        return Card(highlighted: activeCount > 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(activeCount > 0 ? "home.status.on" : "home.status.off")
                    .font(.title2.bold())
                if let until = model.strictLockedUntil {
                    Label {
                        Text("home.status.strictUntil \(until, style: .time)")
                    } icon: { Image(systemName: "lock.fill") }
                    .font(.subheadline).foregroundStyle(Theme.textDim)
                } else {
                    Text(activeCount > 0 ? "home.status.onHint" : "home.status.offHint")
                        .font(.subheadline).foregroundStyle(Theme.textDim)
                }
            }
        }
    }
}

struct ModeRow: View {
    let mode: FocusMode
    let active: Bool
    let locked: Bool
    let onToggle: () -> Void
    let onQuick: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Card(highlighted: active) {
            HStack(spacing: 14) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(active ? Theme.accent : Theme.surfaceHi)
                    .foregroundStyle(active ? .black : Theme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.name).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(Theme.textDim)
                }
                Spacer()
                if locked {
                    Image(systemName: "lock.fill").foregroundStyle(Theme.accent)
                } else {
                    Toggle("", isOn: Binding(get: { active }, set: { _ in onToggle() }))
                        .labelsHidden().tint(Theme.accent)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onEdit)
            .contextMenu {
                Button { onQuick() } label: { Label("home.quick.menu", systemImage: "timer") }
                Button { onEdit() } label: { Label("home.edit", systemImage: "pencil") }
            }
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        if let s = mode.schedule {
            parts.append(String(format: "%02d:%02d–%02d:%02d", s.startHour, s.startMinute, s.endHour, s.endMinute))
        }
        if let p = mode.place { parts.append(p.name) }
        if mode.strict { parts.append(String(localized: "mode.strict.short")) }
        return parts.isEmpty ? String(localized: "mode.manual") : parts.joined(separator: " · ")
    }
}
