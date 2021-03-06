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
    //Blur effect
    var blurEffectView: UIVisualEffectView!
    //Object array of weather data
    var weatherCurrentlyForecast = [WeatherDaily]()
    var weatherHourlyForecast = [WeatherDaily]()
    var weatherHistory = [WeatherDaily]()
    var weatherDailyForecast = [WeatherDaily]()
    
    var locationManager = CLLocationManager()
    var gpsIsOn:Bool = false
    var defaultLocation:CLLocation? = nil
    var isDaily: Bool!
    var isFahrenheit: Bool = true
    var numberOfItem: Int!
    var currentState = state.current
    
    //setting Mode
    enum state {
        case current
        case hourByhour
        case forward5days
        case last5days
    }

    
    @IBOutlet weak var segmentTag: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
       //when user choose setting mode, the screen will be blur and a pop up will appear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        modeView.layer.cornerRadius = 5
        //Auto adjust width and size of cell when change device and potrait
        let width = view.frame.width - 20
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 168)
        modeView.layer.cornerRadius = 5
        updateModetitle()
        //Get current location
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // Header to contain search bar
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    //Search bar recieve location and put it into api
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !(searchBar.text?.isEmpty)!{
            updateWeatherForLocation(location: locationString)
            //updateWeatherForLocation(location: locationString)
        } else if (searchBar.text?.isEmpty)! && gpsIsOn {
            getData(withLocation: defaultLocation!.coordinate)
        }
    }
    
    // MARK: - Navigation
 

    // MARK: UICollectionViewDataSource

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //return the cell with the outputData
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDailyCell", for: indexPath) as! WeatherDailyCollectionViewCell
        cell.setWeather(weatherDaily: outputData(rowIndexPath: indexPath.row, state: currentState), isDaily: isDaily, isFahrenheit: isFahrenheit)
        return cell
    }
    
    func outputData(rowIndexPath: Int, state: state) -> WeatherDaily {
        var weatherDailyObjectData: WeatherDaily!
        //comparing the current mode to set the output data
        switch state {
        case .current:
            weatherDailyObjectData = weatherCurrentlyForecast[rowIndexPath]
        case .last5days:
            weatherDailyObjectData = weatherHistory[rowIndexPath]
        case .forward5days:
            weatherDailyObjectData = weatherDailyForecast[rowIndexPath]
        case .hourByhour:
            weatherDailyObjectData = weatherHourlyForecast[rowIndexPath]
        }
        return weatherDailyObjectData
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if the application has access to location service, this fuction will be call and the default location will be assign with the current location
        defaultLocation = locations.first
        //then, the data of the the weather of the current location will be update
        getData(withLocation: defaultLocation!.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            //if location service access is denied, show popup
            showLocationPopup()
        } else {
            //if location service access is approved, assign gpsIsOn = true
            gpsIsOn = true
        }
    }
    
    func showLocationPopup() {
        //show alert that location service is denied
        let alertController = UIAlertController(title: "Location access disabled", message: "Turn on location permission to get your current location", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Canel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        //create an alert action, which leads to the location service seting for this app
        let openSetting = UIAlertAction(title: "Setting", style: .default) {(action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openSetting)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateWeatherForLocation (location: String){   //get the coordinate of the input address from search bar then get the weather data from that coordinate
        CLGeocoder().geocodeAddressString(location){ (placemarks: [CLPlacemark]?, error: Error?) in // get the coordinate
            if error == nil{
                if let location = placemarks?.first?.location{
                    self.getData(withLocation: location.coordinate) //get the weather data
                }
            }
        }
        
    }
   
   
   func getData(withLocation location: CLLocationCoordinate2D) {
        print(location)
        //let locationCoordinate = "\(location.latitude),\(location.longitude)"
        getHistory(withLocation: location)
        getCurrentForecast(withLocation: location)
        getDailyForecast(withLocation: location)
        getHourlyForecast(withLocation: location)
    }
    
    
    func getDate(daysToAdd: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date!)
    }
    
    func getHistory(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        var weatherData = [WeatherDaily]()
        for i in -7 ...  -1 {
            WeatherDaily.parseHistory(location: locationCoordinate, time: getDate(daysToAdd: i),
                                      completion: {(result: WeatherDaily!) in
                                        if let weatherDailyData = result {
                                            weatherData.append(weatherDailyData)
                                            self.weatherHistory = weatherData
                                        }
                                        /*
                                         Since reloadData is a UI API call, it needs to happen on main thread and not background one
                                         (e.g closures, completion handlers etc), so we dispatch the reloadData statement to
                                         to main thread */
                                        DispatchQueue.main.async {
                                            self.collectionView?.reloadData()
                                        }
                                        
            })
        }
    }
    
    
    func getHourlyForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.hourlyForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherHourlyForecast = weatherData
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    func getDailyForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.dailyForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherDailyForecast = weatherData
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    func getCurrentForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.currentForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherCurrentlyForecast = weatherData
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
   
   //setting Mode to choose current, hour by hour, next 7 days or last 7 days
    func animationIn() {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(modeView)
        modeView.center = self.view.center
        modeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        modeView.alpha = 0
        UIView.animate(withDuration: 0.5){
            self.modeView.alpha = 1
            self.modeView.transform = CGAffineTransform.identity
        }
    }
    
    //leaving setting Mode
    func animationOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.modeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.modeView.alpha = 0
        }) {(success:Bool) in
            self.view.sendSubview(toBack: self.blurEffectView)
            self.modeView.removeFromSuperview()
        }
    }
    
    
    //display user current mode title
    func updateModetitle() {
        switch currentState{
        case .current:
            modeSelected.text = "Selected mode: Current weather"
            isDaily = false
            collectionView?.reloadData()
        case .hourByhour:
            modeSelected.text = "Selected mode: Hour-by-Hour"
            isDaily = false
            collectionView?.reloadData()
        case .forward5days:
            modeSelected.text = "Selected mode: Forecast 7 days"
            isDaily = true
            collectionView?.reloadData()
        case .last5days:
            modeSelected.text = "Selected mode: Last 7 days"
            isDaily = true
            collectionView?.reloadData()
        }
    }
   
   //when user click on setting, a pop up appears
    @IBAction func modeSwitch(_ sender: Any) {
        animationIn()
    }
    
   //when the user click done, the pop up disappears
    @IBAction func Done(_ sender: Any) {
         animationOut()
    }
    
   //user selected to see current weather
    @IBAction func currentTap(_ sender: Any) {
        currentState = .current
        animationOut()
        updateModetitle()
    }
    
    //user selected to see hour by hour weather
    @IBAction func hourByhourTap(_ sender: Any) {
        currentState = .hourByhour
        animationOut()
        updateModetitle()
    }
    
   //user selected to see next week weather
    @IBAction func forwar7daysTap(_ sender: Any) {
        currentState = .forward5days
        animationOut()
        updateModetitle()
    }

   //user selected to see last 7 days weather
    @IBAction func last7daysTap(_ sender: Any) {
       currentState = .last5days
       animationOut()
       updateModetitle()
    }

   //user select unit for temperature - Celsius or Fahrenheit
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
       let getIndex = segmentTag.selectedSegmentIndex
        if getIndex == 0{
            isFahrenheit = true
        } else {
            isFahrenheit = false
        }
        collectionView?.reloadData()
    }

}
