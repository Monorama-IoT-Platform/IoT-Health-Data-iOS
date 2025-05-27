//
//  Classification.swift
//  IoT-Health-Data-iOS
//
//  Created by 모노라마 on 5/27/25.
//


public enum Classification: Int {
    case notSet = 0
    case sinusRhythm = 1
    case atrialFibrillation = 2
    case inconclusiveLowHeartRate = 3
    case inconclusiveHighHeartRate = 4
    case inconclusivePoorReading = 5
    case inconclusiveOther = 6
    case unrecognized = 7
}