//
//  YomCalendarMonthHeader.swift
//  YomCalendar
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

class YomCalendarMonthHeader: UICollectionReusableView {
    var textLabel = UILabel()
    var configuration = Configuration.default

    private var days: [String] {
        // `weekdaySymbols` seems they always return `Sun ... Sat` array regardless `.firstWeekday` property
        // of the calendar. You have to rotate it manually.
        var calendar = configuration.localeConfiguration.calendar
        calendar.locale = configuration.localeConfiguration.locale
        var days = calendar.veryShortStandaloneWeekdaySymbols

        var shifts = configuration.localeConfiguration.calendar.firstWeekday
        while shifts > 1 {
            shifts -= 1
            let sunday = days.removeFirst()
            days.append(sunday)
        }
        return days
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }

    private func loadView() {
        textLabel.textAlignment = .center
        textLabel.font = configuration.fontConfiguration.monthFont
        textLabel.textColor = configuration.colorConfiguration.monthText
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        for day in days {
            let label = UILabel()
            label.font = configuration.fontConfiguration.monthDayFont
            label.textColor = configuration.colorConfiguration.monthText
            label.textAlignment = .center
            label.text = day
            stack.addArrangedSubview(label)
        }

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 30),
            stack.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
