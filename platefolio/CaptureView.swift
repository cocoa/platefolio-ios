import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("localUserId") private var localUserId: String = ""

    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?

    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var ocrAllCandidates: [String] = []
    @State private var bestPlate: String = ""
    @State private var tagsText: String = ""
    @State private var showConfirm = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Optional: add this camera button later if you want it visible
                // Button("Camera") { showCamera = true }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Import photo", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let ui = selectedUIImage {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if isProcessing {
                    ProgressView("Reading number plate…")
                }

                if let err = errorMessage {
                    Text(err).foregroundStyle(.red)
                }

                if !ocrAllCandidates.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected text candidates")
                            .font(.headline)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(ocrAllCandidates, id: \.self) { s in
                                    Text("• \(s)")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Add plate")
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem = newItem else { return }
                Task { await loadAndRunOCR(item: newItem) }
            
            }
            .onAppear {
                if localUserId.isEmpty {
                    localUserId = UUID().uuidString
                }
            }
            .sheet(isPresented: $showConfirm) {
                ConfirmPlateSheet(
                    image: selectedUIImage,
                    suggestedPlate: bestPlate,
                    tagsText: $tagsText
                ) { confirmedPlate, tags in
                    let display = PlateSanitizer.sanitizeForDisplay(confirmedPlate)
                    let canonical = PlateSanitizer.canonicalize(display)

                    let entity = PlatePostEntity(
                        id: UUID().uuidString,
                        ownerID: localUserId,
                        plateDisplay: display,
                        plateCanonical: canonical,
                        createdAt: Date(),
                        tags: tags,
                        imageData: selectedImageData
                    )
                    modelContext.insert(entity)
                    resetCapture()
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(
                    sourceType: .camera,
                    onImagePicked: { image in
                        Task { await handlePickedUIImage(image) }
                    },
                    dismiss: {
                        showCamera = false
                    }
                )
            }
        }
    }

    private func loadAndRunOCR(item: PhotosPickerItem) async {
        errorMessage = nil
        isProcessing = true
        ocrAllCandidates = []
        bestPlate = ""
        tagsText = ""

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw NSError(domain: "Platefolio", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Couldn’t load image data."
                ])
            }

            selectedImageData = data

            guard let uiImage = UIImage(data: data) else {
                throw NSError(domain: "Platefolio", code: 2, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid image."
                ])
            }

            selectedUIImage = uiImage
            await handlePickedUIImage(uiImage)

        } catch {
            isProcessing = false
            errorMessage = (error as NSError).localizedDescription
        }
    }

    private func handlePickedUIImage(_ uiImage: UIImage) async {
        errorMessage = nil
        isProcessing = true
        ocrAllCandidates = []
        bestPlate = ""
        tagsText = ""

        selectedUIImage = uiImage
        selectedImageData = uiImage.jpegData(compressionQuality: 0.9)

        let result = await PlateOCR.readBestPlate(from: uiImage)
        ocrAllCandidates = result.allCandidatesDisplay
        bestPlate = result.bestPlateDisplay ?? ""

        isProcessing = false
        showConfirm = true
    }

    private func resetCapture() {
        pickerItem = nil
        selectedImageData = nil
        selectedUIImage = nil
        ocrAllCandidates = []
        bestPlate = ""
        tagsText = ""
        errorMessage = nil
    }
}



