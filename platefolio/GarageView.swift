import SwiftUI

struct GarageView: View {
    @StateObject private var store = PlateStoreHolder.shared.store

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.myGarage) { post in
                        GarageCard(post: post)
                    }
                }
                .padding()
            }
            .navigationTitle("My Garage")
        }
    }
}

private struct GarageCard: View {
    let post: PlatePost

    var uiImage: UIImage? {
        guard let data = post.imageData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle().fill(.gray.opacity(0.2))
                    Image(systemName: "car")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 140)
            .clipped()

            // Plate strip
            Text(post.plateDisplay)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.yellow)
                .foregroundStyle(.black)

            if !post.tags.isEmpty {
                Text(post.tags.joined(separator: " · "))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            } else {
                // keep card heights consistent
                Spacer(minLength: 10)
                    .frame(height: 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
    }
}
