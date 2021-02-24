import Foundation
import SpriteKit

struct Payload : Codable {
    public let shipPosX: CGFloat;
    public let shipPosY: CGFloat;
    public let shipAngleRad: CGFloat;
    public let hasPowerup: Bool;
    
}
