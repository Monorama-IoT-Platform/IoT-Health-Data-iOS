import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {} 

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
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "HealthKitAuthorization",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "HealthKit authorization was not granted."]
                    ))
                }
            }
        }
    }

    // 이하 기존 함수들도 그대로 유지
    func fetchQuantity(_ id: HKQuantityTypeIdentifier) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            throw NSError(domain: "Invalid type", code: 0)
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    print("⚠️ fetchQuantity error for \(id.rawValue): \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                } else if let quantity = result?.sumQuantity() {
                    let value = quantity.doubleValue(for: type.defaultUnit)
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(returning: 0.0)
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchAverageQuantity(_ id: HKQuantityTypeIdentifier) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            throw NSError(domain: "Invalid type", code: 0)
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    print("⚠️ fetchAverageQuantity error for \(id.rawValue): \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                } else {
                    guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else {
                        continuation.resume(returning: 0.0)
                        return
                    }

                    let total = quantitySamples.reduce(0.0) { sum, sample in
                        sum + sample.quantity.doubleValue(for: sample.quantityType.defaultUnit)
                    }
                    continuation.resume(returning: total / Double(quantitySamples.count))
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchOptionalQuantity(_ id: HKQuantityTypeIdentifier) async throws -> Double? {
        let value = try await fetchQuantity(id)
        return value == 0.0 ? nil : value
    }

    func fetchOptionalAverageQuantity(_ id: HKQuantityTypeIdentifier) async throws -> Double? {
        let value = try await fetchAverageQuantity(id)
        return value == 0.0 ? nil : value
    }

    func fetchSleepAnalysis() async throws -> Int {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw NSError(domain: "Invalid type", code: 0)
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 100, sortDescriptors: nil) { _, results, error in
                if let error = error {
                    print("⚠️ fetchSleepAnalysis error: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                } else {
                    continuation.resume(returning: results?.count ?? 0)
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchECG() async throws -> String {
        let type = HKObjectType.electrocardiogramType()
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, end: Date())

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: nil) { _, results, error in
                if let error = error {
                    print("⚠️ fetchECG error: \(error.localizedDescription)")
                    continuation.resume(returning: "No Data")
                } else if let ecg = results?.first as? HKElectrocardiogram {
                    let classificationString: String
                    switch ecg.classification {
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
