//
//  Date+Extensions.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 28/05/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import Foundation

var defaultCalendar = Calendar.autoupdatingCurrent

extension Int {
    internal func toDateComponents(type: Calendar.Component) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.setValue(self, for: type)
        return dateComponents
    }

    var year: DateComponents { return toDateComponents(type: .year) }
    var years: DateComponents { return toDateComponents(type: .year) }

    var month: DateComponents { return toDateComponents(type: .month) }
    var months: DateComponents { return toDateComponents(type: .month) }

    var week: DateComponents { return toDateComponents(type: .weekOfYear) }
    var weeks: DateComponents { return toDateComponents(type: .weekOfYear) }

    var day: DateComponents { return toDateComponents(type: .day) }
    var days: DateComponents { return toDateComponents(type: .day) }

    var hour: DateComponents { return toDateComponents(type: .hour) }
    var hours: DateComponents { return toDateComponents(type: .hour) }

    var minute: DateComponents { return toDateComponents(type: .minute) }
    var minutes: DateComponents { return toDateComponents(type: .minute) }

    var second: DateComponents { return toDateComponents(type: .second) }
    var seconds: DateComponents { return toDateComponents(type: .second) }
}

//extension Date {
//    var years: Int { return defaultCalendar.component(.year, from: self) }
//    var months: Int { return defaultCalendar.component(.month, from: self) }
//    var weeks: Int { return defaultCalendar.component(.weekOfYear, from: self) }
//    var days: Int { return defaultCalendar.component(.day, from: self) }
//    var hours: Int { return defaultCalendar.component(.hour, from: self) }
//    var minutes: Int { return defaultCalendar.component(.minute, from: self) }
//    var seconds: Int { return defaultCalendar.component(.second, from: self) }
//    var weekday: Int { return defaultCalendar.component(.weekday, from: self) }
//
//    public func truncated(from component: Calendar.Component) -> Date? {
//        switch component {
//        case .month: return truncated(at: [.month, .day, .hour, .minute, .second, .nanosecond])
//        case .day: return truncated(at: [.day, .hour, .minute, .second, .nanosecond])
//        case .hour: return truncated(at: [.hour, .minute, .second, .nanosecond])
//        case .minute: return truncated(at: [.minute, .second, .nanosecond])
//        case .second: return truncated(at: [.second, .nanosecond])
//        default: return self
//        }
//    }

//    func truncated(at components: [Calendar.Component]) -> Date? {
//        var dateComponents = defaultCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
//                                                                from: self)
//        for component in components {
//            switch component {
//            case .month: dateComponents.month = 1
//            case .day: dateComponents.day = 1
//            case .hour: dateComponents.hour = 0
//            case .minute: dateComponents.minute = 0
//            case .second: dateComponents.second = 0
//            default: continue
//            }
//        }
//
//        return defaultCalendar.date(from: dateComponents)
//    }
//
//    func dateAtStartOf(_ unit: Calendar.Component) -> Date {
//        guard let comp = unit.smallerComponent else { return self }
//        return self.truncated(from: comp) ?? self
//    }

//    func compare(to date2: Date, granularity component: Calendar.Component) -> ComparisonResult {
//        return defaultCalendar.compare(self, to: date2, toGranularity: component)
//    }

//    func isAfterDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
//        let result = compare(to: refDate, granularity: granularity)
//        return (orEqual ? (result == .orderedSame || result == .orderedDescending) : result == .orderedDescending)
//    }
//
//    func isBeforeDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
//        let result = compare(to: refDate, granularity: granularity)
//        return (orEqual ? (result == .orderedSame || result == .orderedAscending) : result == .orderedAscending)
//    }

//    var daysInMonth: Int {
//        return defaultCalendar.range(of: .day, in: .month, for: self)!.count
//    }

//    func toFormat(_ format: String) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = configuration.staticConfiguration.locale
//        formatter.dateFormat = format
//        return formatter.string(from: self)
//    }

//    func isToday() -> Bool {
//        return defaultCalendar.isDateInToday(self)
//    }

//    func componentsSince(_ date: Date, components: [Calendar.Component]? = nil) -> DateComponents {
//        let allComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
//        let cmps = (components != nil ? Set(components!) : allComponents)
//        return defaultCalendar.dateComponents(cmps, from: date, to: self)
//    }
//}

class CalendarDate {
    let date: Date
    var calendar: Calendar
    var locale: Locale?

    var years: Int { return calendar.component(.year, from: date) }
    var months: Int { return calendar.component(.month, from: date) }
    var weeks: Int { return calendar.component(.weekOfYear, from: date) }
    var days: Int { return calendar.component(.day, from: date) }
    var hours: Int { return calendar.component(.hour, from: date) }
    var minutes: Int { return calendar.component(.minute, from: date) }
    var seconds: Int { return calendar.component(.second, from: date) }
    var weekday: Int { return calendar.component(.weekday, from: date) }

    init(date: Date = Date(), calendar: Calendar = Calendar.autoupdatingCurrent,
         locale: Locale? = Locale.preferredLocale) {
        self.date = date
        self.calendar = calendar
        self.locale = locale
    }

    init(date: Date = Date(), config: StaticConfiguration = StaticConfiguration.default) {
        self.date = date
        calendar = config.calendar
        locale = config.locale
    }

    func update(configuration: StaticConfiguration) {
        calendar = configuration.calendar
        locale = configuration.locale
    }

    func isToday() -> Bool {
        return calendar.isDateInToday(date)
    }

    func componentsSince(_ date: Date, components: [Calendar.Component]? = nil) -> DateComponents {
        let allComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cmps = (components != nil ? Set(components!) : allComponents)
        return calendar.dateComponents(cmps, from: date, to: self.date)
    }

    func toFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(format)
        return formatter.string(from: date)
    }

    var daysInMonth: Int {
        return calendar.range(of: .day, in: .month, for: date)!.count
    }

    func compare(to date2: Date, granularity component: Calendar.Component) -> ComparisonResult {
        return calendar.compare(date, to: date2, toGranularity: component)
    }

    func isAfterDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedDescending) : result == .orderedDescending)
    }

    func isBeforeDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedAscending) : result == .orderedAscending)
    }

    func compare(to date2: CalendarDate, granularity component: Calendar.Component) -> ComparisonResult {
        return calendar.compare(date, to: date2.date, toGranularity: component)
    }

    func isAfterDate(_ refDate: CalendarDate, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate.date, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedDescending) : result == .orderedDescending)
    }

    func isBeforeDate(_ refDate: CalendarDate, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate.date, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedAscending) : result == .orderedAscending)
    }

    func truncated(at components: [Calendar.Component]) -> CalendarDate? {
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        for component in components {
            switch component {
            case .month: dateComponents.month = 1
            case .day: dateComponents.day = 1
            case .hour: dateComponents.hour = 0
            case .minute: dateComponents.minute = 0
            case .second: dateComponents.second = 0
            default: continue
            }
        }

        guard let date = calendar.date(from: dateComponents) else { return nil }
        return CalendarDate(date: date, calendar: calendar, locale: locale)
    }

    func dateAtStartOf(_ unit: Calendar.Component) -> CalendarDate {
        guard let comp = unit.smallerComponent else { return self }
        return self.truncated(from: comp) ?? self
    }

    public func truncated(from component: Calendar.Component) -> CalendarDate? {
        switch component {
        case .month: return truncated(at: [.month, .day, .hour, .minute, .second, .nanosecond])
        case .day: return truncated(at: [.day, .hour, .minute, .second, .nanosecond])
        case .hour: return truncated(at: [.hour, .minute, .second, .nanosecond])
        case .minute: return truncated(at: [.minute, .second, .nanosecond])
        case .second: return truncated(at: [.second, .nanosecond])
        default: return self
        }
    }
}

func + (lhs: CalendarDate, rhs: DateComponents) -> CalendarDate {
    let date = lhs.calendar.date(byAdding: rhs, to: lhs.date)!
    return CalendarDate(date: date, calendar: lhs.calendar, locale: lhs.locale)
}

func - (lhs: CalendarDate, rhs: DateComponents) -> CalendarDate {
    var inversed = DateComponents()
    Calendar.Component.all.forEach { if let value = rhs.value(for: $0) { inversed.setValue(-value, for: $0) } }
    inversed.isLeapMonth = rhs.isLeapMonth
    let date = lhs.calendar.date(byAdding: inversed, to: lhs.date)!
    return CalendarDate(date: date, calendar: lhs.calendar, locale: lhs.locale)
}

extension Calendar.Component {
    var largerComponent: Calendar.Component? {
        switch self {
        case .year: return .era
        case .month: return .year
        case .day: return .month
        case .hour: return .day
        case .minute: return .hour
        case .second: return .minute
        default: return nil
        }
    }
    var smallerComponent: Calendar.Component? {
        switch self {
        case .era: return .year
        case .year: return .month
        case .month: return .day
        case .day: return .hour
        case .hour: return .minute
        case .minute: return .second
        case .second: return .nanosecond
        default: return nil
        }
    }

    static let all: [Calendar.Component] = [
        .era, .year, .yearForWeekOfYear, .quarter, .month,
        .weekOfMonth, .weekOfYear, .weekday, .weekdayOrdinal, .day,
        .hour, .minute, .second, .nanosecond
    ]
}

extension Locale {
    static var preferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
