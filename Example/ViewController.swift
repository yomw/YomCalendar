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
    let calendar = YomCalendar()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(calendar.view, withInsets: .zero)
        calendar.didSelectDate = {
            print($0)
        }
    }
}
