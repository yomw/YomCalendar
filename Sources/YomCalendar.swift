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

enum Colors {
    static var purple = UIColor.purple

    enum Background {
        static var base = UIColor(hexString: "FAFAFA")
    }

    enum Text {
        static var base = UIColor.darkGray
        static var disabled = UIColor.lightGray
        static var month = UIColor.gray
        static var selected = UIColor.white
    }
}

enum Font {
    static func defaultFont(withSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
}

public class YomCalendar {
    let calendar = YomCalendarVC()

    public var view: UIView { return calendar.view }
    public var didSelectDate: ((Date) -> Void)? { didSet { calendar.didSelectDate = didSelectDate } }

    public init() {}
}

class YomCalendarVC: UIViewController {
    private var hourView = YomCalendarHourPicker()
    private var calView = YomCalendarView(frame: .zero)
    private var currentDate: DateComponents?
    private var selectedDate = Date()

    var didSelectDate: ((Date) -> Void)?

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.lightGray

        buildCalView()
        buildHourView()
    }

    private func buildCalView() {
        calView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(calView, at: 0)

        NSLayoutConstraint.activate([
            calView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calView.topAnchor.constraint(equalTo: view.topAnchor)])

        calView.addTarget(self, action: #selector(calendarDateUpdated), for: .valueChanged)
        calView.addTarget(self, action: #selector(calendarEndEditing), for: .editingDidEnd)
    }

    private func buildHourView() {
        view.addSubview(hourView)
        NSLayoutConstraint.activate([
            hourView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hourView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hourView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hourView.topAnchor.constraint(equalTo: calView.bottomAnchor)
            ])
        hourView.addTarget(self, action: #selector(hourDateUpdated), for: .valueChanged)
        hourView.sendDate = { self.didSelectDate?($0) }
    }

    @objc private func calendarDateUpdated() {
        guard let date = calView.selectedDate else { return }
        hourView.selectedDate = date
        hourView.unfoldDate()
    }

    @objc private func calendarEndEditing() {
        hourView.endEditing(true)
    }

    @objc private func hourDateUpdated() {
        calView.setDate(date: hourView.selectedDate)
    }
}
