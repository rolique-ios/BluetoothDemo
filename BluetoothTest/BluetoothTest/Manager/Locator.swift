
import UIKit
import CoreLocation
import CoreMotion


enum BatteryMode: String {
  case accuracy
}

class Locator: NSObject {
  static let main: Locator = Locator()
  var location: CLLocation?
  
  private override init() {
    super.init()
  }
  
  private var locationManager = CLLocationManager()
  private lazy var locationUpdateTimer: Timer = {
    return Timer(timeInterval: 1, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
  }()
  func start() {
    log("start updating location")
    Firebase.clearLogs()
    configureLocationManager()
    RunLoop.main.add(locationUpdateTimer, forMode: .default)
  }

  func stop() {
    log("stop updating location")
    locationManager.stopUpdatingLocation()
  }
  
  @objc func getLocation() {
    locationManager.requestLocation()
  }
  
  private func configureLocationManager() {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.requestLocation()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 20
    locationManager.startUpdatingLocation()
  }
  
}

extension CLLocation {
  var data: [String: Any] {
    return [
      "lat": coordinate.latitude.description,
      "lon": coordinate.longitude.description,
      "cource": course.description,
      "altitude": altitude.description,
      "speed": speed.description,
      "horizontal_accuracy": horizontalAccuracy.description,
      "vertical_accuracy": verticalAccuracy.description,
    ]
  }
  
  var printed: String {
    return "lat: \(coordinate.latitude.description), lon: \(coordinate.longitude.description), cource: \(course.description), altitude: \(altitude.description), speed: \(speed.description), horizontal_accuracy: \(horizontalAccuracy.description), vertical_accuracy: \(verticalAccuracy.description)"
  }
  
  var jsonString: String? { return self.data.toJSONString() }
}

extension Locator: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    log("didUpdateLocations")
    
    locations.forEach { location in
      Firebase.logLocation(location)
      Locator.main.location = location
    }
    NotificationCenter.default.post(name: NSNotification.Name.onUpdatLocation, object: nil)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    log("location manager did fail with error \(error)")
  }
 
}
