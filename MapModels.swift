//
//  MapModels.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//
import UIKit
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
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
    @Published var region = MKCoordinateRegion()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization() // 常に位置情報を利用許可をリクエスト
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone // 無制限の距離フィルター
        manager.allowsBackgroundLocationUpdates = true // バックグラウンド更新を許可
        manager.pausesLocationUpdatesAutomatically = false // 自動的に位置情報更新を一時停止しない
        manager.startUpdatingLocation() // 初期化時に位置情報の取得を開始
        
        checkAuthorizationStatus()
        startUpdatingLocationWithTimer()
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

    private func startUpdatingLocationWithTimer() {
        // 1分ごとに位置情報を更新
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.manager.startUpdatingLocation()
            // 数秒後に停止してバッテリー消費を抑える
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.manager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 200.0,
                longitudinalMeters: 200.0
            )
        }

        let location: CLLocation? = locations.first
        if let valueLat = location?.coordinate.latitude {
            self.myLatitude = valueLat
            print("Updated Latitude: \(valueLat)")
        }
        if let valueLon = location?.coordinate.longitude {
            self.myLongitude = valueLon
            print("Updated Longitude: \(valueLon)")
        }
        if let valueAlt = location?.altitude {
            self.myAltitude = valueAlt
            print("Updated Altitude: \(valueAlt)")
        }
        if let valueFl = location?.floor?.level {
            self.myFloor = valueFl
            print("Updated Floor: \(valueFl)")
        }
        
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
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
 
