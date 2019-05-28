//
//  YomCalendar.swift
//  YomCalendar
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

// Include Foundation
@_exported import Foundation
import UIKit

public class YomCalendar {
    let calendar = YomCalendarVC()

    var configuration = Configuration.default

    public var view: UIView { return calendar.view }
    public var didSelectDate: ((Date) -> Void)? { didSet { calendar.didSelectDate = didSelectDate } }

    public init(configuration: ((Configuration) -> Void)? = nil) {
        configuration?(self.configuration)
        calendar.configuration = self.configuration
    }

    public class Configuration {
        public var colorConfiguration = ColorConfiguration.default
        public var fontConfiguration = FontConfiguration.default

        public var minimumDate = Date()
        public var maximumDate = Date() + 10.years

        public static var `default` = Configuration()
    }
    public class ColorConfiguration {
        public static var `default` = ColorConfiguration()
        public var background = UIColor(hexString: "FAFAFA")

        public var selectionBackground = UIColor.red
        public var selectionText = UIColor.white

        public var todayText = UIColor.red
        public var dayText = UIColor.darkGray
        public var monthText = UIColor.gray
        public var disabledText = UIColor.lightGray

        public var dateTimeBackground = UIColor(hexString: "FAFAFA")
        public var dateTimeText = UIColor.darkGray
        public var dateTimeLines = UIColor(hexString: "DDDDDD")
    }
    public class FontConfiguration {
        public static var `default` = FontConfiguration()

        public var monthFont = UIFont.systemFont(ofSize: 12)
        public var monthDayFont = UIFont.systemFont(ofSize: 12)

        public var dayFont = UIFont.systemFont(ofSize: 16)
        public var todayFont = UIFont.systemFont(ofSize: 16)
        public var disabledFont = UIFont.systemFont(ofSize: 16, weight: .light)
        public var selectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)

        public var dateTimeFont = UIFont.systemFont(ofSize: 16)
        public var pickerFont = UIFont.systemFont(ofSize: 20)
    }
}

class YomCalendarVC: UIViewController {
    private var hourView = YomCalendarHourPicker()
    private var calView: YomCalendarView?
    private var currentDate: DateComponents?
    private var selectedDate = Date()

    var configuration = YomCalendar.Configuration.default

    var didSelectDate: ((Date) -> Void)?

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.lightGray

        buildCalView()
        buildHourView()
    }

    private func buildCalView() {
        let calView = YomCalendarView(frame: view.frame)
        calView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(calView, at: 0)

        NSLayoutConstraint.activate([
            calView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calView.topAnchor.constraint(equalTo: view.topAnchor)])

        calView.addTarget(self, action: #selector(calendarDateUpdated), for: .valueChanged)
        calView.addTarget(self, action: #selector(calendarEndEditing), for: .editingDidEnd)

        calView.configuration = configuration
        self.calView = calView
    }

    private func buildHourView() {
        guard let calView = calView else { return }
        view.addSubview(hourView)
        NSLayoutConstraint.activate([
            hourView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hourView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hourView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hourView.topAnchor.constraint(equalTo: calView.bottomAnchor)
            ])
        hourView.addTarget(self, action: #selector(hourDateUpdated), for: .valueChanged)
        hourView.sendDate = { self.didSelectDate?($0) }
        hourView.configuration = configuration
    }

    @objc private func calendarDateUpdated() {
        guard let date = calView?.selectedDate else { return }
        hourView.selectedDate = date
        hourView.unfoldDate()
    }

    @objc private func calendarEndEditing() {
        hourView.endEditing(true)
    }

    @objc private func hourDateUpdated() {
        calView?.setDate(date: hourView.selectedDate)
    }
}
