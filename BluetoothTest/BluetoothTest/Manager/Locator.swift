
import UIKit
import CoreLocation
import CoreMotion

extension TimeInterval {
  static let automotive: TimeInterval = 100
  static let walking: TimeInterval = 10
  static let running: TimeInterval = 11
  static let cycling: TimeInterval = 50
  static let stationary: TimeInterval = 400
  static let unknown: TimeInterval = 75
  
  static let update_automotive: TimeInterval = 45
  static let update_walking: TimeInterval = 15
  static let update_running: TimeInterval = 16
  static let update_sycling: TimeInterval = 30
  static let update_stationary: TimeInterval = 120
  static let update_unknown: TimeInterval = 60
}


enum BatteryMode: String {
  case accuracy
}



class Locator: NSObject {
  static let main: Locator = Locator()
  var location: CLLocation?
  
  private override init() {
    super.init()
  }
  
  private enum Mode {
    case start, ready, regionUpdate
  }
  
  private var locationManager = CLLocationManager()
  private var motionManager = CMMotionManager()
  private var pedometer = CMPedometer()
  
  private var refreshTimer = Timer()
  private var backTimer = Timer()
  private var taskID: UIBackgroundTaskIdentifier?
  
  private var timeInterval: TimeInterval = .stationary
  private var minimalDistanceInterval: TimeInterval = .stationary
  private var batteryMode: BatteryMode = .accuracy
  private  var currentMode: Mode = .start
  
  private var startedRegion = false
  
  
  
  func start() {
    Firebase.clearLogs()
    log("start")
    configureLocationManager()
    //    requestLocationWithTimer()
    startPedometer()
  }
  
  private func configureLocationManager() {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.requestLocation()
    //    locationManager.activityType = .fitness
    locationManager.allowsBackgroundLocationUpdates = true
    //    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 20
    locationManager.startMonitoringSignificantLocationChanges()
  }
  
  private func startPedometer() {
    pedometer.startEventUpdates { [weak self] event, error in
      guard error == nil else {
        print("error", error?.localizedDescription ?? "")
        return
      }
      switch event?.type {
      case .resume?:
        Locator.main.minimalDistanceInterval = .walking
        Locator.main.timeInterval = .walking
      case .pause?:
        Locator.main.minimalDistanceInterval = .stationary
        Locator.main.timeInterval = .stationary
      default: break
      }
      switch self?.currentMode {
      case .start?: self?.currentMode = .ready
      case .ready?: self?.requestLocationWithTimer()
      default: break
      }
    }
  }
  
  private func requestLocationWithTimer() {
    configureTimers()
    startTimers()
  }
  
  private func configureTimers() {
    log("configureTimers Locator.main.timeInterval \(Locator.main.timeInterval)")
    refreshTimer = Timer(timeInterval: Locator.main.timeInterval, target: self, selector: #selector(Locator.main.refreshBackgroundTask), userInfo: [:], repeats: true)
    backTimer = Timer(timeInterval: .unknown, target: self, selector: #selector(Locator.main.getLocation), userInfo: [
      "source": "applicationDidEnterBackground NSTimer \(TimeInterval.unknown) sec"], repeats: true)
  }
  
  private func startTimers() {
    log("startTimers")
    
    RunLoop.main.add(refreshTimer, forMode: RunLoop.Mode.default)
    RunLoop.main.add(backTimer, forMode: RunLoop.Mode.default)
  }
  
  @objc private  func getLocation(timer: Timer? = nil) {
    log("getLocation")
    guard batteryMode == .accuracy else {
      return
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 100
    locationManager.requestLocation()
  }
  
  @objc private func refreshBackgroundTask() {
    log("refresh background task")
    
    func endTask() {
      if let taskID = self.taskID {
        log("end background task")
        UIApplication.shared.endBackgroundTask(taskID)
      }
    }
    self.taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: endTask)
    saveStatus()
  }
  
  private func startRegionLocationFrom(location: CLLocation) {
    log("startRegionLocationFrom location \(location)")
    func truncated(d: Double) -> Double { return Double(round(1000*d)/1000) }
    let region = CLCircularRegion(center: location.coordinate, radius: 30, identifier: "region_\(truncated(d: location.coordinate.latitude))_\(truncated(d: location.coordinate.longitude))")
    region.notifyOnEntry = false
    region.notifyOnExit = true
    locationManager.startMonitoring(for: region)
  }
  
}

private extension Locator {
  func saveStatus() {
    log("save status")
    Firebase.saveOnce(refString: "status", data: [
      "battery": batteryMode.rawValue,
      "minimalDistanceInterval": minimalDistanceInterval,
      "timeInterval": timeInterval,
      "stamp": Date().description
      ])
  }
}

extension Locator: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    log("didUpdateLocations")
    
    locations.forEach { location in
      let locator = Locator.main
      if locator.currentMode == .regionUpdate {
        locator.currentMode = .ready
        startRegionLocationFrom(location: location)
      } else if !startedRegion {
        startedRegion = true
        startRegionLocationFrom(location: location)
      }
      let data: [String: Any] = [
        "lat": location.coordinate.latitude,
        "lon": location.coordinate.longitude,
        "stamp": Date().description,
      ]
      Firebase.saveOnce(refString: "location_test", data: data)
  
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    log("location manager did fail with error \(error)")
  }
  
  func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    log("manager pause")
  }
  func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    log("manager resume")
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    log("did exit region \(region.identifier)")
    currentMode = .regionUpdate
    locationManager.stopMonitoring(for: region)
    locationManager.requestLocation()
    requestLocationWithTimer()
    Firebase.saveOnce(refString: "region_exit", data: ["region": region.identifier, "stamp": Date().description])
  }
}
