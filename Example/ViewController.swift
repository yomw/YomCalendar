//
//  ViewController.swift
//  Example
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit
import YomCalendar

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {
    let picker = YomCalendarPicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(picker, withInsets: .zero)

        picker.minimumDate = Date()
        picker.maximumDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 250)

        var calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "fr_FR")
        calendar.locale = locale
        picker.calendar = calendar
        picker.locale = locale
        picker.mode = .dateAndTime
        picker.setDate(Date(), animated: false)

        picker.configuration.colorConfiguration = ColorConfiguration.light

        picker.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
    }

    @objc func valueChanged(sender: YomCalendarPicker) {
        print(sender.date)
        picker.configuration.colorConfiguration = ColorConfiguration.dark
    }
}
