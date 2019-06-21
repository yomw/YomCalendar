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

    private var fromDate = CalendarDate().dateAtStartOf(.month)
    private var toDate = CalendarDate() + 10.years

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
        fromDate = configuration.minimumDate.dateAtStartOf(.month)
        toDate = configuration.maximumDate + 1.months
    }

    public var selectedDate: CalendarDate? {
        didSet {
            guard let selectedDate = selectedDate else { return }
            guard toDate.isAfterDate(selectedDate, granularity: .day) else { return }
            var paths: [IndexPath] = []
            if let old = oldValue {
                let path = indexPath(from: old)
                paths.append(path)
            }
            if oldValue?.compare(to: selectedDate, granularity: .day) != .orderedSame {
                let path = indexPath(from: selectedDate)
                paths.append(path)
            }
            collectionView.reloadItems(at: paths)
        }
    }

    private func weekday(for date: CalendarDate) -> Int {
        let first = configuration.staticConfiguration.calendar.firstWeekday
        return (date.weekday - first + 7) % 7
    }

    public func setDate(date: CalendarDate, animated: Bool) {
        selectedDate = date

        var indexPath = self.indexPath(from: date)
        if indexPath.section >= self.collectionView.numberOfSections {
            indexPath.section = self.collectionView.numberOfSections - 1
        }

        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
    }

    private func indexPath(from date: CalendarDate) -> IndexPath {
        let section = self.section(for: date)
        let first = date.dateAtStartOf(.month)
        return IndexPath(item: date.days + weekday(for: first) - 1, section: section)
    }

    private func date(from indexPath: IndexPath) -> CalendarDate {
        let first = fromDate + indexPath.section.months
        return first + (indexPath.row - weekday(for: first)).days
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = bounds
        if collectionView.superview == nil {
            addSubview(collectionView)
        }
    }

    private func section(for date: CalendarDate) -> Int {
        guard date.isAfterDate(fromDate, granularity: .day) else { return 0 }
        let duration = date.componentsSince(fromDate.date, components: [.month, .year])
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
        let first = fromDate + section.months
        return weekday(for: first) + first.daysInMonth
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard let cell: YomCalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellIdentifier,
                                                                             for: indexPath) as? YomCalendarCell
            else { fatalError("Could not find cell with identifier \(dateCellIdentifier)") }

        let cellDate = date(from: indexPath)

        let isEmptyCell = cellDate.isBeforeDate(fromDate + indexPath.section.months, granularity: .day)
        let today = cellDate.isToday()

        let enabled = !isEmptyCell
            && cellDate.isAfterDate(configuration.minimumDate, orEqual: true, granularity: .day)
            && cellDate.isBeforeDate(configuration.maximumDate, orEqual: true, granularity: .day)
        let selected = selectedDate?.compare(to: cellDate, granularity: .day) == .orderedSame

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
        header.textLabel.text = (fromDate + indexPath.section.months).toFormat("LLLL yyyy")

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

//        let now = DateInRegion(Date(), region: currentRegion)
        let now = CalendarDate(config: configuration.staticConfiguration)
        let minutes = now.hours * 60 + now.minutes
        selectedDate = cell.date + minutes.minutes
        sendActions(for: .valueChanged)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sendActions(for: .editingDidEnd)
    }
}
