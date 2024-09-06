//
//  SceneDelegate.swift
//  MyLocation
//
//  Created by 矢口悠月 on 2024/09/06.
//
import UIKit
import CoreBluetooth


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func sceneDidBecomeActive(_ scene: UIScene) {
        // アプリがフォアグラウンドに入ったときの処理
        // BLEスキャンを開始
        LocationManager.shared.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

    }

    func sceneWillResignActive(_ scene: UIScene) {
        // アプリがバックグラウンドに入る直前の処理
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // バックグラウンドに入ったときの処理
        LocationManager.shared.updateLocation { _ in }
    }
}
