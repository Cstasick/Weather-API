import SwiftUI
import Foundation

struct WeatherResponse: Codable {
    let main: Main
    
    struct Main: Codable {
        let temp: Double
    }
}

class WeatherViewModel: ObservableObject {
    @Published var temperature: Double?
    
    private let apiKey = "e6fef06e8f38410c2cc6ccb242ca00de"
    private let cityName = "College Station"
    private let stateCode = "TX"
    
    func fetchTemperature() {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName),\(stateCode)&appid=\(apiKey)&units=imperial"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.temperature = weatherResponse.main.temp
                    }
                } catch {
                    print("Error decoding weather data: \(error)")
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    var body: some View {
        VStack {
            if let temperature = weatherViewModel.temperature {
                Text("Temperature in College Station, TX: \(temperature, specifier: "%.1f")°F")
                    .font(.largeTitle)
            } else {
                Text("Fetching temperature...")
                    .font(.largeTitle)
            }
        }
        .onAppear {
            weatherViewModel.fetchTemperature()
        }
    }
}

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
