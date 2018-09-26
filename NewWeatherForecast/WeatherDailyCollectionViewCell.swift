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
    

    
}

