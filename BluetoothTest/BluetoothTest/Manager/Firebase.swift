
import Foundation
import Firebase

func log(_ str:String) { Firebase.log(str) }

class Firebase {
  
  static var ref: DatabaseReference {
    return Database.database().reference()
  }

  static var locationHandle: DatabaseHandle?
  
  static func getLastLocation(cmp: ((DataSnapshot) -> Void)?) {
    Firebase.ref.child("location_test").observeSingleEvent(of: DataEventType.value) { snap in
      cmp?(snap)
    }

  }
  
  static internal func log(_ str: String) {
    print(str)
    Firebase.ref.child("logs").childByAutoId().setValue(["text": str, "stamp": Date().description])
  }
  
  static func clearLogs() {
    Firebase.ref.child("logs").removeValue()
  }
  
  static func subscribeForLocationUpdate(ref: String, handler: (([String:Any]) -> Void)?) {
    print("subscribe for", ref)
    Firebase.locationHandle = Firebase.ref.child(ref).observe(DataEventType.value, with: { (snapshot) in
      print("snapshot received", snapshot.value, snapshot.children)
      handler?(snapshot.value as? [String : Any] ?? [:])
    })
  }
  
  static func saveOnce(refString: String, data: [String: Any]) {
    Firebase.ref.child(refString).setValue(data)
  }
}
