//
//  GradientView.swift
//  IBDesignables
//
//  Created by Guillaume Bellue on 29/03/2018.
//  Copyright © 2018 DVMobile. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientView: UIView {
    @IBInspectable open var startColor: UIColor = .black { didSet { updateColors() } }
    @IBInspectable open var endColor: UIColor = .white { didSet { updateColors() } }
    @IBInspectable open var startLocation: Double = 0.05 { didSet { updateLocations() } }
    @IBInspectable open var endLocation: Double = 0.95 { didSet { updateLocations() } }
    @IBInspectable open var horizontalMode: Bool = false { didSet { updatePoints() } }
    @IBInspectable open var diagonalMode: Bool = false { didSet { updatePoints() } }

    override open class var layerClass: AnyClass { return CAGradientLayer.self }

    var gradientLayer: CAGradientLayer? { return layer as? CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer?.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer?.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer?.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer?.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer?.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer?.colors    = [startColor.cgColor, endColor.cgColor]
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
