# 🌦️ Weather Forecast App

![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=for-the-badge&logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-UIKit-blue?style=for-the-badge&logo=xcode)
![PropertyList](https://img.shields.io/badge/Persistence-PropertyList-yellowgreen?style=for-the-badge)

This is a simple iOS app I built for my Winter 2025 Mobile App Development course (MAP523NSC). The app lets users search for cities and view current weather info along with a 5-day forecast using the OpenWeather API.

---

## 🔍 Features

- Add cities to your watch list and view current weather at a glance
- Tap a city to see more details and a 5-day forecast
- Search for any city using the Geobytes autocomplete API
- Weather icons are pulled from OpenWeather so they match the conditions
- Watch list is saved using Property List encoding, so it stays even after you close the app

---

## 📸 Screenshots

| City List | Detail View | Search |
|-----------|-------------|--------|
| ![weather_cities](https://github.com/user-attachments/assets/4124d9ec-6f98-48e7-98dd-11f2b5f851ec) | ![weather_temp](https://github.com/user-attachments/assets/756a547f-7c10-4428-b0ed-5083b51f49f2) |![weather_search](https://github.com/user-attachments/assets/48e1b089-6011-42fc-becc-49ef8878bd86) |

---

## 🧰 Tech Stack

- **Language**: Swift
- **Framework**: UIKit
- **Architecture**: MVC
- **Data Persistence**: PropertyListEncoder / PropertyListDecoder
- **APIs Used**:
  - OpenWeather13 via RapidAPI – for current weather and 5-day forecasts
  - OpenWeather image icons – for weather visuals
  - GeoBytes Autocomplete API – for city name search

---

## 🛠 How It Works

- Built using **UIKit** and storyboard layout
- Used **PropertyListEncoder / Decoder** for saving data locally
- Integrated with:
  - [OpenWeather API](https://rapidapi.com/worldapi/api/open-weather13/playground/) for weather data
  - [OpenWeather Icons](https://openweathermap.org/img/wn/) for weather visuals
  - [GeoBytes](http://gd.geobytes.com/AutoCompleteCity) for city name autocomplete

---

## 👩‍💻 About Me

Hi, I’m **Kate de Leon**, a Computer Programming student at Seneca Polytechnic.  
This project was part of my coursework, and I really enjoyed building it from scratch.

GitHub: [@yourusername](https://github.com/keirisa)

---

## 📎 Note

This was made for educational purposes only. Please don’t copy or repost this project.  
It’s part of Seneca’s academic integrity policy, so all code must be your own work.

