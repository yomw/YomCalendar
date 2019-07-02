//
//  YomCalendarTests.swift
//  YomCalendarTests
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

@testable import YomCalendar
import XCTest

class DateTests: XCTestCase {
    var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    
    func testIntToComponents() {
        XCTAssertEqual(10.years, DateComponents(year: 10))
        XCTAssertEqual(3.months, DateComponents(month: 3))
        XCTAssertEqual(3.month, 3.months)
        XCTAssertEqual(1.day, DateComponents(day: 1))
    }
    func testDateComponentsInDefaultCalendar() {
        let date = Date(timeIntervalSince1970: 1561284751) // 2019-06-23T10:12:31+00:00

        XCTAssertEqual(date.years(calendar: calendar), 2019)
        XCTAssertEqual(date.months(calendar: calendar), 6)
        XCTAssertEqual(date.days(calendar: calendar), 23)
        XCTAssertEqual(date.hours(calendar: calendar), 10)
        XCTAssertEqual(date.minutes(calendar: calendar), 12)
        XCTAssertEqual(date.seconds(calendar: calendar), 31)

        XCTAssertEqual(date.daysInMonth(calendar: calendar), 30)
        XCTAssertFalse(date.isToday(calendar: calendar))

        XCTAssertEqual(date.toFormat("YYYYMMdd", locale: calendar.locale, calendar: calendar), "06/23/2019")
    }
    func testDateComponentsInHebrewCalendar() {
        let date = Date(timeIntervalSince1970: 1561284751) // 2019-06-23T10:12:31+00:00

        var calendar = Calendar(identifier: .hebrew)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "UTC")!

        XCTAssertEqual(date.years(calendar: calendar), 5779)
        XCTAssertEqual(date.months(calendar: calendar), 10)
        XCTAssertEqual(date.days(calendar: calendar), 20)
        XCTAssertEqual(date.hours(calendar: calendar), 10)
        XCTAssertEqual(date.minutes(calendar: calendar), 12)
        XCTAssertEqual(date.seconds(calendar: calendar), 31)

        XCTAssertEqual(date.daysInMonth(calendar: calendar), 30)
        XCTAssertFalse(date.isToday(calendar: calendar))

        XCTAssertEqual(date.toFormat("YYYYMMdd", locale: calendar.locale, calendar: calendar), "10/20/5779")
    }

    func testAddingComponents() {
        let date = Date(timeIntervalSince1970: 1561284751)                  // 2019-06-23T10:12:31+00:00
        let tenYearsFromDate = Date(timeIntervalSince1970: 1876903951)      // 2029-06-23T10:12:31+00:00
        let eightMonthsFromDate = Date(timeIntervalSince1970: 1582452751)   // 2020-02-23T10:12:31+00:00
        let hundredDaysFromDate = Date(timeIntervalSince1970: 1569924751)   // 2019-10-01T10:12:31+00:00

        XCTAssertEqual(date.adding(10.years, calendar: calendar), tenYearsFromDate)
        XCTAssertEqual(date.adding(8.months, calendar: calendar), eightMonthsFromDate)
        XCTAssertEqual(date.adding(100.days, calendar: calendar), hundredDaysFromDate)
    }

    func testSubstractingComponents() {
        let date = Date(timeIntervalSince1970: 1561284751)                  // 2019-06-23T10:12:31+00:00
        let tenYearsToDate = Date(timeIntervalSince1970: 1245751951)        // 2009-06-23T10:12:31+00:00
        let eightMonthsToDate = Date(timeIntervalSince1970: 1540289551)     // 2018-10-23T10:12:31+00:00
        let hundredDaysToDate = Date(timeIntervalSince1970: 1552644751)     // 2019-03-15T10:12:31+00:00

        XCTAssertEqual(date.substracting(10.years, calendar: calendar), tenYearsToDate)
        XCTAssertEqual(date.substracting(8.months, calendar: calendar), eightMonthsToDate)
        XCTAssertEqual(date.substracting(100.days, calendar: calendar), hundredDaysToDate)
    }

    func testComponentsSince() {
        let date = Date(timeIntervalSince1970: 1561284751) // 2019-06-23T10:12:31+00:00
        let twoHoursAnd23MinutesLater = date.adding(2.hours, calendar: calendar).adding(23.minutes, calendar: calendar)
        let twoHoursAnd23MinutesLaterComponents = twoHoursAnd23MinutesLater.componentsSince(date, calendar: calendar,
                                                                                            components: [.day, .hour, .minute])
        XCTAssertEqual(twoHoursAnd23MinutesLaterComponents.day, 0)
        XCTAssertEqual(twoHoursAnd23MinutesLaterComponents.hour, 2)
        XCTAssertEqual(twoHoursAnd23MinutesLaterComponents.minute, 23)

        let manyDaysLater = date.adding(537.days, calendar: calendar)
        let manyDaysLaterComponents = manyDaysLater.componentsSince(date, calendar: calendar,
                                                                    components: [.year, .month])
        XCTAssertEqual(manyDaysLaterComponents.year, 1)
        XCTAssertEqual(manyDaysLaterComponents.month, 5)
    }

    func testTruncate() {
        let date = Date(timeIntervalSince1970: 1561284751)      // 2019-06-23T10:12:31+00:00
        let day = Date(timeIntervalSince1970: 1561248000)       // 2019-06-23T00:00:00+00:00
        let month = Date(timeIntervalSince1970: 1559347200)     // 2019-06-01T00:00:00+00:00
        let year = Date(timeIntervalSince1970: 1546300800)      // 2019-01-01T00:00:00+00:00
        XCTAssertEqual(date.truncated(from: .month, calendar: calendar), year)
        XCTAssertEqual(date.truncated(from: .day, calendar: calendar), month)
        XCTAssertEqual(date.truncated(from: .hour, calendar: calendar), day)

        XCTAssertEqual(date.truncated(at: [.hour, .minute, .second], calendar: calendar), day)
        XCTAssertEqual(date.truncated(at: [.day, .hour, .minute, .second], calendar: calendar), month)
        XCTAssertEqual(date.truncated(at: [.month, .day, .hour, .minute, .second], calendar: calendar), year)
    }

    func testCompare() {
        let date = Date(timeIntervalSince1970: 1561284751)      // 2019-06-23T10:12:31+00:00
        let laterDate = Date(timeIntervalSince1970: 1563876751) // 2019-07-23T10:12:31+00:00

        XCTAssertEqual(date.compare(to: laterDate, granularity: .day, calendar: calendar), ComparisonResult.orderedAscending)
        XCTAssertEqual(date.compare(to: laterDate, granularity: .month, calendar: calendar), ComparisonResult.orderedAscending)
        XCTAssertEqual(date.compare(to: laterDate, granularity: .year, calendar: calendar), ComparisonResult.orderedSame)
        XCTAssertEqual(laterDate.compare(to: date, granularity: .day, calendar: calendar), ComparisonResult.orderedDescending)

        XCTAssert(laterDate.isAfterDate(date, granularity: .day, calendar: calendar))
        XCTAssert(laterDate.isAfterDate(date, granularity: .month, calendar: calendar))
        XCTAssertFalse(laterDate.isAfterDate(date, granularity: .year, calendar: calendar))
        XCTAssert(laterDate.isAfterDate(date, orEqual: true, granularity: .year, calendar: calendar))
        XCTAssertFalse(date.isAfterDate(laterDate, granularity: .day, calendar: calendar))

        XCTAssert(date.isBeforeDate(laterDate, granularity: .day, calendar: calendar))
        XCTAssert(date.isBeforeDate(laterDate, granularity: .month, calendar: calendar))
        XCTAssertFalse(date.isBeforeDate(laterDate, granularity: .year, calendar: calendar))
        XCTAssert(date.isBeforeDate(laterDate, orEqual: true, granularity: .year, calendar: calendar))
        XCTAssertFalse(laterDate.isBeforeDate(date, granularity: .day, calendar: calendar))
    }

    func testToday() {
        XCTAssert(Date().isToday(calendar: calendar))
        XCTAssert(Date().adding(5.minutes, calendar: calendar).isToday(calendar: calendar))
        XCTAssertFalse(Date().adding(5.days, calendar: calendar).isToday(calendar: calendar))

        let today = Date().truncated(from: .hour, calendar: calendar)!
        XCTAssert(today.isToday(calendar: calendar))
        XCTAssert(today.adding(24.hours, calendar: calendar).substracting(1.second, calendar: calendar).isToday(calendar: calendar))
        XCTAssertFalse(today.substracting(1.second, calendar: calendar).isToday(calendar: calendar))
    }

    func testStart() {
        let date = Date(timeIntervalSince1970: 1561284751)      // 2019-06-23T10:12:31+00:00
        let day = Date(timeIntervalSince1970: 1561248000)       // 2019-06-23T00:00:00+00:00
        let month = Date(timeIntervalSince1970: 1559347200)     // 2019-06-01T00:00:00+00:00
        let year = Date(timeIntervalSince1970: 1546300800)      // 2019-01-01T00:00:00+00:00

        XCTAssertEqual(date.dateAtStartOf(.day, calendar: calendar), day)
        XCTAssertEqual(date.dateAtStartOf(.month, calendar: calendar), month)
        XCTAssertEqual(date.dateAtStartOf(.year, calendar: calendar), year)
    }
}
