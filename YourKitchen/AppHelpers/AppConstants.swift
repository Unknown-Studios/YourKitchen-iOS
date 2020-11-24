//
//  AppConstants.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public enum AppConstants {
    public enum URL {
        public static var main = "https://yourkitchen.io"
        public static var privacyPolicy = main + "/policies/privacy?hideNav=true"
        public static var termsPolicy = main + "/policies/terms?hideNav=true"
        public static var trelloIOS = "https://trello.com/b/UwS3oZxo/ios"
    }

    public enum Colors {
        // Main Color
        public static var YKColor = Color(red: 1.0, green: 0.68, blue: 0.0)

        public static var facebookColor = Color(red: 0.26, green: 0.4, blue: 0.7)
        public static var googleColor = Color(red: 0.26, green: 0.52, blue: 0.96)
    }

    #if os(iOS)
    public static var multiplier: CGFloat = UIDevice.current.userInterfaceIdiom != .phone ? 1.5 : 1.0
    #endif

    public enum Measure {
        public enum MeasurementType: CaseIterable {
            case none
            case mass
            case volume

            var caseName: String {
                "\(self)"
            }
        }

        public static var units: [Unit?] = [UnitVolume.deciliters, UnitVolume.liters, UnitVolume.milliliters,
                                            UnitVolume.fluidOunces, UnitVolume.cups, UnitVolume.tablespoons,
                                            UnitVolume.teaspoons, UnitMass.grams, UnitMass.ounces,
                                            UnitMass.kilograms, UnitMass.pounds]

        public static func getUnitSymbol(unit: Unit?) -> String {
            if let unit = unit {
                return unit.symbol
            } else {
                return ""
            }
        }

        public static func getUnitType(value: MeasurementType) -> [String] {
            switch value {
            case .volume:
                return ["", "L", "mL", "fl oz", "cup", "tbsp", "tsp"]
            case .mass:
                return ["", "g", "kg", "oz", "lb"]
            case .none:
                return [""]
            }
        }

        public static func convertToLocale(_ value: Double, unit: UnitMass?) -> String {
            formatMeasurement(value, unit: unit)
        }

        public static func convertToLocale(_ value: Double, unit: UnitVolume?) -> String {
            formatMeasurement(value, unit: unit)
        }

        fileprivate static func formatMeasurement(_ value: Double, unit: Unit?) -> String {
            if let unit = unit {
                let formatter = MeasurementFormatter()
                return formatter.string(from: Measurement(value: value, unit: unit))
            } else {
                return value.description
            }
        }
    }
}
