//
//  YomCalendarPickerViewController.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 21/06/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

class YomCalendarPickerViewController: UIViewController {
    private var hourView = YomCalendarHourPicker()
    private var calView: YomCalendarView?
    private var currentDate: DateComponents?
    var configuration = Configuration.default {
        didSet { reloadData() }
    }

    var didSelectDate: ((Date) -> Void)?

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.lightGray

        buildCalView()
        buildHourView()
    }

    func setDate(_ date: Date, animated: Bool) {
        calView?.setDate(date: date, animated: animated)
        dateUpdated(animated: animated)
    }

    func reloadData() {
        calView?.configuration = configuration
        calView?.reloadData()
        hourView.configuration = configuration
    }

    private func buildCalView() {
        let calView = YomCalendarView(frame: view.frame)
        calView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(calView, at: 0)

        NSLayoutConstraint.activate([
            calView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calView.topAnchor.constraint(equalTo: view.topAnchor)])

        calView.addTarget(self, action: #selector(dateUpdated), for: .valueChanged)
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

    @objc private func dateUpdated(animated: Bool = true) {
        guard let date = calView?.selectedDate else { return }
        hourView.selectedDate = date
        hourView.unfoldDate(animated: animated)
    }

    @objc private func calendarEndEditing() {
        hourView.endEditing(true)
    }

    @objc private func hourDateUpdated() {
        calView?.setDate(date: hourView.selectedDate, animated: true)
    }
}
