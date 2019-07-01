//
//  YomCalendarHourPicker.swift
//  YomCalendar
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

class YomCalendarHourPicker: UIControl {
    static let dateHeight: CGFloat = 60

    var selectedDate: Date {
        didSet { setDateDisplayed(date: selectedDate) }
    }
    var sendDate: ((Date) -> Void)?

    enum Mode {
        case folded, date, picker
    }

    private let picker = UIPickerView()
    private let dateLabel = UILabel()
    private var foldedDate: NSLayoutConstraint!
    private var foldedPicker: NSLayoutConstraint!
    private var deployedDate: NSLayoutConstraint!
    private var deployedPicker: NSLayoutConstraint!
    private var datePicker: NSLayoutConstraint!
    private var mode: Mode = .folded

    var configuration = YomCalendar.Configuration.default

    init() {
        selectedDate = Date()
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        buildDate()
        buildPicker()

        updateMode(.folded, animated: false)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        selectedDate = DateInRegion(formatter.string(from: Date()))!.date
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        tweakPicker(picker)
    }

    private func updateMode(_ mode: Mode, animated: Bool = true) {
        self.mode = mode
        let activate, deactivate: [NSLayoutConstraint]
        switch mode {
        case .folded:
            deactivate = [deployedDate, datePicker, deployedPicker]
            activate = [foldedDate, foldedPicker]
        case .date:
            deactivate = [foldedDate, datePicker, deployedPicker]
            activate = [deployedDate, foldedPicker]
        case .picker:
            deactivate = [foldedDate, deployedDate, foldedPicker]
            activate = [datePicker, deployedPicker]
        }
        NSLayoutConstraint.deactivate(deactivate)
        NSLayoutConstraint.activate(activate)
        if animated {
            UIView.animate(withDuration: 0.3, animations: { self.superview?.layoutIfNeeded() }, completion: { _ in
                self.sendActions(for: .valueChanged)
            })
        } else {
            layoutIfNeeded()
            sendActions(for: .valueChanged)
        }
    }

    func unfoldDate(animated: Bool) {
        updateMode(.date, animated: animated)
    }

    @discardableResult
    override func endEditing(_ force: Bool) -> Bool {
        if mode == .picker {
            updateMode(.date, animated: true)
        }
        return super.endEditing(force)
    }

    @objc func togglePicker() {
        guard configuration.mode == .dateAndTime else { return }
        updateMode(mode == .picker ? .date : .picker, animated: true)
    }

    private func capDate(_ date: Date) -> Date {
        if date < configuration.maximumDate {
            if date > configuration.minimumDate {
                return date
            }
            return configuration.minimumDate
        }
        return configuration.maximumDate
    }
}

extension YomCalendarHourPicker {
    private func buildDate() {
        let container = UIView()
        container.backgroundColor = configuration.colorConfiguration.dateTimeBackground

        let topLine = UIView()
        topLine.backgroundColor = configuration.colorConfiguration.dateTimeLines

        dateLabel.textColor = configuration.colorConfiguration.dateTimeText
        dateLabel.font = configuration.fontConfiguration.dateTimeFont

        let toggler = UIButton(type: .custom)
        toggler.addTarget(self, action: #selector(togglePicker), for: .touchUpInside)

        let validate = UIButton(type: .system)
        validate.backgroundColor = UIColor.white
        validate.setImage(UIImage(named: "next-white"), for: .normal)
        validate.tintColor = configuration.colorConfiguration.selectionBackground
        validate.layer.cornerRadius = 15
        validate.imageEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        validate.addTarget(self, action: #selector(send), for: .touchUpInside)

        [container, topLine, dateLabel, toggler, validate]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        container.addSubview(topLine)
        container.addSubview(dateLabel)
        container.addSubview(toggler, withInsets: .zero)
        container.addSubview(validate)
        addSubview(container)

        NSLayoutConstraint.activate([
            topLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            topLine.topAnchor.constraint(equalTo: container.topAnchor),
            topLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            dateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            dateLabel.topAnchor.constraint(equalTo: container.topAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            dateLabel.heightAnchor.constraint(equalToConstant: YomCalendarHourPicker.dateHeight),
            validate.widthAnchor.constraint(equalToConstant: 30),
            validate.widthAnchor.constraint(equalTo: validate.heightAnchor),
            validate.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            validate.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

        if #available(iOS 11.0, *) {
            deployedDate = dateLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        } else {
            deployedDate = dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        }
        foldedDate = container.topAnchor.constraint(equalTo: bottomAnchor)
    }

    private func buildPicker() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = configuration.colorConfiguration.background
        container.clipsToBounds = true

        let topLine = UIView()
        topLine.backgroundColor = configuration.colorConfiguration.dateTimeLines
        topLine.translatesAutoresizingMaskIntoConstraints = false

        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(topLine)
        container.addSubview(picker)
        addSubview(container)
        NSLayoutConstraint.activate([
            topLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            topLine.topAnchor.constraint(equalTo: container.topAnchor),
            topLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            picker.heightAnchor.constraint(equalToConstant: 230),
            picker.widthAnchor.constraint(equalToConstant: 120),
            picker.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            picker.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)])

        deployedPicker = picker.bottomAnchor.constraint(equalTo: bottomAnchor)
        foldedPicker = container.topAnchor.constraint(equalTo: bottomAnchor)
        datePicker = container.topAnchor.constraint(equalTo: dateLabel.bottomAnchor)
    }

    private func tweakPicker(_ picker: UIPickerView) {
        guard let superview = picker.superview else { return }
        for view in picker.subviews {
            if view == picker.subviews.first { continue }
            view.isHidden = true

            let line = UIView()
            line.backgroundColor = configuration.colorConfiguration.dateTimeLines
            line.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(line)
            NSLayoutConstraint.activate([
                line.heightAnchor.constraint(equalTo: view.heightAnchor),
                line.topAnchor.constraint(equalTo: view.topAnchor),
                line.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: superview.trailingAnchor)])
        }
    }
}

extension YomCalendarHourPicker {
    func setPickerTime(date: Date, animated: Bool = true) {
        let hour = date.hours(calendar: configuration.localeConfiguration.calendar)
        let minute = date.minutes(calendar: configuration.localeConfiguration.calendar)

        picker.selectRow(hour, inComponent: 0, animated: animated)
        picker.selectRow(minute, inComponent: 1, animated: animated)
        picker.reloadAllComponents() // color in selection
    }

    func setDateDisplayed(date: Date) {
        let formatter = DateFormatter()
        formatter.calendar = configuration.localeConfiguration.calendar
        formatter.locale = configuration.localeConfiguration.locale

        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let day = formatter.string(from: date)

        let time: String
        if configuration.mode == .dateAndTime {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            time = formatter.string(from: date)
        } else {
            time = ""
        }

        let text = "\(day) \(time)"
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: time)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        dateLabel.attributedText = attributedString
        setPickerTime(date: date, animated: false)
    }

    @objc func send() {
        sendDate?(selectedDate)
    }
}

extension YomCalendarHourPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 24 : 60
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let lbl: UILabel
        if let label = view as? UILabel {
            lbl = label
        } else {
            lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
            lbl.font = configuration.fontConfiguration.pickerFont
            lbl.textAlignment = .center
        }

        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        lbl.text = formatter.string(from: row as NSNumber)
        lbl.textColor = configuration.colorConfiguration.dayText
        if pickerView.selectedRow(inComponent: component) == row {
            lbl.textColor = configuration.colorConfiguration.selectionBackground
        }

        return lbl
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(component)

        let hour = pickerView.selectedRow(inComponent: 0)
        let minute = pickerView.selectedRow(inComponent: 1)

        let truncated = selectedDate.truncated(from: .hour, calendar: configuration.localeConfiguration.calendar)!
        let date = truncated
            .adding(hour.hours, calendar: configuration.localeConfiguration.calendar)
            .adding(minute.minutes, calendar: configuration.localeConfiguration.calendar)

        selectedDate = capDate(date)
        setDateDisplayed(date: selectedDate)
        sendActions(for: .valueChanged)
    }
}
