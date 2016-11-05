///
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by TheBao on 16/10/16.
//  Copyright © 2016 TheBao. All rights reserved.
//

import Foundation
import CoreLocation

extension Coordinate {
    init(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}

final class LocationManager : NSObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()

    var onLocationFix: ((Coordinate) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestLocation()
    }
    func getPermission() {
       
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            manager.requestWhenInUseAuthorization()
        }

    }
    // MARK: CCLocationManager Delegates

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else { return }
        // 2 way : Delegate and closure /  5:20 video

        let coordinate = Coordinate(location: location)

        if let onLocationFix = onLocationFix {
            onLocationFix(coordinate)
        }

    }

}
