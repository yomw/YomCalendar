//
//  YomCalendarView.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 17/05/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

class YomCalendarView: UIControl {
    private let dateCellIdentifier = "dateCellId"
    private let monthHeaderIdentifier = "monthHeaderId"

    private var fromDate = Date().dateAtStartOf(.month, calendar: Calendar.autoupdatingCurrent)
    private var toDate = Date().adding(10.years, calendar: Calendar.autoupdatingCurrent)

    var configuration = YomCalendar.Configuration.default {
        didSet { setupRange() }
    }

    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collection = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collection.backgroundColor = configuration.colorConfiguration.background
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(YomCalendarCell.self, forCellWithReuseIdentifier: dateCellIdentifier)
        collection.register(YomCalendarMonthHeader.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: monthHeaderIdentifier)
        return collection
        }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let cvl = UICollectionViewFlowLayout()
        cvl.headerReferenceSize = CGSize(width: bounds.width, height: 104)

        let spacing: CGFloat = 2
        let cellPerLine: CGFloat = 7
        let width = (bounds.width - spacing * (cellPerLine - 1)) / cellPerLine
        cvl.itemSize = CGSize(width: width, height: 44)
        cvl.minimumLineSpacing = spacing
        cvl.minimumInteritemSpacing = spacing
        return cvl
    }()

    func reloadData() {
        collectionView.reloadData()
    }

    private func setupRange() {
        fromDate = configuration.minimumDate.dateAtStartOf(.month, calendar: configuration.localeConfiguration.calendar)
        toDate = configuration.maximumDate.adding(1.month, calendar: configuration.localeConfiguration.calendar)
    }

    public var selectedDate: Date? {
        didSet {
            guard let selectedDate = selectedDate else { return }
            guard toDate.isAfterDate(selectedDate, granularity: .day,
                                     calendar: configuration.localeConfiguration.calendar) else { return }
            var paths: [IndexPath] = []
            if let old = oldValue {
                let path = indexPath(from: old)
                paths.append(path)
            }
            if oldValue?.compare(to: selectedDate, granularity: .day,
                                 calendar: configuration.localeConfiguration.calendar) != .orderedSame {
                let path = indexPath(from: selectedDate)
                paths.append(path)
            }

            let sanitizedPaths = paths.filter {
                $0.section < collectionView.numberOfSections
                    && $0.item < collectionView.numberOfItems(inSection: $0.section)
                }.compactMap { $0 }
            collectionView.reloadItems(at: sanitizedPaths)
        }
    }

    private func weekday(for date: Date) -> Int {
        let first = configuration.localeConfiguration.calendar.firstWeekday
        return (date.weekday(calendar: configuration.localeConfiguration.calendar) - first + 7) % 7
    }

    public func setDate(date: Date, animated: Bool) {
        selectedDate = date

        var indexPath = self.indexPath(from: date)
        if indexPath.section >= self.collectionView.numberOfSections {
            indexPath.section = self.collectionView.numberOfSections - 1
        }
        if indexPath.item >= self.collectionView.numberOfItems(inSection: indexPath.section) {
            indexPath.item = self.collectionView.numberOfItems(inSection: indexPath.section) - 1
        }

        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
    }

    private func indexPath(from date: Date) -> IndexPath {
        let section = self.section(for: date)
        let first = date.dateAtStartOf(.month, calendar: configuration.localeConfiguration.calendar)
        let item = date.days(calendar: configuration.localeConfiguration.calendar) + weekday(for: first) - 1
        return IndexPath(item: item, section: section)
    }

    private func date(from indexPath: IndexPath) -> Date {
        let first = fromDate.adding(indexPath.section.months, calendar: configuration.localeConfiguration.calendar)
        return first.adding((indexPath.row - weekday(for: first)).days,
                            calendar: configuration.localeConfiguration.calendar)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = bounds
        if collectionView.superview == nil {
            addSubview(collectionView)
        }
    }

    private func section(for date: Date) -> Int {
        guard date.isAfterDate(fromDate, granularity: .day, calendar: configuration.localeConfiguration.calendar)
            else { return 0 }
        let duration = date.componentsSince(fromDate, calendar: configuration.localeConfiguration.calendar,
                                            components: [.month, .year])
        let years = duration.year ?? 0
        let months = duration.month ?? 0
        return years * 12 + months
    }
}

// collection view
extension YomCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return section(for: toDate)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let first = fromDate.adding(section.months, calendar: configuration.localeConfiguration.calendar)
        return weekday(for: first) + first.daysInMonth(calendar: configuration.localeConfiguration.calendar)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard let cell: YomCalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellIdentifier,
                                                                             for: indexPath) as? YomCalendarCell
            else { fatalError("Could not find cell with identifier \(dateCellIdentifier)") }

        let cellDate = date(from: indexPath)
        let monthStart = fromDate.adding(indexPath.section.months, calendar: configuration.localeConfiguration.calendar)
        let isEmptyCell = cellDate.isBeforeDate(monthStart, granularity: .day,
                                                calendar: configuration.localeConfiguration.calendar)
        let today = cellDate.isToday(calendar: configuration.localeConfiguration.calendar)

        let isAfterMinimum = cellDate.isAfterDate(configuration.minimumDate, orEqual: true, granularity: .day,
                                                  calendar: configuration.localeConfiguration.calendar)
        let isBeforeMaximum = cellDate.isBeforeDate(configuration.maximumDate, orEqual: true, granularity: .day,
                                                    calendar: configuration.localeConfiguration.calendar)
        let enabled = !isEmptyCell
            && isAfterMinimum
            && isBeforeMaximum
        let selected = selectedDate?.compare(to: cellDate, granularity: .day,
                                             calendar: configuration.localeConfiguration.calendar) == .orderedSame

        cell.configuration = configuration
        cell.update(date: cellDate, enabled: enabled, out: isEmptyCell, today: today, selected: selected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else { fatalError("must never happen!!!") }

        guard let header: YomCalendarMonthHeader =
            collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                            withReuseIdentifier: monthHeaderIdentifier,
                                                            for: indexPath) as? YomCalendarMonthHeader
            else { fatalError("Could not find cell with identifier \(monthHeaderIdentifier)") }

        header.configuration = configuration
        header.textLabel.text = fromDate
            .adding(indexPath.section.months, calendar: configuration.localeConfiguration.calendar)
            .toFormat("LLLL yyyy", locale: configuration.localeConfiguration.locale,
                      calendar: configuration.localeConfiguration.calendar)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? YomCalendarCell
            else { fatalError("Could not find cell") }
        return cell.enabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? YomCalendarCell else {
            selectedDate = nil
            return
        }

        let now = Date()
        let minutes = now.hours(calendar: configuration.localeConfiguration.calendar) * 60
            + now.minutes(calendar: configuration.localeConfiguration.calendar)
        selectedDate = cell.date.adding(minutes.minutes, calendar: configuration.localeConfiguration.calendar)
        sendActions(for: .valueChanged)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sendActions(for: .editingDidEnd)
    }
}
