//
//  YKDatePicker.swift
//  YourKitchen
//
//  Created by Markus Moltke on 06/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import Foundation

struct YKDatePicker: UIViewRepresentable {
    @Binding var time: Time

    func makeCoordinator() -> YKDatePicker.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = 5
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.onDateChanged), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ datePicker: UIDatePicker, context: Context) {
        let date = Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: datePicker.date)!
        datePicker.setDate(date, animated: true)
    }

    class Coordinator: NSObject {
        var durationPicker: YKDatePicker

        init(_ durationPicker: YKDatePicker) {
            self.durationPicker = durationPicker
        }

        @objc func onDateChanged(sender: UIDatePicker) {
            let calendar = Calendar.current
            let date = sender.date
            durationPicker.time = Time(hour: calendar.component(.hour, from: date), minute: calendar.component(.minute, from: date))
        }
    }
}
