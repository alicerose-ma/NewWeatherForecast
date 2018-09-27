/*
RMIT University Vietnam
Course: COSC2659 iOS Development
Semester: 2018B
Assessment: Project
Author: Tran Nguyen Minh Thuan, Huynh Nguyen Trung Hieu, Ma Ngoc Phuong Anh, Bui Quoc Anh
ID: s3634793(Thuan), s3634747(Hieu), s3634707(Phuong Anh), s3634132(Quoc Anh)
Created date: 10/09/2018
Acknowledgment: If you use any resources, acknowledge here
*/

import Foundation

class WeatherDaily{
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
    let humidity: Double
    let uvIndex: Int
    let windSpeed: Double
    
    //Error Enum
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any], isDaily: Bool) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        //if json file is daily data, temperature = temperatureMax of that day
        //hourly and currently data, temperature = temperature
        if isDaily {
            if let temperature = json["temperatureMax"] as? Double  {
                self.temperature = temperature
            } else {throw SerializationError.missing("temp is missing")}
        }
        else{
            if let temperature = json["temperature"] as? Double  {
                self.temperature = temperature
            } else {throw SerializationError.missing("temp is missing")}
        }
        
        guard let humidity = json["humidity"] as? Double else {throw SerializationError.missing("humidity is missing")}
        
        guard let uvIndex = json["uvIndex"] as? Int else {throw SerializationError.missing("UV Index is missing")}
        
        guard let windSpeed = json["windSpeed"] as? Double else {throw SerializationError.missing("wind speed is missing")}
        
        guard let time = json["time"] as? Double else {throw SerializationError.missing("time is missing")}
        
        self.time = Int(time)
        self.summary = summary
        self.icon = icon
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.windSpeed = windSpeed
    }
    
    //main api key of our team
    static let apiLink: String = "https://api.darksky.net/forecast/a5fafc7995f9f2c6c2df5af3af69a15b/"
    
     //get daily history as array of WeatherDaily
    static func parseHistory(location: String, time: String, completion: @escaping (WeatherDaily?) -> ()) {
        let url = apiLink + location + "," + time + "T00:00:00Z"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            var weatherDailyData: WeatherDaily? = nil
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: true) {
                                        weatherDailyData = weatherObject
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(weatherDailyData)
                
            }
        }
        task.resume()
        
    }
    
    
    //get daily forecast as array of WeatherDaily
    static func dailyForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: true) {
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
    //get next hourly forecast weather data as an array
    static func hourlyForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["hourly"] as? [String:Any] { // search for "hourly" data
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] { //search for "data" in the "hourly" data
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: false) {
                                        forecastArray.append(weatherObject) //append the "hourly" data to the array
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
    
    //get current weather data
    static func currentForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["currently"] as? [String:Any] {
                            if let weatherObject = try? WeatherDaily(json: dailyForecasts, isDaily: false) {
                                forecastArray.append(weatherObject)
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

