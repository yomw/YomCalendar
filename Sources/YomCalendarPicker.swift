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

public class YomCalendarPicker: UIControl {
    public enum CalendarMode: Int {
        case date, dateAndTime
    }

    private let calendarPicker = YomCalendarPickerViewController()

    public var calendar: Calendar! = Calendar.autoupdatingCurrent {
        didSet {
            configuration.localeConfiguration.calendar = calendar
            calendarPicker.reloadData()
        }
    }
    public var date: Date = Date()
    public var locale: Locale? {
        didSet {
            configuration.localeConfiguration.locale = locale
            calendarPicker.reloadData()
        }
    }
//    public var timeZone: TimeZone? { // TODO
//        didSet {
//            configuration.localeConfiguration.timeZone = timeZone
//            calendarPicker.reloadData()
//        }
//    }
    public var minimumDate = Date() {
        didSet { configuration.minimumDate = minimumDate }
    }
    public var maximumDate = Date() {
        didSet { configuration.maximumDate = maximumDate }
    }

    public func setDate(_ date: Date, animated: Bool) {
        self.date = date
        calendarPicker.setDate(date, animated: animated)
    }

    public var mode: CalendarMode = .dateAndTime {
        didSet {
            configuration.mode = mode
            calendarPicker.reloadData()
        }
    }

    public var configuration = Configuration.default {
        didSet { calendarPicker.configuration = configuration }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        loadView()
    }
}

extension YomCalendarPicker { // private
    private func loadView() {
        calendarPicker.configuration = self.configuration
        calendarPicker.didSelectDate = didSelectDate
        addSubview(calendarPicker.view, withInsets: .zero)
    }

    private func didSelectDate(_ date: Date) {
        self.date = date
        sendActions(for: .valueChanged)
    }
}

public class Configuration {
    public var colorConfiguration = ColorConfiguration.default
    public var fontConfiguration = FontConfiguration.default

    var localeConfiguration = LocaleConfiguration.default

    var minimumDate = Date()
    var maximumDate = Date().adding(10.years, calendar: Calendar.autoupdatingCurrent)
    var mode = YomCalendarPicker.CalendarMode.dateAndTime

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

class LocaleConfiguration {
    static var `default` = LocaleConfiguration()

    var calendar: Calendar = Calendar.autoupdatingCurrent

    private var privateLocale: Locale?
    var locale: Locale? {
        get { return privateLocale ?? Locale.preferredLocale }
        set { privateLocale = newValue }
    }

    private var privateTimeZone: TimeZone?
    var timeZone: TimeZone? {
        get { return privateTimeZone ?? TimeZone.autoupdatingCurrent }
        set { privateTimeZone = newValue }
    }
}
