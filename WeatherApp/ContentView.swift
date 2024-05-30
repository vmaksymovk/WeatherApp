import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                if let weatherData = weatherData {
                    Text("\(Int(weatherData.temperature))°C")
                        .font(.system(size: 100, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    HStack(spacing: 35){
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Min")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("\(Int(weatherData.temp_minimum))°C")
                                .font(.title2)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        
                        WeatherIcon(condition: weatherData.condition)
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Max")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("\(Int(weatherData.temp_maximum))°C")
                                .font(.title2)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    VStack(spacing: 20) {
                        Text(weatherData.locationName)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 10)
                        
                        Text(weatherData.condition)
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Feels like")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("\(Int(weatherData.feels))°C")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            
                            
                            
                            
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.5))
                    )
                    .shadow(radius: 10)

                    .padding(.bottom, 50)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$location) { location in
            if let location = location {
                fetchWeatherData(for: location)
            }
        }
    }
    
    private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "f85760f6e35abd1494c625c265484771"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                // 
//                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//                                    if let placemark = placemarks?.first {
//                                        weatherData?.locationName = placemark.locality ?? ""
//                                    }
//                                }
                
                DispatchQueue.main.async {
                    self.weatherData = WeatherData(
                        locationName: weatherResponse.name,
                        temperature: weatherResponse.main.temp,
                        condition: weatherResponse.weather.first?.description ?? "",
                        feels: weatherResponse.main.feels_like,
                        temp_minimum: weatherResponse.main.temp_min,
                        temp_maximum: weatherResponse.main.temp_max
                    )
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct WeatherIcon: View {
    let condition: String
    
    var body: some View {
        Image(systemName: weatherIcon(for: condition))
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "broken clouds":
            return "cloud.fill"
        case "overcast clouds":
            return "cloud.fill"
        case "light rain":
            return "cloud.rain.fill"
        case "few clouds":
            return "cloud.sun.fill"
            
        default:
            return "questionmark.diamond.fill"
        }
    }
}
