import Foundation
import UIKit
import SpriteKit
import Firebase
import FirebaseCore

class DataPusher {

    private static var ref: DatabaseReference = Database.database().reference()

    public static func PushData(path : String, Value : String){
        ref.child(path).setValue(Value)
    }

    // MARK: - For the admin dashboard
    //
    // Everything below is written under `Users/<device>`, next to `Polynite`
    // and `ShopStuff`, and read back by the admin dashboard (web/). Older
    // versions of the game read only `Polynite` and `ShopStuff` from a player,
    // so the extra fields are safe for them.

    /// This device's key under `Users`, the same one the rest of the game uses.
    static var device: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    /// Saves when this device last had the game open, as `LastSeen`, for the
    /// dashboard's "Last active". The server fills in the time (milliseconds
    /// since 1970), so a phone with the wrong clock can't skew it.
    public static func markSeen() {
        guard let device = device else { return }
        ref.child("Users/\(device)/LastSeen").setValue(ServerValue.timestamp())
    }

    /// Saves the name they go by in Game Center, as `GameCenter`, so the
    /// dashboard has something to call players who never picked an online
    /// name.
    public static func saveGameCenterName(_ name: String) {
        guard let device = device, !name.isEmpty else { return }
        ref.child("Users/\(device)/GameCenter").setValue(name)
    }

    /// Adds to a counter on the server, so two writes never overwrite each
    /// other.
    static func add(_ amount: Int, to path: String) {
        guard let device = device else { return }
        ref.child("Users/\(device)/\(path)").setValue(ServerValue.increment(NSNumber(value: amount)))
    }

}

/// Where players spend their time, for the admin dashboard: which screen or
/// mode is on screen, how often it's started, and for how long.
///
/// - `Users/<device>/Play/<scene>/plays`: times that scene came on screen.
/// - `Users/<device>/Play/<scene>/seconds`: time spent in it.
/// - `Users/<device>/Days/<yyyy-MM-dd>`: seconds the game was open that day,
///   in UTC. A day with the game opened at all is there, even at 0.
///
/// `<scene>` is the scene's class name: `GameScene` is Endless, `TurretBoss`,
/// `CPLevel1`, `GameSceneOnline` and so on. Scenes are presented from twenty-odd
/// places, so rather than hook each one, this looks at what's on screen every
/// two seconds. Time is saved when the scene changes and when the game goes
/// to the background, so a session costs a handful of small writes.
final class PlayTracker {

    static let shared = PlayTracker()

    private var timer: Timer?
    /// The scene on screen, and since when its time hasn't been saved.
    private var scene: String?
    private var sceneSince: Date?
    /// Since when the game's open time hasn't been saved.
    private var openSince: Date?

    private static let dayFormat: DateFormatter = {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.timeZone = TimeZone(identifier: "UTC")
        format.dateFormat = "yyyy-MM-dd"
        return format
    }()

    private init() {}

    /// The game came to the front.
    func start() {
        guard timer == nil else { return }
        openSince = Date()
        DataPusher.add(0, to: "Days/\(PlayTracker.dayFormat.string(from: Date()))")
        let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in self?.look() }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        look()
    }

    /// The game is going to the background.
    func stop() {
        timer?.invalidate()
        timer = nil
        saveScene()
        scene = nil
        if let since = openSince {
            let seconds = Int(Date().timeIntervalSince(since).rounded())
            if seconds > 0 { DataPusher.add(seconds, to: "Days/\(PlayTracker.dayFormat.string(from: Date()))") }
        }
        openSince = nil
    }

    private func look() {
        let current = (Global.gameViewController?.view as? SKView)?.scene.map { String(describing: type(of: $0)) }
        guard current != scene else { return }
        saveScene()
        scene = current
        sceneSince = Date()
        if let current = current { DataPusher.add(1, to: "Play/\(current)/plays") }
    }

    private func saveScene() {
        guard let scene = scene, let since = sceneSince else { return }
        sceneSince = nil
        let seconds = Int(Date().timeIntervalSince(since).rounded())
        if seconds > 0 { DataPusher.add(seconds, to: "Play/\(scene)/seconds") }
    }

}
