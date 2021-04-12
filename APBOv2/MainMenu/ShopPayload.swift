import Foundation
import SpriteKit

struct ShopPayload : Codable {
    public var lockerDecals: [String] = []
    public var lockerTrails: [String] = []
    public var equippedDecal: String = "default"
    public var equippedTrail: String = "default"
}
