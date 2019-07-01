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

extension Date {
    func years(calendar: Calendar) -> Int { return calendar.component(.year, from: self) }
    func months(calendar: Calendar) -> Int { return calendar.component(.month, from: self) }
    func weeks(calendar: Calendar) -> Int { return calendar.component(.weekOfYear, from: self) }
    func days(calendar: Calendar) -> Int { return calendar.component(.day, from: self) }
    func hours(calendar: Calendar) -> Int { return calendar.component(.hour, from: self) }
    func minutes(calendar: Calendar) -> Int { return calendar.component(.minute, from: self) }
    func seconds(calendar: Calendar) -> Int { return calendar.component(.second, from: self) }
    func weekday(calendar: Calendar) -> Int { return calendar.component(.weekday, from: self) }

    func daysInMonth(calendar: Calendar) -> Int {
        return calendar.range(of: .day, in: .month, for: self)!.count
    }

    func isToday(calendar: Calendar) -> Bool {
        return calendar.isDateInToday(self)
    }

    func componentsSince(_ date: Date, calendar: Calendar,
                         components: [Calendar.Component]? = nil) -> DateComponents {
        let allComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cmps = (components != nil ? Set(components!) : allComponents)
        return calendar.dateComponents(cmps, from: date, to: self)
    }

    func toFormat(_ format: String, locale: Locale?, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale ?? Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate(format)
        return formatter.string(from: self)
    }

    func compare(to date: Date, granularity component: Calendar.Component, calendar: Calendar) -> ComparisonResult {
        return calendar.compare(self, to: date, toGranularity: component)
    }

    func isAfterDate(_ date: Date, orEqual: Bool = false, granularity: Calendar.Component,
                     calendar: Calendar) -> Bool {
        let result = compare(to: date, granularity: granularity, calendar: calendar)
        return (orEqual ? (result == .orderedSame || result == .orderedDescending) : result == .orderedDescending)
    }

    func isBeforeDate(_ date: Date, orEqual: Bool = false, granularity: Calendar.Component,
                      calendar: Calendar) -> Bool {
        let result = compare(to: date, granularity: granularity, calendar: calendar)
        return (orEqual ? (result == .orderedSame || result == .orderedAscending) : result == .orderedAscending)
    }

    func truncated(at components: [Calendar.Component],
                   calendar: Calendar) -> Date? {
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
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
        return calendar.date(from: dateComponents)
    }

    func dateAtStartOf(_ unit: Calendar.Component, calendar: Calendar) -> Date {
        guard let comp = unit.smallerComponent else { return self }
        return self.truncated(from: comp, calendar: calendar) ?? self
    }

    public func truncated(from component: Calendar.Component,
                          calendar: Calendar) -> Date? {
        switch component {
        case .month: return truncated(at: [.month, .day, .hour, .minute, .second, .nanosecond], calendar: calendar)
        case .day: return truncated(at: [.day, .hour, .minute, .second, .nanosecond], calendar: calendar)
        case .hour: return truncated(at: [.hour, .minute, .second, .nanosecond], calendar: calendar)
        case .minute: return truncated(at: [.minute, .second, .nanosecond], calendar: calendar)
        case .second: return truncated(at: [.second, .nanosecond], calendar: calendar)
        default: return self
        }
    }

    func adding(_ components: DateComponents, calendar: Calendar) -> Date {
        return calendar.date(byAdding: components, to: self)!
    }

    func substracting(_ components: DateComponents, calendar: Calendar) -> Date {
        var inversed = DateComponents()
        Calendar.Component.all.forEach {
            if let value = components.value(for: $0) {
                inversed.setValue(-value, for: $0)
            }
        }
        inversed.isLeapMonth = components.isLeapMonth
        return calendar.date(byAdding: inversed, to: self)!
    }
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
