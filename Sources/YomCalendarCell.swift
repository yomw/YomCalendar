//
//  YomCalendarCell.swift
//  YomCalendar
//
//  Created by Guillaume Bellue on 17 mai 2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import SwiftDate
import UIKit

class YomCalendarCell: UICollectionViewCell {
    private(set) var date = Date()
    private(set) var enabled: Bool = true
    private var label: UILabel = UILabel()
    private var selectView: UIView?

    override init(frame: CGRect) {

        super.init(frame: frame)

        label.frame = self.contentView.bounds
        label.font = Font.defaultFont(withSize: 16)
        label.textColor = UIColor.white
        label.highlightedTextColor = Colors.purple
        label.textAlignment = .center
        self.contentView.addSubview(label)
        label.layer.shouldRasterize = true

        self.backgroundColor = Colors.Background.base
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

            var textColor = enabled ? Colors.Text.base : Colors.Text.disabled

            label.text = "\(self.date.day)"

            if selected || today {
                var size = self.bounds.width < self.bounds.height ? self.bounds.width : self.bounds.height
                size -= 2

                let subview = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
                if selected {
                    subview.backgroundColor = Colors.purple
                    subview.layer.cornerRadius = size / 2
                    textColor = Colors.Text.selected
                } else {
                    subview.backgroundColor = self.backgroundColor
                    subview.layer.cornerRadius = size / 2
                    subview.layer.borderColor = Colors.purple.cgColor
                    subview.layer.borderWidth = 2
                }
                subview.center = label.center
                self.contentView.insertSubview(subview, belowSubview: label)
                selectView = subview
            }

            label.textColor = textColor
        }
    }
}
