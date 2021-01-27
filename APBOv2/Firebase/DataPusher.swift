import Foundation
import Firebase
import FirebaseCore

class DataPusher {
    
    private static var ref: DatabaseReference = Database.database().reference()
    
    public static func PushData(path : String, Value : String){
        ref.child(path).setValue(Value)
    }
    
//    public static func PullData(path: String) -> DataSnapshot{
//        ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
//            print("u");
//            if (val)
//            )} { (error) in
//            print("error saving data")
//        }
//    }
}
