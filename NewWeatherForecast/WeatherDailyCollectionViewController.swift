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
import CoreLocation

private let reuseIdentifier = "Cell"

class WeatherDailyCollectionViewController: UICollectionViewController, UISearchBarDelegate, CLLocationManagerDelegate {
   
    
    @IBOutlet var modeView: UIView!
    @IBOutlet weak var modeSelected: UILabel!

    
    @IBOutlet weak var segmentTag: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Navigation
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
      return 1
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDailyCell", for: indexPath) as! WeatherDailyCollectionViewCell
        return cell
    }
    
    @IBAction func modeSwitch(_ sender: Any) {
    }
    
    @IBAction func Done(_ sender: Any) {
    }
    
    @IBAction func currentTap(_ sender: Any) {
    }
    
    @IBAction func hourByhourTap(_ sender: Any) {
    }
    
    @IBAction func forwar5daysTap(_ sender: Any) {
    }
    
    @IBAction func last5daysTap(_ sender: Any) {
    }
    
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
    }

}
