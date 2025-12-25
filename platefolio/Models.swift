import Foundation

struct PlatePost: Identifiable, Codable, Hashable {
    let id: String
    let plateDisplay: String
    let plateCanonical: String
    let createdAt: Date
    var tags: [String]
    var imageData: Data?   // local-only for MVP
}
