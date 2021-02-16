//
//  MapViewController.swift
//  FavPlaces
//
//  Created by Вадим Аписов on 08.02.2021.
//  Copyright © 2021 Вадим Аписов. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 300.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeAddressLabel.text = ""
        
        mapView.delegate = self
        
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func centerViewOnUserLocation() {
        checkLocationServices()
        
        guard incomeSegueIdentifier == "showPlaceLocation" else { return }
        
        showUserLocation()
    }

    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(placeAddressLabel.text)
        
        dismiss(animated: true)
    }
    
    @IBAction func closeMapVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        guard incomeSegueIdentifier == "showPlaceLocation" else { return }
        
        mapPinImage.isHidden = true
        placeAddressLabel.isHidden = true
        doneButton.isHidden = true
        
        setupPlacemark()
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are disabled",
                               message: "To enable it go to: Settings > Privacy > Location Services")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            
            if incomeSegueIdentifier == "getAddress" {
                showUserLocation()
            }
            
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not available",
                               message: "To give permission go to: Settings > Privacy > Location Services > FavPlaces")
            }
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    private func showUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ru_RU")
        
        geocoder.reverseGeocodeLocation(center, preferredLocale: locale) { (placemarks, error) in
            if let error = error {
                print(error)

                return
            }

            guard let placemarks = placemarks else { return }

            let placemark = placemarks.first
            let cityName = placemark?.subAdministrativeArea
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare

            DispatchQueue.main.async {
                if cityName != nil && streetName != nil && buildNumber != nil {
                    self.placeAddressLabel.text = "\(cityName!), \(streetName!), \(buildNumber!)"
                } else if cityName != nil && streetName != nil {
                    self.placeAddressLabel.text = "\(cityName!), \(streetName!)"
                } else if cityName != nil {
                    self.placeAddressLabel.text = "\(cityName!)"
                } else {
                    self.placeAddressLabel.text = ""
                }
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
}
