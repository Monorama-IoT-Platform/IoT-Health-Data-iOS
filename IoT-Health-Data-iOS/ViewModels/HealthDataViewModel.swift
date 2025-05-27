import Foundation
import HealthKit

@MainActor
class HealthDataViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    private let healthDataService = HealthDataService()

    func requestAuthorization() async throws {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.electrocardiogramType()
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func fetchAndSendData() async {
        do {
            try await requestAuthorization()

            let stepCount = try await fetchQuantity(.stepCount)
            let runningSpeed = try await fetchQuantity(.runningSpeed)
            let basalEnergyBurned = try await fetchQuantity(.basalEnergyBurned)
            let activeEnergyBurned = try await fetchQuantity(.activeEnergyBurned)
            let sleepAnalysisCount = try await fetchSleepAnalysis()
            let heartRate = try await fetchQuantity(.heartRate)
            let oxygenSaturation = try await fetchQuantity(.oxygenSaturation)
            let systolic = try await fetchQuantity(.bloodPressureSystolic)
            let diastolic = try await fetchQuantity(.bloodPressureDiastolic)
            let respiratoryRate = try await fetchQuantity(.respiratoryRate)
            let bodyTemp = try await fetchQuantity(.bodyTemperature)
            let ecgCount = try await fetchECG()

            let watchLatitude = 37.5665
            let watchLongitude = 126.9780

            let request = HealthDataRequest(
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
                ecgData: "\(ecgCount)",
                watchDeviceLatitude: watchLatitude,
                watchDeviceLongitude: watchLongitude
            )

            try await healthDataService.uploadHealthData(request)

        } catch {
            print("Error fetching/sending health data: \(error.localizedDescription)")
        }
    }

    private func fetchQuantity(_ id: HKQuantityTypeIdentifier) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            throw NSError(domain: "Invalid type", code: 0)
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
                    continuation.resume(returning: value)
                }
            }
            healthStore.execute(query)
        }
    }

    private func fetchSleepAnalysis() async throws -> Int {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw NSError(domain: "Invalid type", code: 0)
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 100, sortDescriptors: nil) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: results?.count ?? 0)
                }
            }
            healthStore.execute(query)
        }
    }

    private func fetchECG() async throws -> String {
        let type = HKObjectType.electrocardiogramType()
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: nil) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let ecg = results?.first as? HKElectrocardiogram {
                    let classification = ecg.classification
                    let classificationString: String

                    switch classification {
                    case .notSet: classificationString = "Not Set"
                    case .sinusRhythm: classificationString = "Sinus Rhythm"
                    case .atrialFibrillation: classificationString = "Atrial Fibrillation"
                    case .inconclusiveLowHeartRate: classificationString = "Inconclusive (Low HR)"
                    case .inconclusiveHighHeartRate: classificationString = "Inconclusive (High HR)"
                    case .inconclusivePoorReading: classificationString = "Inconclusive (Poor Reading)"
                    case .inconclusiveOther: classificationString = "Inconclusive (Other)"
                    case .unrecognized: classificationString = "Unrecognized"
                    @unknown default: classificationString = "Unknown"
                    }

                    continuation.resume(returning: classificationString)
                } else {
                    continuation.resume(returning: "No Data")
                }
            }
            healthStore.execute(query)
        }
    }


}
