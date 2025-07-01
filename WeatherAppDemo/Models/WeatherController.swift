//
//  WeatherController.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/19/25.
//

import Foundation

class WeatherController {
    static let shared = WeatherController()
    
    // MARK: - Headers (Single Source of Truth)
    private let headers = [
        "x-rapidapi-key": "YOUR API KEY",
        "x-rapidapi-host": "open-weather13.p.rapidapi.com"
    ]
    
    // MARK: - Fetch Current Weather by City Name and Country Code
    func fetchCityWeather(for cityName: String, countryCode: String) async throws -> CityWeather {
        let cityPath = "\(cityName)/\(countryCode)"
        let encodedPath = cityPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? cityPath
        let urlString = "https://open-weather13.p.rapidapi.com/city/\(encodedPath)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debugging
        if let json = String(data: data, encoding: .utf8) {
            print("🌤 Current Weather JSON: \(json)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CurrentWeatherResponse.self, from: data)
        
        let tempText = response.main.temp.isFinite ? "\(Int((response.main.temp - 32) * 5 / 9))°C" : "N/A"
        
        return CityWeather(
            cityName: response.name,
            temperature: tempText,
            iconCode: response.weather.first?.icon ?? "01d",
            latitude: response.coord?.lat,
            longitude: response.coord?.lon
        )
    }

    // MARK: - Fetch 5-Day Forecast by Coordinates
    func fetchForecast(lat: Double, lon: Double) async throws -> [ForecastEntry] {
        print("📡 Fetching forecast for coordinates: \(lat), \(lon)")
        
        let urlString = "https://open-weather13.p.rapidapi.com/city/fivedaysforcast/\(lat)/\(lon)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debugging
        print("📦 Forecast Data Received: \(data.count) bytes")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🧾 Forecast Raw JSON:\n\(jsonString)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(ForecastResponse.self, from: data)
        print("✅ Forecast decoded: \(response.list.count) entries")
        
        // Filter only one forecast per day (preferably 12:00:00)
        let filtered = response.list.filter { $0.dt_txt.contains("12:00:00") }
        print("📅 Filtered daily forecasts: \(filtered.count) entries")
        
        return filtered
    }


    // MARK: - Fetch Weather Icon Image
    func fetchImage(for iconCode: String, completion: @escaping (Data?) -> Void) {
        let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        
        guard let url = URL(string: iconURLString) else {
            print("❌ Invalid icon URL: \(iconCode)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Failed to fetch icon: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(data)
            }
        }.resume()
    }
}



    //MAJOR PROBLEMS debugging, layout, tables/collection, API HIT QUOTA GEOBITE NO WORK weather different??
