import Foundation
import Firebase

public class PlayerData{
    public var uniqueDeviceID = UIDevice.current.identifierForVendor?.uuidString
    public var playerID = "";
    public var color = "player"
}
