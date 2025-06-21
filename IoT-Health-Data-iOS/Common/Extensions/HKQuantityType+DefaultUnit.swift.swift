import HealthKit

extension HKQuantityType {
    var defaultUnit: HKUnit {
        switch self.identifier {
        case HKQuantityTypeIdentifier.runningSpeed.rawValue:
            return HKUnit.meter().unitDivided(by: HKUnit.second()) // m/s
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return HKUnit.count().unitDivided(by: HKUnit.minute()) // bpm
        case HKQuantityTypeIdentifier.oxygenSaturation.rawValue:
            return HKUnit.percent() // %
        case HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue,
             HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue:
            return HKUnit.millimeterOfMercury() // mmHg
        case HKQuantityTypeIdentifier.respiratoryRate.rawValue:
            return HKUnit.count().unitDivided(by: HKUnit.minute()) // breaths/min
        case HKQuantityTypeIdentifier.bodyTemperature.rawValue:
            return HKUnit.degreeCelsius() // °C
        case HKQuantityTypeIdentifier.basalEnergyBurned.rawValue,
             HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return HKUnit.kilocalorie() // kcal
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return HKUnit.count() // steps
        default:
            return HKUnit.count()
        }
    }
}
