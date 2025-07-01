//
//  CityWeather.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/19/25.
//

import Foundation

struct CityWeather: Codable {
    let cityName: String
    let temperature: String
    let iconCode: String
    var latitude: Double? // <-- changed to var
    var longitude: Double? // <-- changed to var to allow updating the lat/lon later

    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("cityWeather").appendingPathExtension("plist")

    static func save(cities: [CityWeather]) {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(cities)
            try data.write(to: archiveURL, options: .noFileProtection)
            print("Saved cities to: \(archiveURL.path)")
        } catch {
            print("Failed to save cities: \(error)")
        }
    }

    static func load() -> [CityWeather]? {
        let decoder = PropertyListDecoder()
        do {
            if FileManager.default.fileExists(atPath: archiveURL.path) {
                let data = try Data(contentsOf: archiveURL)
                let cities = try decoder.decode([CityWeather].self, from: data)
                print("Loaded \(cities.count) cities from: \(archiveURL.path)")
                return cities
            } else {
                print("No saved cities found.")
                return []
            }
        } catch {
            print("Failed to load cities: \(error)")
            return nil
        }
    }
}
