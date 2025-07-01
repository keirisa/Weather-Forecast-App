//
//  CityWeatherDetailTableViewController.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/22/25.
//

import UIKit

class CityWeatherDetailTableViewController: UITableViewController {
    
    var city: CityWeather?
    var forecast: [ForecastEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = city?.cityName ?? "Weather Forecast"
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: "ForecastCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        
        if let lat = city?.latitude, let lon = city?.longitude {
            fetchForecast(lat: lat, lon: lon)
        } else {
            // Fallback: Refetch lat/lon
            Task {
                await refetchLatLonIfNeeded()
            }
        }
    }
    
    // MARK: - Forecast Fetching
    
    func fetchForecast(lat: Double, lon: Double) {
        Task {
            do {
                let entries = try await WeatherController.shared.fetchForecast(lat: lat, lon: lon)
                DispatchQueue.main.async {
                    self.forecast = entries
                    self.tableView.reloadData()
                }
            } catch {
                showAlert(title: "Error", message: "Failed to fetch forecast: \(error.localizedDescription)")
            }
        }
    }
    
    private func refetchLatLonIfNeeded() async {
        guard let cityName = city?.cityName else { return }
        do {
            let updatedCity = try await WeatherController.shared.fetchCityWeather(for: cityName, countryCode: "CA")
            if let lat = updatedCity.latitude, let lon = updatedCity.longitude {
                updateSavedCityLatLon(cityName: updatedCity.cityName, newLat: lat, newLon: lon)
                fetchForecast(lat: lat, lon: lon)
            }
        } catch {
            showAlert(title: "Error", message: "Could not update coordinates.")
        }
    }
    
    private func updateSavedCityLatLon(cityName: String, newLat: Double, newLon: Double) {
        var savedCities = CityWeather.load() ?? []
        if let index = savedCities.firstIndex(where: { $0.cityName == cityName }) {
            var city = savedCities[index]
            city = CityWeather(cityName: city.cityName,
                               temperature: city.temperature,
                               iconCode: city.iconCode,
                               latitude: newLat,
                               longitude: newLon)
            savedCities[index] = city
            CityWeather.save(cities: savedCities)
            print("✅ Updated coordinates for \(cityName)")
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as? ForecastTableViewCell else {
            fatalError("❌ Could not dequeue ForecastTableViewCell")
        }
        
        let entry = forecast[indexPath.row]
        cell.configure(with: entry)
        return cell
    }
    
    // MARK: - Utility
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func deleteCityTapped(_ sender: UIBarButtonItem) {
        guard let cityToDelete = city else { return }
        
        var savedCities = CityWeather.load() ?? []
        if let index = savedCities.firstIndex(where: { $0.cityName == cityToDelete.cityName }) {
            savedCities.remove(at: index)
            CityWeather.save(cities: savedCities)
            print("Deleted city: \(cityToDelete.cityName)")
        }
        
        let alert = UIAlertController(title: "Deleted", message: "\(cityToDelete.cityName) was removed from saved cities.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
