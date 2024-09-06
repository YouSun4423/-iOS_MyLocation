//
//  ContentView.swift
//  MyLocation
//
//  Created by manabe on 2022/11/11.
//

import SwiftUI
import MapKit

struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
    
//    @State  var region = MKCoordinateRegion(
//        center : CLLocationCoordinate2D(
//            latitude: 35.710057714926265,  // 緯度
//            longitude: 139.81071829999996 // 経度
//        ),
//        latitudinalMeters: 1000.0, // 南北
//        longitudinalMeters: 1000.0 // 東西
//    )
//
//    var body: some View {
//        // 地図を表示
//        Map(coordinateRegion: $region)
//            .edgesIgnoringSafeArea(.bottom)
//    }
    
    @ObservedObject  var manager = LocationManager()
    
    // ユーザートラッキングモードを追従モードにするための変数を定義
    @State  var trackingMode = MapUserTrackingMode.follow
    
    var body: some View {
        
        VStack {
//            let deviceId = UIDevice.current.identifierForVendor!.uuidString
//            Text(deviceId)
            Text(String(manager.id))
            
            //            Text(String(manager.lat) + ", " + String(manager.lon))
            //            Text(String(manager.alt) + ", " +  String(manager.fl))
            Text(String(manager.lat) + ", " + String(manager.lon) + ", " + String(manager.alt) + ", " +  String(manager.fl))
            
            Map(coordinateRegion: $manager.region,
                showsUserLocation: true, // マップ上にユーザーの場所を表示するオプションをBool値で指定
                userTrackingMode: $trackingMode) // マップがユーザーの位置情報更新にどのように応答するかを決定
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

