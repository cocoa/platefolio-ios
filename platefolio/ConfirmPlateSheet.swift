import SwiftUI
import UIKit

struct ConfirmPlateSheet: View {
    let image: UIImage?
    let suggestedPlate: String
    @Binding var tagsText: String
    var onSave: (_ confirmedPlateDisplay: String, _ tags: [String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var confirmedPlate: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Confirm plate")
                        .font(.headline)

                    TextField("e.g. FS22 PET", text: $confirmedPlate)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    TextField("Tags (comma separated)", text: $tagsText)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    Text("Tip: “porsche, black, spotted”")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let display = PlateSanitizer.sanitizeForDisplay(confirmedPlate)

                        let tags = tagsText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }

                        guard !PlateSanitizer.canonicalize(display).isEmpty else { return }

                        onSave(display, tags)
                        dismiss()
                    }
                    .disabled(PlateSanitizer.canonicalize(PlateSanitizer.sanitizeForDisplay(confirmedPlate)).isEmpty)
                }
            }
            .onAppear {
                confirmedPlate = suggestedPlate
            }
        }
    }
}
