import Foundation
import Firebase
import FirebaseCore

class DataPusher {
    
    private static var ref: DatabaseReference = Database.database().reference()
    
    public static func PushData(path : String, Value : String){
        ref.child(path).setValue(Value)
    }
    
}
