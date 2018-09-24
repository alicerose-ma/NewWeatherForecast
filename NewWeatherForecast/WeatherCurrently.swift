//
//  WeatherCurrently.swift
//  NewWeatherForecast
//
//  Created by HIeu on 9/23/18.
//  Copyright © 2018 Alice Ma. All rights reserved.
//

import Foundation

class WeatherCurrently{
    let date: String
    let summary: String
    let icon: String
    let temperature: Double
    let humidity: Double
    let uvIndex: Int
    let url: String
    let windSpeed: Double
    
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any], time: String, url: String) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperature = json["apparentTemperature"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        guard let humidity = json["humidity"] as? Double else {throw SerializationError.missing("humidity is missing")}
        
        guard let uvIndex = json["uvIndex"] as? Int else {throw SerializationError.missing("UV Index is missing")}
        
        guard let windSpeed = json["windSpeed"] as? Double else {throw SerializationError.missing("wind speed is missing")}
        
        self.date = time
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.url = url
        self.windSpeed = windSpeed
    }
    
    
    static let apiLink: String = "https://api.darksky.net/forecast/a5fafc7995f9f2c6c2df5af3af69a15b/"
    
    static func foreCastnow(location: String, time: String, completion: @escaping (WeatherCurrently?) -> ()) {
        let url = apiLink + location + "," + time + "T00:00:00Z"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            var weatherNow: WeatherCurrently? = nil
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dataNow = json["currently"] as? [String:Any] {
                            // print("Data now \(dailyForecasts)")
                            weatherNow = try? WeatherCurrently(json: dataNow, time: time, url: url)
                        }
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(weatherNow)
            }
        }
        task.resume()
        
    }
}
