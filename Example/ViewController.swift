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
    let calendar = YomCalendarPicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(calendar, withInsets: .zero)

        calendar.minimumDate = Date()
        calendar.maximumDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 50)

//        calendar.calendar = Calendar(identifier: .islamic)
        calendar.locale = Locale(identifier: "en")
        calendar.mode = .dateAndTime
        calendar.setDate(Date(timeIntervalSinceNow: 60 * 60 * 24 * 37), animated: false)

        calendar.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
    }

    @objc func valueChanged(sender: YomCalendarPicker) {
        print(sender.date)
    }
}
