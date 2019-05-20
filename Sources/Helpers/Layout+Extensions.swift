//
//  LayoutExtensions.swift
//  timejump
//
//  Created by Guillaume Bellue on 31/08/2018.
//  Copyright © 2018 DVMobile. All rights reserved.
//

import UIKit

extension UIView {
    public func addSubview(_ view: UIView, withInsets insets: UIEdgeInsets) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
            ])
    }
}

extension NSLayoutAnchor {
    @objc public func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>,
                                 constant: CGFloat = 0,
                                 priority: UILayoutPriority) -> NSLayoutConstraint {
        let const = constraint(equalTo: anchor, constant: constant)
        const.priority = priority
        return const
    }
}

extension NSLayoutDimension {
    @objc public func constraint(equalToConstant constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
        let const = constraint(equalToConstant: constant)
        const.priority = priority
        return const
    }
}
