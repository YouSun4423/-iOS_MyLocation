//
//  MapModels.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//
import CoreLocation
import CoreBluetooth
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    static let shared = LocationManager()
    
    private var myDeviceId: String = UIDevice.current.identifierForVendor!.uuidString
    private var myLatitude: Double = 0
    private var myLongitude: Double = 0
    private var myAltitude: Double = 0
    private var myFloor: Int = 0
    
    var id: String {
        return myDeviceId
    }
    
    var lat: Double {
        return myLatitude
    }
    
    var lon: Double {
        return myLongitude
    }

    var alt: Double {
        return myAltitude
    }

    var fl: Int {
        return myFloor
    }

    let manager = CLLocationManager()
    var centralManager: CBCentralManager!
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization() // 常に位置情報を利用許可をリクエスト
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone // 無制限の距離フィルター
        manager.allowsBackgroundLocationUpdates = true // バックグラウンド更新を許可
        manager.pausesLocationUpdatesAutomatically = false // 自動的に位置情報更新を一時停止しない
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
        let status = manager.authorizationStatus
        if status != .authorizedAlways {
            DispatchQueue.main.async {
                self.showAuthorizationAlert()
            }
        }
    }
    
    private func showAuthorizationAlert() {
        let alert = UIAlertController(title: "位置情報の許可",
                                      message: "アプリがバックグラウンドでも位置情報を使用するために、位置情報の常に許可が必要です。設定から許可を変更してください。",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "設定へ移動", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            checkAuthorizationStatus()
        }
    }

    func updateLocation(completion: @escaping (Bool) -> Void) {
        manager.requestLocation()
        completion(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        DispatchQueue.main.async {
            // 現在のregionのspanを保持したままcenterだけを更新
            self.region = MKCoordinateRegion(center: center, span: self.region.span)
        }

        myLatitude = location.coordinate.latitude
        myLongitude = location.coordinate.longitude
        myAltitude = location.altitude
        myFloor = location.floor?.level ?? 0
        // 位置情報が有効である場合にのみデータを送信
        if myLatitude != 0 && myLongitude != 0 {
            postData()
        }
    }
    
    func postData() {
        let baseUrl: String = "http://arta.exp.mnb.ees.saitama-u.ac.jp/ana/staff/post.php" + "?id=" + self.myDeviceId + "&lat=" + String(self.myLatitude) + "&lon=" + String(self.myLongitude) + "&alt=" + String(self.myAltitude) + "&fl=" + String(self.myFloor)
        
        let url = URL(string: baseUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: [])
                print(object)
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    func updateLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .denied {
            print("Location access denied by the user.")
            // 必要ならばユーザーに許可を促す処理を追加
        } else {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CBCentralManagerDelegate methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)])
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print("Discovered \(name) with MAC address \(peripheral.identifier.uuidString) and RSSI \(RSSI)")
            // MACアドレス (peripheral.identifier.uuidString) と電波強度 (RSSI) を処理
        }
    }
}
