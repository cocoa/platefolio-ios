import Foundation
import SwiftData

@Model
final class PlatePostEntity {
    @Attribute(.unique) var id: String
    var plateDisplay: String
    var plateCanonical: String
    var createdAt: Date
    var tags: [String]
    var imageData: Data?
    var ownerID: String

    init(
        id: String,
        ownerID: String,
        plateDisplay: String,
        plateCanonical: String,
        createdAt: Date,
        tags: [String],
        imageData: Data?
    ) {
        self.id = id
        self.ownerID = ownerID
        self.plateDisplay = plateDisplay
        self.plateCanonical = plateCanonical
        self.createdAt = createdAt
        self.tags = tags
        self.imageData = imageData
    }
}


