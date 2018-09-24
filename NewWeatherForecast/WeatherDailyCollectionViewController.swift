//
//  WeatherDailyCollectionViewController.swift
//  NewWeatherForecast
//
//  Created by Ma Duy Loc on 20/09/2018.
//  Copyright © 2018 Alice Ma. All rights reserved.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "Cell"

class WeatherDailyCollectionViewController: UICollectionViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    //MARK: Thuan
    var blurEffectView: UIVisualEffectView!
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
    
    enum state {
        case current
        case hourByhour
        case forward5days
        case last5days
    }
    
    
    
    @IBOutlet var modeView: UIView!
    @IBOutlet weak var modeSelected: UILabel!

    
    @IBOutlet weak var segmentTag: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let width = view.frame.width - 20
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 168)
        modeView.layer.cornerRadius = 5
        updateModetitle()
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
            return UICollectionReusableView()
        
    }
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch currentState {
        case .current:
            return weatherCurrentlyForecast.count
        case .last5days:
            return weatherHistory.count
            
        case .forward5days:
            return weatherDailyForecast.count
            
        case .hourByhour:
            return weatherHourlyForecast.count
        }
    }

//MARK: Hieu
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDailyCell", for: indexPath) as! WeatherDailyCollectionViewCell
        cell.setWeather(weatherDaily: outputData(rowIndexPath: indexPath.row, state: currentState), isDaily: isDaily, isFahrenheit: isFahrenheit)
        return cell
    }
    
    func outputData(rowIndexPath: Int, state: state) -> WeatherDaily {
        var weatherDailyObjectData: WeatherDaily!
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
        defaultLocation = locations.first
        getData(withLocation: defaultLocation!.coordinate)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            showLocationPopup()
        } else {
            gpsIsOn = true
        }
    }
    func showLocationPopup() {
        let alertController = UIAlertController(title: "Location access disabled", message: "Turn on location permission to get your current location", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Canel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openSetting = UIAlertAction(title: "Setting", style: .default) {(action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openSetting)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateWeatherForLocation (location: String){
        CLGeocoder().geocodeAddressString(location){ (placemarks: [CLPlacemark]?, error: Error?) in
            if error == nil{
                if let location = placemarks?.first?.location{
                    self.getData(withLocation: location.coordinate)
                }
            }
        }
        
    }
    //MARK: Quoc Anh
    
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
    //MARK: Alice
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
    
    func animationOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.modeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.modeView.alpha = 0
        }) {(success:Bool) in
            self.view.sendSubview(toBack: self.blurEffectView)
            self.modeView.removeFromSuperview()
        }
    }
    
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
    @IBAction func modeSwitch(_ sender: Any) {
        animationIn()
    }
    
    @IBAction func Done(_ sender: Any) {
        animationOut()
    }
    
    @IBAction func currentTap(_ sender: Any) {
        currentState = .current
        animationOut()
        updateModetitle()
    }
    
    @IBAction func hourByhourTap(_ sender: Any) {
        currentState = .hourByhour
        animationOut()
        updateModetitle()
    }
    
    @IBAction func forwar5daysTap(_ sender: Any) {
        currentState = .forward5days
        animationOut()
        updateModetitle()
    }
    
    @IBAction func last5daysTap(_ sender: Any) {
        currentState = .last5days
        animationOut()
        updateModetitle()
    }
    
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
        let getIndex = segmentTag.selectedSegmentIndex
        if getIndex == 0{
            isFahrenheit = true
        } else {
            isFahrenheit = false
        }
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDelegate

}
