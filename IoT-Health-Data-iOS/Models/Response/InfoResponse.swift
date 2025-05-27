import Foundation

struct InfoResponse: Decodable {
    let projectTitle: String
    let participant: Int
    let description: String
    let startDate: Int64
    let endDate: Int64
    let createdDate: Int64

    let email: Bool
    let gender: Bool
    let phoneNumber: Bool
    let dateOfBirth: Bool
    let bloodType: Bool
    let height: Bool
    let weight: Bool
    let name: Bool

    let stepCount: Bool
    let runningSpeed: Bool
    let basalEnergyBurned: Bool
    let activeEnergyBurned: Bool
    let sleepAnalysis: Bool
    let heartRate: Bool
    let oxygenSaturation: Bool
    let bloodPressureSystolic: Bool
    let bloodPressureDiastolic: Bool
    let respiratoryRate: Bool
    let bodyTemperature: Bool
    let ecgData: Bool

    let watchDeviceLatitude: Bool
    let watchDeviceLongitude: Bool

    let pm25Value: Bool
    let pm25Level: Bool
    let pm10Value: Bool
    let pm10Level: Bool
    let temperature: Bool
    let temperatureLevel: Bool
    let humidity: Bool
    let humidityLevel: Bool
    let co2Value: Bool
    let co2Level: Bool
    let vocValue: Bool
    let vocLevel: Bool
    let picoDeviceLatitude: Bool
    let picoDeviceLongitude: Bool
}
