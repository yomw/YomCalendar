//
//  Date+Extensions.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 28/05/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import Foundation

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
    var years: Int { return Calendar.current.component(.year, from: self) }
    var months: Int { return Calendar.current.component(.month, from: self) }
    var weeks: Int { return Calendar.current.component(.weekOfYear, from: self) }
    var days: Int { return Calendar.current.component(.day, from: self) }
    var hours: Int { return Calendar.current.component(.hour, from: self) }
    var minutes: Int { return Calendar.current.component(.minute, from: self) }
    var seconds: Int { return Calendar.current.component(.second, from: self) }

    var weekday: Int { return Calendar.current.component(.weekday, from: self) }

    public func truncated(from component: Calendar.Component) -> Date? {
        switch component {
        case .month: return truncated(at: [.month, .day, .hour, .minute, .second, .nanosecond])
        case .day: return truncated(at: [.day, .hour, .minute, .second, .nanosecond])
        case .hour: return truncated(at: [.hour, .minute, .second, .nanosecond])
        case .minute: return truncated(at: [.minute, .second, .nanosecond])
        case .second: return truncated(at: [.second, .nanosecond])
        default: return self
        }
    }

    func truncated(at components: [Calendar.Component]) -> Date? {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

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

        return Calendar.current.date(from: dateComponents)
    }

    func dateAtStartOf(_ unit: Calendar.Component) -> Date {
        guard let comp = unit.smallerComponent else { return self }
        return self.truncated(from: comp) ?? self
    }

    func compare(to date2: Date, granularity component: Calendar.Component) -> ComparisonResult {
        return Calendar.current.compare(self, to: date2, toGranularity: component)
    }

    func isAfterDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedDescending) : result == .orderedDescending)
    }

    func isBeforeDate(_ refDate: Date, orEqual: Bool = false, granularity: Calendar.Component) -> Bool {
        let result = compare(to: refDate, granularity: granularity)
        return (orEqual ? (result == .orderedSame || result == .orderedAscending) : result == .orderedAscending)
    }

    var daysInMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)!.count
    }

    func toFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.preferredLocale
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }

    func componentsSince(_ date: Date, components: [Calendar.Component]? = nil) -> DateComponents {
        let allComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cmps = (components != nil ? Set(components!) : allComponents)
        return Calendar.current.dateComponents(cmps, from: date, to: self)
    }
}

public func + (lhs: Date, rhs: DateComponents) -> Date {
    return Calendar.current.date(byAdding: rhs, to: lhs)!
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
}

extension Locale {
    static var preferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
