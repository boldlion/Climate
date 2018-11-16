//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "96498cec4674dfddad3cfda0f19c27ac"
    
    let locationManager = CLLocationManager()
    let weatherObject = WeatherDataModel()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    //MARK: - Networking
    /***************************************************************/

    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(response.result.error!.localizedDescription)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateWeatherData(json: JSON) {
        
        if let temperatureResult = json["main"]["temp"].double {
            weatherObject.temperature = Int(temperatureResult - 273.15)
            weatherObject.city = json["name"].stringValue
            weatherObject.condition = json["weather"][0]["id"].intValue
            weatherObject.weatherIconName = weatherObject.updateWeatherIcon(condition: weatherObject.condition)
            updateUI()
        }
        else {
             cityLabel.text = "Weather Unavailable"
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUI() {
        cityLabel.text = weatherObject.city
        temperatureLabel.text = String(weatherObject.temperature) + "ºC"
        weatherIcon.image = UIImage(named: weatherObject.weatherIconName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let changeCityVC = segue.destination as! ChangeCityViewController
            changeCityVC.delegate = self
        }
    }

}

extension WeatherViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1] // grabs last and most accurate location value
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let parameters = ["lat" : latitude, "lon" : longitude, "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: parameters)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location unavailable"
    }
}


extension WeatherViewController : ChangeCityDelegate {
    func newCityName(city: String) {
        let parametars = ["q" : city, "appid": APP_ID ]
        getWeatherData(url: WEATHER_URL, parameters: parametars)
    }
}
