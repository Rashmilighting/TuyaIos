//
//  HomeDetailTableViewController.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import TuyaSmartDeviceKit

class HomeDetailTableViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var homeIDLabel: UILabel!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Property
    var homeModel: TuyaSmartHomeModel?
    var home: TuyaSmartHome?

    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let model = homeModel else { return }
        
        home = TuyaSmartHome(homeId: model.homeId)
        
        homeIDLabel.text = String(model.homeId)
        homeNameLabel.text = model.name
        cityLabel.text = model.geoName
        
        home?.getWeatherSketch(success: { [weak self] (weatherModel) in
            guard let self = self else { return }
            self.weatherConditionLabel.text = weatherModel?.condition
            self.temperatureLabel.text = weatherModel?.temp
        }) { [weak self] error in
            guard let self = self else { return }
            let errorMessage = error?.localizedDescription ?? ""
            Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Fetch Weather", comment: ""), message: errorMessage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - IBAction
    @IBAction func dismiss(_ sender: UIButton) {
        let alertVC = UIAlertController(title: NSLocalizedString("Dismiss This Home", comment: ""), message: NSLocalizedString("You're going to dismiss this home.", comment: ""), preferredStyle: .actionSheet)
        let action = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss a home."), style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            
            self.home?.dismiss(success: {
                Home.current = nil
                self.navigationController?.popViewController(animated: true)
            }, failure: { [weak self] error in
                guard let self = self else { return }
                let errorMessage = error?.localizedDescription ?? ""
                Alert.showBasicAlert(on: self, with: NSLocalizedString("Failed to Dismiss", comment: "Failed to dismiss a home."), message: errorMessage)
            })
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alertVC.addAction(action)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "edit-home" else { return }
        
        let destination = segue.destination as! EditHomeTableViewController
        destination.home = home
    }
}
