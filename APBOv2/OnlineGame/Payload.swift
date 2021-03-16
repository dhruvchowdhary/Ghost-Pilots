import Foundation
import SpriteKit

struct Payload : Codable {
    public let posX: CGFloat?;
    public let posY: CGFloat?;
    public let angleRad: CGFloat;
    public let velocity: CGVector?;
}
