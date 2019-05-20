//
//  YomCalendarView.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 17/05/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import SwiftDate
import UIKit

let currentRegion = Region(calendar: Calendars.gregorian,
                           zone: TimeZone.autoupdatingCurrent,
                           locale: Locale.autoupdatingCurrent)

class YomCalendarView: UIControl {
    private let dateCellIdentifier = "dateCellId"
    private let monthHeaderIdentifier = "monthHeaderId"

    private var fromDate: Date
    private var toDate: Date

    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collection = UICollectionView(frame: self.bounds, collectionViewLayout: self.collectionViewLayout)
        collection.backgroundColor = Colors.Background.base
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(YomCalendarCell.self, forCellWithReuseIdentifier: dateCellIdentifier)
        collection.register(YomCalendarMonthHeader.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: monthHeaderIdentifier)
        collection.reloadData()
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

    private var fixedNow: Date {
        let todayString = Date().convertTo(region: currentRegion).toFormat("yyyy-MM-dd HH:mm:ss")
        return todayString.toDate()?.date ?? Date()
    }

    override init(frame: CGRect) {
        fromDate = Date().dateAtStartOf(.month)
        toDate = fromDate + 24.years + 1.months
        super.init(frame: frame)
        selectedDate = fixedNow
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var selectedDate: Date? {
        didSet {
            guard let selectedDate = selectedDate else { return }
            guard toDate.date.isAfterDate(selectedDate, granularity: .day) else { return }
            var paths: [IndexPath] = []
            if let old = oldValue {
                let path = indexPath(from: old)
                paths.append(path)
            }
            if oldValue?.compare(toDate: selectedDate, granularity: .day) != .orderedSame {
                let path = indexPath(from: selectedDate)
                paths.append(path)
            }
            collectionView.reloadItems(at: paths)
        }
    }

    private func weekday(for date: Date) -> Int {
        return (date.weekday - 2 + 7) % 7
    }

    public func setDate(date: Date) {
        selectedDate = date

        var indexPath = self.indexPath(from: date)
        if indexPath.section >= self.collectionView.numberOfSections {
            indexPath.section = self.collectionView.numberOfSections - 1
        }

        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }

    private func indexPath(from date: Date) -> IndexPath {
        let section = self.section(for: date)
        let first = date.dateAtStartOf(.month)
        return IndexPath(item: date.day + weekday(for: first) - 1, section: section)
    }

    private func date(from indexPath: IndexPath) -> Date {
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

    private func section(for date: Date) -> Int {
        guard date.isAfterDate(fromDate, granularity: .day) else { return 0 }
        let duration = date.inDefaultRegion().componentsSince(fromDate.inDefaultRegion(), components: [.month, .year])
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
        return weekday(for: first) + first.monthDays
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard let cell: YomCalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellIdentifier,
                                                                             for: indexPath)
            as? YomCalendarCell
            else { fatalError("Could not find cell with identifier \(dateCellIdentifier)") }

        let cellDate = date(from: indexPath)

        let isEmptyCell = cellDate.isBeforeDate(fromDate + indexPath.section.months, granularity: .day)
        let today = cellDate.compare(.isSameDay(fixedNow))

        let enabled = !isEmptyCell
            && cellDate.isAfterDate(fixedNow, orEqual: true, granularity: .day)
            && cellDate.isBeforeDate(fixedNow + 24.years, orEqual: true, granularity: .day)
        let selected = selectedDate?.compare(toDate: cellDate, granularity: .day) == .orderedSame

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

        let now = DateInRegion(Date(), region: currentRegion)
        let minutes = now.hour * 60 + now.minute
        selectedDate = cell.date + minutes.minutes
        sendActions(for: .valueChanged)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sendActions(for: .editingDidEnd)
    }
}
