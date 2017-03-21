//
//  MapViewController.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit
import MapKit

class CSMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var heightForButtonsLayout: Int = 0
    var locationManager: CLLocationManager!
    var myLocation: CLLocation!
    var annotation: CSDisplayMap!
    var message: CSMessageModel!

    @IBOutlet weak var mkMap: MKMapView!
    @IBOutlet weak var buttonsLayoutHeight: NSLayoutConstraint!

    @IBAction func onOkClicked(_ sender: Any) {
        if (myLocation != nil) {
            let location = CSLocationModel()
            location.lat = myLocation.coordinate.latitude
            location.lng = myLocation.coordinate.longitude
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(myLocation, completionHandler: {(_ placemarks: [CLPlacemark]?, _ error: Error?) -> Void in
                if ((placemarks?.count)! > 0) {
                    let place: CLPlacemark? = placemarks?.last
                    let lines: [String] = place?.addressDictionary?["FormattedAddressLines"] as! [String]
                    let addressString: String = lines.joined(separator: ", ")
                    let dict: [AnyHashable: Any] = [paramLocation: location, paramAddress: addressString]
                    NotificationCenter.default.post(name: NSNotification.Name.SpikaLocationSelectedNotification, object: nil, userInfo: dict)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @IBAction func onCancelClicked(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    convenience init() {
        self.init(height: 0)
    }
    
    init(message: CSMessageModel!) {
        self.message = message;
        self.heightForButtonsLayout = 0

        super.init(nibName: "CSMapViewController", bundle: Bundle.main)
    }
    
    init(height: Int) {
        self.heightForButtonsLayout = height
        super.init(nibName: "CSMapViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mkMap.mapType = .standard
        mkMap.isZoomEnabled = true
        mkMap.isScrollEnabled = true
        if (message != nil) {
            addLocationFromMessage()
        } else {
            setMyLocation()
        }
        mkMap.delegate = self
        buttonsLayoutHeight.constant = CGFloat(heightForButtonsLayout)
        edgesForExtendedLayout = []
    }

    override func viewWillAppear(_ animated: Bool) {
        title = "Location"
    }

    deinit {
        mkMap.delegate = nil
        if (locationManager != nil) {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }

    func addLocationFromMessage() {
        if (message.location != nil) {
            var region = MKCoordinateRegion()
            region.center.latitude = message.location.lat
            region.center.longitude = message.location.lng
            region.span.latitudeDelta = 0.01
            region.span.longitudeDelta = 0.01
            showPin(toLocation: region, title: message.message)
        }
    }

    func showPin(toLocation region: MKCoordinateRegion, title: String) {
        mkMap.setRegion(region, animated: true)
        annotation = CSDisplayMap()
        annotation.title = title
        annotation.coordinate = region.center
        mkMap.addAnnotation(annotation)
    }

    func setMyLocation() {
        if (nil == locationManager) {
            locationManager = CLLocationManager()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()

        if (kAppDeviceVersion >= 8.0) {
            locationManager.requestWhenInUseAuthorization()
        }
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onUserTouchMap))
        gesture.minimumPressDuration = 0.1
        mkMap.addGestureRecognizer(gesture)
    }

    func onUserTouchMap(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        let touchPoint: CGPoint = gestureRecognizer.location(in: mkMap)
        let touchMapCoordinate: CLLocationCoordinate2D = mkMap.convert(touchPoint, toCoordinateFrom: mkMap)
        mkMap.removeAnnotation(annotation)
        annotation.coordinate = touchMapCoordinate
        mkMap.addAnnotation(annotation)
        mkMap.selectAnnotation(annotation, animated: true)
        let oldLocation = CLLocation(coordinate: myLocation.coordinate, altitude: myLocation.altitude, horizontalAccuracy: myLocation.horizontalAccuracy, verticalAccuracy: myLocation.verticalAccuracy, timestamp: myLocation.timestamp)
        myLocation = CLLocation(coordinate: touchMapCoordinate, altitude: oldLocation.altitude, horizontalAccuracy: oldLocation.horizontalAccuracy, verticalAccuracy: oldLocation.verticalAccuracy, timestamp: oldLocation.timestamp)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (myLocation != nil) {
            return
        }
        myLocation = locations.last
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center = myLocation.coordinate
        region.span = MKCoordinateSpanMake(0.1, 0.1)
        region = mkMap.regionThatFits(region)
        mkMap.setRegion(region, animated: true)
        showPin(toLocation: region, title: "Location")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR")
    }

    func mapView(aMapView: MKMapView, viewForAnnotation annotation: MKAnnotationView!) -> MKAnnotationView! {
        var pinView: MKPinAnnotationView? = nil
        if (!annotation.isEqual(mkMap.userLocation)) {
            let defaultPinID: String = "com.invasivecode.pin"
            pinView = (mkMap.dequeueReusableAnnotationView(withIdentifier: defaultPinID) as? MKPinAnnotationView)
            if (pinView == nil) {
                pinView = MKPinAnnotationView(annotation: annotation as! MKAnnotation?, reuseIdentifier: defaultPinID)
            }
            pinView?.pinColor = .purple
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
        } else {
            mkMap.userLocation.title = message.message
        }
        return pinView!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
