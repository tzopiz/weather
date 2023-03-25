//
//  ViewController.swift
//  weather
//
//  Created by Дмитрий Корчагин on 25.03.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var weatherData = WeatherData()
    private let stackView = UIStackView()
    private let nameCityLabel = UILabel()
    private let infoWeatherLabel = UILabel()
    private let temp = UILabel()
    private let weatherImageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearence()
        startLocationManager()
        
    }
    private func configureAppearence() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "back_weather"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        
        stackView.axis = .vertical
        stackView.spacing = 50
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
      
        nameCityLabel.textColor = .white
        nameCityLabel.text = " nameCityLabel "
        nameCityLabel.font =  UIFont(name: "HelveticaNeue", size: 40)
        
      
        infoWeatherLabel.textColor = .white
        infoWeatherLabel.text = " infoWeatherLabel "
        infoWeatherLabel.font =  UIFont(name: "HelveticaNeue", size: 40)
        
       
        temp.textColor = .white
        temp.text = " temp "
        temp.font =  UIFont(name: "HelveticaNeue", size: 40)
        
      
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameCityLabel)
        stackView.addArrangedSubview(infoWeatherLabel)
        stackView.addArrangedSubview(temp)
        view.addSubview(weatherImageView)
        NSLayoutConstraint.activate([
            weatherImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weatherImageView.centerYAnchor.constraint(equalTo: temp.centerYAnchor),
            weatherImageView.heightAnchor.constraint(equalToConstant: 50),
            weatherImageView.widthAnchor.constraint(equalToConstant: 50)
        ])
    
    }
    private func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    private func updateViews() {
        nameCityLabel.text = weatherData.name
        infoWeatherLabel.text = weatherData.weather[0].description
        temp.text = weatherData.main.temp.description + "˚"
        weatherImageView.image = UIImage(named: weatherData.weather[0].icon)
    }
    private func updateWeatherInfo(_ latitude: Double, _ longtitude: Double) {
        let session = URLSession.shared
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&lang=eng&appid=41317a21caca4ceb6cace2d7bf7640b1")!
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else { print(error!.localizedDescription); return }
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                print(self.weatherData.weather.description)
                DispatchQueue.main.async {
                    self.updateViews()
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateWeatherInfo(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
        }
    }
}
