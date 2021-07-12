//
//  ContentModel.swift
//  Sights App
//
//  Created by Justin Young on 7/8/21.
//

import Foundation
import CoreLocation

class ContentModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    var locationManager = CLLocationManager()

    override init() {
        
        // Init method of NSObject
        super.init()
        
        
        // Set content model as the delegate of the location manager
        locationManager.delegate = self
        
        // Request permission from the user
        locationManager.requestWhenInUseAuthorization()
        
        
        
        
    }
    
    // MARK - Location Manager Delegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedAlways ||
            locationManager.authorizationStatus == .authorizedWhenInUse {
            
            // We have permission
            // start geolocating the user, after we get permission
            locationManager.startUpdatingLocation()
            
        }
        else if locationManager.authorizationStatus == .denied {
            // We don't have permission
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Gives us the location of the user
        let userLocation = locations.first
        
        
        if userLocation != nil {
            
            // We have location
            // Stop requesting the location after we get it once
            locationManager.stopUpdatingLocation()
            
            // If we have the coordinates of the user, send into Yelp API
            //getBusinesses(category: "arts", location: userLocation!)
            getBusinesses(category: "restaurants", location: userLocation!)
        }
        
    }
    
    // Mark: - Yelp Api
    
    func getBusinesses(category:String, location:CLLocation) {
        /*
        // Create URL
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(location.coordinate.latitude)$longitude=\(location.coordinate.longitude)$categories=\(category)&limit=6"
        let url = URL(string: urlString)
        */
        var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "categories", value: category),
            URLQueryItem(name: "limit", value: "6")
                    
        ]
        let url = urlComponents?.url
        
        if let url = url {
            
            
            // Create URL request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.addValue("Bearer fpi9vhN6SOdjuvDpV4J3I6L4z33kMIZpeTxFVosAz0-I1g3zf_k0N_hAvzgkoAVdBIQTp0_1xIjZljeQKbT8xeZ_8eINFd2DpSe5Hl3NtwJUCUgGbp7gG-qwKXzrYHYx", forHTTPHeaderField: "Authorization")
            // Get URLSession
            let session = URLSession.shared
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                // Check that there isnt't an error
                if error == nil {
                    print(response)
                }
            }
            // Start the Data Task
            dataTask.resume()
        }
    }
    
}
