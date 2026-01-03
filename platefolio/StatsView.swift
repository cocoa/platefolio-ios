import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("localUserId") private var localUserId: String = ""

    @State private var myPosts: [PlatePostEntity] = []

    var totalMyPosts: Int { myPosts.count }

    var uniqueMyPlates: Int {
        Set(myPosts.map { $0.plateCanonical }).count
    }

    var totalMyTags: Int {
        myPosts.reduce(0) { $0 + $1.tags.count }
    }

    var mostUsedTag: String? {
        let counts = myPosts
            .flatMap { $0.tags }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }

        return counts.max(by: { $0.value < $1.value })?.key
    }

    var shortPlateCount: Int {
        myPosts.filter { $0.plateCanonical.count <= 5 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    StatCard(title: "My posts", value: "\(totalMyPosts)")
                    StatCard(title: "Unique plates", value: "\(uniqueMyPlates)")
                    StatCard(title: "Total tags used", value: "\(totalMyTags)")
                    StatCard(title: "Short plates (≤ 5 chars)", value: "\(shortPlateCount)")
                    StatCard(title: "Most used tag", value: mostUsedTag.map { "#\($0)" } ?? "—")
                    GoalsCard(myCount: totalMyPosts)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear { reload() }
            .onChange(of: localUserId) { _, _ in reload() }
        }
    }

    private func reload() {
        guard !localUserId.isEmpty else {
            myPosts = []
            return
        }

        do {
            let predicate = #Predicate<PlatePostEntity> { $0.ownerID == localUserId }
            let descriptor = FetchDescriptor<PlatePostEntity>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            myPosts = try modelContext.fetch(descriptor)
        } catch {
            myPosts = []
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 28, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct GoalsCard: View {
    let myCount: Int

    private var nextGoal: Int {
        if myCount < 5 { return 5 }
        if myCount < 10 { return 10 }
        if myCount < 25 { return 25 }
        if myCount < 50 { return 50 }
        return ((myCount / 50) + 1) * 50
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next goal")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(myCount) / \(nextGoal) posts")
                .font(.headline)

            ProgressView(value: Double(myCount), total: Double(nextGoal))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        )
    }
}



