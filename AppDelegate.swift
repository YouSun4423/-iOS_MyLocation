//
//  AppDelegate.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2024/07/19.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }
    

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 位置情報の更新やデータの取得をここで行う
        // 例えばLocationManagerのインスタンスを作成して位置情報を取得する
        let locationManager = LocationManager()
        locationManager.updateLocation() // 必要なロジックを追加
        
        completionHandler(.newData)
    }
}

