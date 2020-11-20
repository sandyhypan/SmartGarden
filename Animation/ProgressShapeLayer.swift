//
//  ProgressShapeLayer.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
//  ref: https://medium.com/better-programming/lets-build-a-circular-loading-indicator-in-swift-5-b06fcdf1260d

import UIKit

class ProgressShapeLayer: CAShapeLayer {
    
    public init(strokeColor: UIColor, lineWidth: CGFloat){
        super.init()
        
        // The color of the path
        self.strokeColor = strokeColor.cgColor
        // The width of the path
        self.lineWidth = lineWidth
        // The color of the area that the circular path encloses
        self.fillColor = UIColor.clear.cgColor
        // Set the cap to round
        self.lineCap = .round
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
