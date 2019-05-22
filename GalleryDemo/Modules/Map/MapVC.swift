//
//  MapVC.swift
//  GalleryDemo
//
//  Created by roman on 21/05/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import MapKit

protocol MapVCProtocol {
    func setup(fullName: String, imageURL: URL, location: CLLocation)
}

class MapVC: UIViewController {

    @IBOutlet private var mapView: MKMapView!

    let annotationIdentifier = "Annotation"

    private var fullName: String!
    private var imageURL: URL!
    private var location: CLLocation!

    private var imageView: WebImageView = {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let imageView = WebImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        return .default
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAnotation()
    }

    func configureAnotation() {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 1000,
                                                  longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = fullName
        imageView.setImage(url: imageURL)
        mapView.addAnnotation(annotation)
    }
}

extension MapVC: MapVCProtocol {
    func setup(fullName: String, imageURL: URL, location: CLLocation) {
        self.fullName = fullName
        self.imageURL = imageURL
        self.location = location
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.addSubview(imageView)
        }

        annotationView?.annotation = annotation

        return annotationView
    }
}
