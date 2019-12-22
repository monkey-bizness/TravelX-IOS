//
//  ViewController.swift
//  TravelX
//
//  Created by Fawzi Bedidi on 12/21/19.
//  Copyright © 2019 Fawzi Bedidi. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPhotosFromLibrary()
        let photos = getPhotosFromSQLite();
        addPins(photos: photos);
        // Do any additional setup after loading the view.
    }


    func addPins(photos: Array<Photo>){
        for photo in photos {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: photo.latitude, longitude: photo.longitude);
            map.addAnnotation(annotation);
        }
    }
}

