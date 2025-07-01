//
//  SearchCityViewController.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/19/25.

import UIKit

protocol SearchCityDelegate: AnyObject {
    func didAddCity(_ city: CityWeather)
}

class SearchCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SearchCityDelegate?
    var suggestions: [String] = []
    var selectedSuggestion: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Search City"
        
        // Setup UI elements
        setupUI()

        tableView.dataSource = self
        tableView.delegate = self
        searchTextField.delegate = self
    }

    // MARK: - UI Enhancements
    private func setupUI() {
        // Style Search TextField
        searchTextField.placeholder = "Enter city name (e.g. Toronto)"
        searchTextField.layer.cornerRadius = 12
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.systemGray4.cgColor
        searchTextField.backgroundColor = .systemBackground
        searchTextField.setLeftPaddingPoints(10)
        
        // Style Add Button
        addButton.layer.cornerRadius = 12
        addButton.backgroundColor = UIColor.systemGray
        addButton.setTitleColor(.white, for: .normal)
        addButton.setTitle("Add City", for: .normal)

    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        fetchAutocompleteSuggestions(for: updatedText)
        selectedSuggestion = nil
        return true
    }

    // MARK: - Fetch Autocomplete Suggestions
    func fetchAutocompleteSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            tableView.reloadData()
            return
        }

        let urlString = "http://gd.geobytes.com/AutoCompleteCity?q=\(query)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to fetch suggestions: \(error.localizedDescription)")
                return
            }
            guard let data = data,
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                print("Failed to decode suggestions")
                return
            }
            DispatchQueue.main.async {
                self.suggestions = decoded
                self.tableView.reloadData()

                if decoded.isEmpty {
                    self.showEmptyMessage("No suggestions found.")
                } else {
                    self.removeEmptyMessage()
                }
            }
        }.resume()
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        let suggestion = suggestions[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = suggestion
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        config.textProperties.color = .label
        cell.contentConfiguration = config

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        selectedSuggestion = suggestion
        searchTextField.text = suggestion
        suggestions = []
        tableView.reloadData()
    }

    // MARK: - Add City Functionality
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        guard let input = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !input.isEmpty else {
            print("❌ No input")
            return
        }

        let parts = input.components(separatedBy: ",")
        let cityName = parts[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let countryCode = (parts.count >= 2 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines).uppercased() : "CA")

        print("🌍 City input: '\(cityName)', Country: '\(countryCode)'")

        Task {
            do {
                let weather = try await WeatherController.shared.fetchCityWeather(for: cityName, countryCode: countryCode)
                DispatchQueue.main.async {
                    self.delegate?.didAddCity(weather)
                    CityWeather.save(cities: CityWeather.load() ?? [] + [weather]) // Save with lat/lon
                    self.dismiss(animated: true)
                }
            } catch {
                print("❌ Failed to fetch weather: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Weather Error",
                        message: "Could not fetch weather for '\(cityName.uppercased())'. Try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Empty State Message
    func showEmptyMessage(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.tag = 999
        tableView.backgroundView = label
    }

    func removeEmptyMessage() {
        tableView.backgroundView = nil
    }
}

// MARK: - UITextField Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
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
