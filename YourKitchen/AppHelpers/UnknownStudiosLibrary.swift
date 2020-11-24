//
//  UnknownStudiosLibrary.swift
//  YourKitchen
//
//  Created by Markus Moltke on 28/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear: Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek: Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday: Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date.end }
    var isInThePast: Bool { self < Date.start }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var nextWeekPlus1: Date {
        Calendar.current.date(byAdding: .day, value: 8, to: self)!
    }

    func addDays(value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: self)!
    }

    static var startTime: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }

    static var start: Date {
        var comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        return Calendar.current.date(from: comp)!
    }

    static var end: Date {
        var comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date().tomorrow)
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        return Calendar.current.date(from: comp)!
    }

    var start: Date {
        var comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        return Calendar.current.date(from: comp)!
    }

    var dateString: String {
        let formatter = DateFormatter()
        // then again set the date format which type of output you need
        formatter.dateFormat = "EEEE"
        // again convert your date to string
        return formatter.string(from: self)
    }

    var dateTimeString: String {
        let formatter = DateFormatter()
        // then again set the date format which type of output you need
        if isInToday {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd-MM-yyyy"
        }
        // again convert your date to string
        return formatter.string(from: self)
    }
}

public extension Identifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    static func != (lhs: Self, rhs: Self) -> Bool {
        lhs.id != rhs.id
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    var url: URL? {
        URL(string: self)
    }
}

extension Color {
    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00FF) / 255
        }
        return (r, g, b, a)
    }
}

extension URL {
    var queryParameters: QueryParameters { QueryParameters(url: self) }

    static var sharedDataFileURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.unknownstudios.yk")!.appendingPathComponent("userID.plist")
    }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }

    subscript(name: String) -> String? {
        queryItems.first(where: { $0.name == name })?.value
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            }
        )
    }
}

extension Sequence {
    func indexed() -> [(offset: Int, element: Element)] {
        Array(enumerated())
    }
}

extension Binding {
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}

#if os(iOS)
    extension UIImage {
        func imageWithSize(size: CGSize) -> UIImage {
            var scaledImageRect = CGRect.zero

            let aspectWidth: CGFloat = size.width / self.size.width
            let aspectHeight: CGFloat = size.height / self.size.height

            // max - scaleAspectFill | min - scaleAspectFit
            let aspectRatio: CGFloat = max(aspectWidth, aspectHeight)

            scaledImageRect.size.width = self.size.width * aspectRatio
            scaledImageRect.size.height = self.size.height * aspectRatio
            scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
            scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0

            UIGraphicsBeginImageContextWithOptions(size, false, 0)

            draw(in: scaledImageRect)

            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return scaledImage!
        }
    }
#endif

extension Array where Element: Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
