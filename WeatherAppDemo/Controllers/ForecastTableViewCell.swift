//
//  ForecastTableViewCell.swift
//  WeatherAppDemo
//
//  Created by Kate Alyssa Joanna L. de Leon on 3/21/25.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    let cardView = UIView()
    let forecastIconImageView = UIImageView()
    let dateLabel = UILabel()
    let timeLabel = UILabel()
    let temperatureLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        
        // MARK: Card container styling
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // MARK: Configure image view
        forecastIconImageView.contentMode = .scaleAspectFit
        forecastIconImageView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Configure labels
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        temperatureLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        temperatureLabel.textAlignment = .center
        temperatureLabel.textColor = .label
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Vertical stack layout inside card
        let verticalStack = UIStackView(arrangedSubviews: [forecastIconImageView, dateLabel, timeLabel, temperatureLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.alignment = .center
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(verticalStack)

        // MARK: Constraints
        NSLayoutConstraint.activate([
            // Card constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Stack inside card
            verticalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            verticalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            verticalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Image size
            forecastIconImageView.heightAnchor.constraint(equalToConstant: 60),
            forecastIconImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    func configure(with forecast: ForecastEntry) {
        let dateTime = forecast.dt_txt
        let components = dateTime.split(separator: " ")

        if let dateStr = components.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: String(dateStr)) {
                formatter.dateFormat = "EEE-dd"
                dateLabel.text = formatter.string(from: date)
            } else {
                dateLabel.text = String(dateStr)
            }
        }

        timeLabel.text = String(components.last ?? "")
        let celsius = Int(forecast.main.temp - 273.15)
        temperatureLabel.text = "\(celsius)°C"

        let iconCode = forecast.weather.first?.icon ?? "01d"
        let iconURL = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        if let url = URL(string: iconURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.forecastIconImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
