import Foundation
import SwiftUI

@MainActor
final class PlateStore: ObservableObject {
    @Published private(set) var myGarage: [PlatePost] = []
    @Published private(set) var community: [PlatePost] = []

    func addToGarageAndCommunity(_ post: PlatePost) {
        myGarage.insert(post, at: 0)
        community.insert(post, at: 0)
    }
}
