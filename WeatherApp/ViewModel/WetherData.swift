import Foundation
import CoreLocation
struct WeatherData {
    var locationName: String
    let temperature: Double
    let condition: String
    let feels : Double
    let temp_minimum : Double
    let temp_maximum : Double
}

struct WeatherResponse: Codable {
    let name: String
    let main: MainWether
    let weather: [Weather]
}

struct MainWether: Codable {
    let temp: Double
    let feels_like : Double
    let temp_min : Double
    let temp_max : Double
}

struct Weather : Codable {
    let description: String
}

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations : [CLLocation]) {
        guard let location = locations.last else { return  }
        self.location = location
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error : Error) {
        print(error.localizedDescription)
    }
}
