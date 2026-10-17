import SwiftUI
import FamilyControls
import MapKit

struct ModeEditorView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var draft: FocusMode
    @State private var hasSchedule: Bool
    @State private var hasPlace: Bool
    @State private var start: Date
    @State private var end: Date
    @State private var showPicker = false
    @State private var showPlacePicker = false
    private let isNew: Bool

    private static let icons = ["bolt.fill", "moon.fill", "book.fill", "briefcase.fill",
                                "figure.run", "fork.knife", "heart.fill", "leaf.fill"]

    init(mode: FocusMode?) {
        let m = mode ?? FocusMode(name: "")
        _draft = State(initialValue: m)
        isNew = mode == nil
        _hasSchedule = State(initialValue: m.schedule != nil)
        _hasPlace = State(initialValue: m.place != nil)
        let s = m.schedule ?? .init()
        _start = State(initialValue: Self.date(h: s.startHour, m: s.startMinute))
        _end = State(initialValue: Self.date(h: s.endHour, m: s.endMinute))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("editor.name", text: $draft.name)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Self.icons, id: \.self) { ic in
                                Image(systemName: ic)
                                    .frame(width: 40, height: 40)
                                    .background(draft.icon == ic ? Theme.accent : Theme.surfaceHi)
                                    .foregroundStyle(draft.icon == ic ? .black : Theme.text)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture { draft.icon = ic }
                            }
                        }
                    }
                }

                Section("editor.apps") {
                    Button { showPicker = true } label: {
                        HStack {
                            Text(draft.blocksAnything
                                 ? "editor.apps.count \(draft.selection.applicationTokens.count + draft.selection.categoryTokens.count + draft.selection.webDomainTokens.count)"
                                 : "editor.apps.pick")
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Theme.textDim)
                        }
                    }
                }

                Section("editor.schedule") {
                    Toggle("editor.schedule.on", isOn: $hasSchedule)
                    if hasSchedule {
                        DatePicker("editor.from", selection: $start, displayedComponents: .hourAndMinute)
                        DatePicker("editor.to", selection: $end, displayedComponents: .hourAndMinute)
                        WeekdayPicker(selected: Binding(
                            get: { draft.schedule?.weekdays ?? [2,3,4,5,6] },
                            set: { v in var s = draft.schedule ?? .init(); s.weekdays = v; draft.schedule = s }))
                    }
                }

                Section("editor.place") {
                    Toggle("editor.place.on", isOn: $hasPlace)
                    if hasPlace {
                        Button { showPlacePicker = true } label: {
                            HStack {
                                Text(draft.place?.name ?? String(localized: "editor.place.pick"))
                                Spacer()
                                Image(systemName: "mappin.and.ellipse").foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }

                Section {
                    Toggle("editor.strict", isOn: $draft.strict)
                } footer: { Text("editor.strict.footer") }

                if !isNew {
                    Section {
                        Button(role: .destructive) { model.delete(draft); dismiss() } label: {
                            Text("editor.delete").frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle(isNew ? "editor.new" : "editor.edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("editor.cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("editor.save") { save() }
                        .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty || !draft.blocksAnything)
                }
            }
            .familyActivityPicker(isPresented: $showPicker, selection: $draft.selection)
            .sheet(isPresented: $showPlacePicker) {
                PlacePickerView(place: $draft.place)
            }
            .onChange(of: hasPlace) { _, on in
                if on { LocationService.shared.requestAlways() } else { draft.place = nil }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        if hasSchedule {
            var s = draft.schedule ?? .init()
            let c = Calendar.current
            s.startHour = c.component(.hour, from: start); s.startMinute = c.component(.minute, from: start)
            s.endHour = c.component(.hour, from: end); s.endMinute = c.component(.minute, from: end)
            draft.schedule = s
        } else {
            draft.schedule = nil
        }
        if !hasPlace { draft.place = nil }
        if isNew { model.add(draft) } else { model.update(draft) }
        dismiss()
    }

    private static func date(h: Int, m: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: h, minute: m)) ?? Date()
    }
}

struct WeekdayPicker: View {
    @Binding var selected: Set<Int>
    private let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols   // localized, Sunday first

    var body: some View {
        HStack(spacing: 6) {
            ForEach(order, id: \.self) { wd in
                Text(symbols[wd - 1])
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(selected.contains(wd) ? Theme.accent : Theme.surfaceHi)
                    .foregroundStyle(selected.contains(wd) ? .black : Theme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        if selected.contains(wd) { selected.remove(wd) } else { selected.insert(wd) }
                    }
            }
        }
    }

    /// Start the row on the locale's first weekday (Monday in ES/IT).
    private var order: [Int] {
        let first = Calendar.current.firstWeekday
        return (0..<7).map { ((first - 1 + $0) % 7) + 1 }
    }
}

/// Drop a pin on a map; the visible centre becomes the geofence.
struct PlacePickerView: View {
    @Binding var place: FocusMode.Place?
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var region = MapCameraPosition.userLocation(fallback: .automatic)
    @State private var center: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("place.name", text: $name)
                    .padding().background(Theme.surface)
                ZStack {
                    Map(position: $region) { UserAnnotation() }
                        .onMapCameraChange(frequency: .onEnd) { ctx in center = ctx.region.center }
                    Image(systemName: "mappin").font(.largeTitle).foregroundStyle(Theme.accent)
                        .offset(y: -14)
                }
                Text("place.hint").font(.footnote).foregroundStyle(Theme.textDim).padding()
            }
            .background(Theme.bg)
            .navigationTitle("place.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("editor.cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("editor.save") {
                        if let c = center {
                            place = .init(name: name.isEmpty ? String(localized: "place.default") : name,
                                          latitude: c.latitude, longitude: c.longitude)
                        }
                        dismiss()
                    }
                    .disabled(center == nil)
                }
            }
            .onAppear { name = place?.name ?? "" }
        }
        .preferredColorScheme(.dark)
    }
}
