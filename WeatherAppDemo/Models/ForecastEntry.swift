//
//  ForecastEntry.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/20/25.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastEntry]
}

struct ForecastEntry: Codable {
    let dt_txt: String
    let main: Main
    let weather: [Weather]

    struct Main: Codable {
        let temp: Double
    }

    struct Weather: Codable {
        let icon: String
    }
}
