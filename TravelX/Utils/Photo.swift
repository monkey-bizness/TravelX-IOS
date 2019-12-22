//
//  Photo.swift
//  TravelX
//
//  Created by Fawzi Bedidi on 12/21/19.
//  Copyright © 2019 Fawzi Bedidi. All rights reserved.
//

import Foundation

class Photo {
    var localIdentifier :String;
    var latitude : Double;
    var longitude : Double;
    var country :String;
    var state :String;
    var city :String;
    
    init(id:String, lat:Double, lng:Double) {
        self.localIdentifier = id;
        self.latitude = lat;
        self.longitude = lng;
        self.country = "";
        self.state = "";
        self.city = "";
        getLocationData();
    }
    
    init(id:String, lat:Double, lng:Double, country:String, state:String, city:String) {
        self.localIdentifier = id;
        self.latitude = lat;
        self.longitude = lng;
        self.country = country;
        self.state = state;
        self.city = city;
    }
    
    func getLocationData(){
        let addr =
"""
http://nominatim.openstreetmap.org/reverse?email=fawzi.bedidi@icloud.com&format=jsonv2&lat=##LAT##&lon=##LNG##&zoom=18&addressdetails=1&accept-language=fr&namedetails=1
""";
    
        var address : String;
        address = addr.replacingOccurrences(of: "##LAT##", with: String(format:"%f", self.latitude));
        address = address.replacingOccurrences(of: "##LNG##", with: String(format:"%f", self.longitude));
        
        let url = URL(string:address);
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let data = data, let _ = String(data: data, encoding: .utf8) {
                    self.handleResponse(data: data);
                }
            }
        }

        task.resume()
    }
    
    func handleResponse(data:Data) {
        let json = try? JSONSerialization.jsonObject(with: data)

        if let dictionary = json as? [String: Any] {
            if let nestedDictionary = dictionary["address"] as? [String: Any] {
                if nestedDictionary.index(forKey: "state") != nil {
                    self.state = nestedDictionary["state"] as! String;
                }
                if nestedDictionary.index(forKey: "country") != nil {
                    self.state = nestedDictionary["country"] as! String;
                }
                if nestedDictionary.index(forKey: "city") != nil {
                    self.city = nestedDictionary["city"] as! String;
                } else if nestedDictionary.index(forKey: "county") != nil {
                    self.city = nestedDictionary["county"] as! String;
                } else if nestedDictionary.index(forKey: "village") != nil {
                    self.city = nestedDictionary["village"] as! String;
                }
//                print(nestedDictionary["town"] as! String);
                // access nested dictionary values by key
            }
        }
    }
}
