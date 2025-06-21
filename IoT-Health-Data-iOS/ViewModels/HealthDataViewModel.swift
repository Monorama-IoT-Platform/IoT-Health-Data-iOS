import Foundation
import CoreLocation

@MainActor
class HealthDataViewModel: ObservableObject {
    private let healthDataService = HealthDataService()
    private let healthKitManager = HealthKitManager.shared
    private let locationManager = LocationManager.shared

    func fetchAndSendData() async throws {
        do {
            try await healthKitManager.requestAuthorization()

            let stepCount = try await healthKitManager.fetchOptionalQuantity(.stepCount)
            print("👣 Step Count: \(stepCount ?? 0.0)")

            let runningSpeed = try await healthKitManager.fetchOptionalAverageQuantity(.runningSpeed)
            print("🏃 Running Speed: \(runningSpeed ?? 0.0) m/s")

            let basalEnergyBurned = try await healthKitManager.fetchOptionalQuantity(.basalEnergyBurned)
            print("🔥 Basal Energy Burned: \(basalEnergyBurned ?? 0.0) kcal")

            let activeEnergyBurned = try await healthKitManager.fetchOptionalQuantity(.activeEnergyBurned)
            print("⚡ Active Energy Burned: \(activeEnergyBurned ?? 0.0) kcal")

            let sleepAnalysisCount = try await healthKitManager.fetchSleepAnalysis()
            print("😴 Sleep Analysis Count: \(sleepAnalysisCount)")

            let heartRate = try await healthKitManager.fetchOptionalAverageQuantity(.heartRate)
            print("❤️ Heart Rate: \(heartRate ?? 0.0) bpm")

            let oxygenSaturation = try await healthKitManager.fetchOptionalAverageQuantity(.oxygenSaturation)
            print("🫁 Oxygen Saturation: \(oxygenSaturation ?? 0.0)%")

            let systolic = try await healthKitManager.fetchOptionalAverageQuantity(.bloodPressureSystolic)
            print("🩺 Blood Pressure (Systolic): \(systolic ?? 0.0) mmHg")

            let diastolic = try await healthKitManager.fetchOptionalAverageQuantity(.bloodPressureDiastolic)
            print("🩺 Blood Pressure (Diastolic): \(diastolic ?? 0.0) mmHg")

            let respiratoryRate = try await healthKitManager.fetchOptionalAverageQuantity(.respiratoryRate)
            print("🌬️ Respiratory Rate: \(respiratoryRate ?? 0.0) breaths/min")

            let bodyTemp = try await healthKitManager.fetchOptionalAverageQuantity(.bodyTemperature)
            print("🌡️ Body Temperature: \(bodyTemp ?? 0.0) °C")

            let ecgClassification = try await healthKitManager.fetchECG()
            print("📈 ECG Classification: \(ecgClassification)")

            let location = try await locationManager.requestLocation()
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("📍 Latitude: \(latitude)")
            print("📍 Longitude: \(longitude)")

            let request = HealthDataRequest(
                createdAt: Date().toYYYYMMddHHmmSS(),
                stepCount: stepCount,
                runningSpeed: runningSpeed,
                basalEnergyBurned: basalEnergyBurned,
                activeEnergyBurned: activeEnergyBurned,
                sleepAnalysis: "\(sleepAnalysisCount)",
                heartRate: heartRate,
                oxygenSaturation: oxygenSaturation,
                bloodPressureSystolic: systolic,
                bloodPressureDiastolic: diastolic,
                respiratoryRate: respiratoryRate,
                bodyTemperature: bodyTemp,
                ecgData: ecgClassification,
                watchDeviceLatitude: latitude,
                watchDeviceLongitude: longitude
            )

            try await healthDataService.uploadHealthData(request)

        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}
