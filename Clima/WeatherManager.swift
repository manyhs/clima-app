//
//  WeatherManager.swift
//  Clima
//
//  Created by many on 9/11/26.
//  Copyright © 2026 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=4d1f820e317a66cf4adc5efa2d04c717&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlstring = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlstring)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let urlstring = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        
        performRequest(with: urlstring)
        
    }
    
    func performRequest (with urlString: String){
        
        // 1 create URL
        
        if let url = URL(string: urlString){
            
            // 2 create URL session
            
            let session = URLSession(configuration: .default)
            
            // 3 give session a taskt
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    
                    if let weather = self.parseJSON(safeData){
                        
                        self.delegate?.didUpdateWeather(self,weather: weather)
                        
                    }
                    
                }
            }
            
            // 4
            
            task.resume()
            
        }
        
        
    }
    
    func parseJSON(_ weatherData: Data ) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        
        do {
            
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = (decodedData.weather[0].id)
            let temp = (decodedData.main.temp)
            let name = (decodedData.name)
            
            let weather = WeatherModel(conditionId: id, cityName: name, temprature: temp)
            
            return weather
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
        
       

            
        }
        
       
        
    }

