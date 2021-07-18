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
    
    @Published var restaurants = [Business]()
    @Published var sights = [Business]()

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
            getBusinesses(category: Constants.sightsKey, location: userLocation!)
            getBusinesses(category: Constants.resturantsKey, location: userLocation!)
        }
        
    }
    
    // Mark: - Yelp Api
    
    func getBusinesses(category:String, location:CLLocation) {
        /*
        // Create URL
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(location.coordinate.latitude)$longitude=\(location.coordinate.longitude)$categories=\(category)&limit=6"
        let url = URL(string: urlString)
        */
        var urlComponents = URLComponents(string: Constants.apiURL)
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
            request.addValue("Bearer \(Constants.apiKey)", forHTTPHeaderField: "Authorization")
            // Get URLSession
            let session = URLSession.shared
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                // Check that there isnt't an error
                if error == nil {
                    
                    do {
                        // Parse json
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(BusinessSearch.self, from: data!)
                        
                        
                        DispatchQueue.main.async {
                            
                            // Assign results to the appropriate property
                          switch category {
                            case Constants.sightsKey:
                                self.sights = result.businesses
                            case Constants.resturantsKey:
                                self.restaurants = result.businesses
                            default:
                                break
                            }
                        }
                      
                    }
                    catch {
                        print(error)
                    }
                   
                    
                    
                }
            }
            // Start the Data Task
            dataTask.resume()
        }
    }
    
}
