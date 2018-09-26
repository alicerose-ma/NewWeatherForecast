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
import UIKit

class WeatherDailyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weatherStatus: UITextView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherDate: UILabel!
    @IBOutlet weak var weatherHumid: UILabel!
    @IBOutlet weak var uvIndex: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var background: UIImageView!
    
    var isDaily: Bool!
    var isFahrenheit: Bool!
    
     func setWeather(weatherDaily: WeatherDaily, isDaily: Bool, isFahrenheit: Bool) { //appear data on the cell
        self.isFahrenheit = isFahrenheit
        self.isDaily = isDaily
        background.image = UIImage(named: weatherDaily.icon + "bg")
        weatherImage.image = UIImage(named: weatherDaily.icon)
        weatherDate.text = convertUnixTimeToRealTime(unixTime: weatherDaily.time, isDaily: self.isDaily)
        weatherStatus.text = weatherDaily.summary
        weatherTemp.text = convertUnit(temp: Int(weatherDaily.temperature), isFahrenheit: isFahrenheit)
        weatherHumid.text = "Humidity \(Int((weatherDaily.humidity)*100)) %"
        uvIndex.text = "UV \(weatherDaily.uvIndex)"
        windSpeed.text = "Wind Speed \(Int(weatherDaily.windSpeed)) mph"
        print(weatherDaily.summary)
    }

    
}

