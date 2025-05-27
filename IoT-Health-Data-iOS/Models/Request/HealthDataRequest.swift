struct HealthDataRequest: Codable {
    let stepCount: Double
    let runningSpeed: Double
    let basalEnergyBurned: Double
    let activeEnergyBurned: Double
    let sleepAnalysis: String
    let heartRate: Double
    let oxygenSaturation: Double
    let bloodPressureSystolic: Double
    let bloodPressureDiastolic: Double
    let respiratoryRate: Double
    let bodyTemperature: Double
    let ecgData: String
    let watchDeviceLatitude: Double
    let watchDeviceLongitude: Double
}
