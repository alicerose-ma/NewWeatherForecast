//
//  weatherHourly.swift
//  NewWeatherForecast
//
//  Created by HIeu on 9/22/18.
//  Copyright © 2018 Alice Ma. All rights reserved.
//

import Foundation


struct WeatherHourly {
    let summary: String
    let icon: String
    let temperature: Double
    let humidity: Double
    let uvIndex: Int
    let time: Int
    let windSpeed: Double

    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperature = json["temperature"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        guard let humidity = json["humidity"] as? Double else {throw SerializationError.missing("humidity is missing")}
        
        guard let uvIndex = json["uvIndex"] as? Int else {throw SerializationError.missing("UV Index is missing")}
        
        guard let windSpeed = json["windSpeed"] as? Double else {throw SerializationError.missing("wind speed is missing")}
        
        guard let time = json["time"] as? Int else {throw SerializationError.missing("time is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.time = time
        self.windSpeed = windSpeed
    }
    
    func getTime(date: WeatherHourly) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date.time))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    
    static func forecast (url: String, completion: @escaping ([WeatherHourly]?) -> ()) {
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherHourly] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["hourly"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherHourly(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        
        task.resume()
    }
    
}
