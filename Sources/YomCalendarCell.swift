//
//  YomCalendarCell.swift
//  YomCalendar
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

class YomCalendarCell: UICollectionViewCell {
    private(set) var date = Date()
    private(set) var enabled: Bool = true
    private var label: UILabel = UILabel()
    private var selectView: UIView?

    var configuration = YomCalendar.Configuration.default

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.frame = self.contentView.bounds
        label.font = configuration.fontConfiguration.dayFont
        label.textColor = UIColor.white
        label.highlightedTextColor = configuration.colorConfiguration.selectionBackground
        label.textAlignment = .center
        self.contentView.addSubview(label)
        label.layer.shouldRasterize = true

        self.backgroundColor = configuration.colorConfiguration.background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update (date: Date, enabled: Bool, out: Bool, today: Bool, selected: Bool) {
        self.date = date
        self.enabled = enabled

        UIView.performWithoutAnimation {
            selectView?.removeFromSuperview()
            selectView = nil
            label.isHighlighted = today && !selected

            label.isHidden = out
            if out {
                return
            }

            var textColor = enabled ? configuration.colorConfiguration.dayText
                                    : configuration.colorConfiguration.disabledText

            var font = enabled ? configuration.fontConfiguration.dayFont
                               : configuration.fontConfiguration.disabledFont

            label.text = date.toFormat("dd",
                                       locale: configuration.localeConfiguration.locale,
                                       calendar: configuration.localeConfiguration.calendar)

            if selected || today {
                var size = self.bounds.width < self.bounds.height ? self.bounds.width : self.bounds.height
                size -= 2

                let subview = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                if selected {
                    subview.backgroundColor = configuration.colorConfiguration.selectionBackground
                    subview.layer.cornerRadius = size / 2

                    textColor = configuration.colorConfiguration.selectionText
                    font = configuration.fontConfiguration.selectedFont
                } else { // today
                    subview.backgroundColor = self.backgroundColor
                    subview.layer.cornerRadius = size / 2
                    subview.layer.borderColor = configuration.colorConfiguration.selectionBackground.cgColor
                    subview.layer.borderWidth = 2

                    textColor = configuration.colorConfiguration.todayText
                    font = configuration.fontConfiguration.todayFont
                }
                subview.center = label.center
                self.contentView.insertSubview(subview, belowSubview: label)
                selectView = subview
            }

            label.textColor = textColor
            label.font = font
        }
    }
}
