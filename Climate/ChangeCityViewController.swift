//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate: AnyObject {
    func newCityName(city: String)
}

class ChangeCityViewController: UIViewController {
 
    @IBOutlet weak var changeCityTextField: UITextField!
    
    weak var delegate: ChangeCityDelegate?

    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        if let city = changeCityTextField.text, city != "" {
            delegate?.newCityName(city: city) 
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
