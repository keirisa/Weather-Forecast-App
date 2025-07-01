//
//  CityWeatherCell.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/19/25.
//

import UIKit

class CityWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    func configure(with city: CityWeather) {
        cityNameLabel.text = city.cityName
        temperatureLabel.text = city.temperature
            
        // Reset the image view before setting a new image
        weatherIconImageView.image = nil
            
        // Fetch and display the weather icon
        WeatherController.shared.fetchImage(for: city.iconCode) { data in
            if let data = data {
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = UIImage(data: data)
                }
            } else {
                DispatchQueue.main.async {
                    // Fallback image if the icon cannot be fetched
                    self.weatherIconImageView.image = UIImage(systemName: "cloud")
                }
            }
        }
    }
}
