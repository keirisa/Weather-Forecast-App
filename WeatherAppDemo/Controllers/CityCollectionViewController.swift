//
//  CityCollectionViewController.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/19/25.
//

import UIKit

class CityCollectionViewController: UICollectionViewController {
    
    var cities: [CityWeather] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Saved Cities"
        collectionView.collectionViewLayout = createLayout()
        
        // Load saved cities at launch
        if let loaded = CityWeather.load() {
            cities = loaded
            print("Loaded saved cities: \(cities.count)")
        } else {
            cities = []
            print("Failed to load cities. Starting with an empty list.")
        }
        
        collectionView.reloadData()
        //CityWeather.save(cities: []) // You can add this temporarily in viewDidLoad() to clear saved data //del recent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCitiesAndUpdateWeather()
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 70, bottom: 10, trailing: 10)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let city = cities[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityWeatherCell", for: indexPath) as! CityWeatherCell
        cell.configure(with: city)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell tapped at index \(indexPath.item)")
        performSegue(withIdentifier: "showCityWeatherDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCityWeatherDetail",
           let detailVC = segue.destination as? CityWeatherDetailTableViewController,
           let indexPath = sender as? IndexPath {
            detailVC.city = cities[indexPath.row]
        } else if segue.identifier == "showSearchCity",
                  let nav = segue.destination as? UINavigationController,
                  let searchVC = nav.viewControllers.first as? SearchCityViewController {
            searchVC.delegate = self
        }
    }
    
    @IBAction func addCityTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSearchCity", sender: self)
    }
    
    func addNewCity(_ city: CityWeather) {
        cities.append(city)
        
        // Save to disk
        CityWeather.save(cities: cities)
        
        DispatchQueue.main.async {
            print("Reloading collection view with \(self.cities.count) cities")
            
            // Reload and scroll
            self.collectionView.reloadData()
            let indexPath = IndexPath(item: self.cities.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
            // Show alert confirming save
            let alert = UIAlertController(
                title: "City Added",
                message: "\(city.cityName) has been added and saved.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func loadCitiesAndUpdateWeather() {
        let savedCities = CityWeather.load() ?? []
        var updatedCities: [CityWeather] = []
        
        Task {
            for city in savedCities {
                do {
                    let updatedCity = try await WeatherController.shared.fetchCityWeather(for: city.cityName, countryCode: "CA")
                    updatedCities.append(updatedCity)
                } catch {
                    print("Failed to update weather for \(city.cityName)")
                    updatedCities.append(city)
                }
            }
            
            DispatchQueue.main.async {
                self.cities = updatedCities
                CityWeather.save(cities: updatedCities)
                self.collectionView.reloadData()
            }
        }
    }
}
   
    
// MARK: - Delegate Implementation
extension CityCollectionViewController: SearchCityDelegate {
    func didAddCity(_ city: CityWeather) {
        print("didAddCity called with: \(city.cityName), \(city.temperature), icon: \(city.iconCode)")
        DispatchQueue.main.async {
            self.addNewCity(city)
            print("Current cities after add: \(self.cities.map { $0.cityName })")
        }
    }
}
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
