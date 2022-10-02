//
//  LocationManager.swift
//  MibandWidgetExtension
//
//  Created by Abdullah Kardas on 1.10.2022.
//

import Combine
import CoreLocation


public typealias Location = CLLocationCoordinate2D

final class LocationManager: NSObject {
  fileprivate lazy var locationManager = CLLocationManager()
  fileprivate var locationStatus = CLAuthorizationStatus.notDetermined

  fileprivate var locationPromise: ((Result<Location, Error>) -> Void)?
   

  func updateLocation() -> AnyPublisher<Location, Error> {
    Future { [weak self] promise in
      guard let self = self else {
        return
      }

      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.requestWhenInUseAuthorization()
      self.locationManager.startUpdatingLocation()

      self.locationPromise = promise

    }.eraseToAnyPublisher()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let locationObj = locations.last {
      let coord = locationObj.coordinate
      let location = Location(latitude: coord.latitude, longitude: coord.longitude)
      locationPromise?(.success(location))
    }
  }

  func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    locationPromise?(.failure(error))
  }
}
