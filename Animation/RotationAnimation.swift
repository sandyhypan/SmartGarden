//
//  RotationAnimation.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
// ref: https://medium.com/better-programming/lets-build-a-circular-loading-indicator-in-swift-5-b06fcdf1260d

import UIKit

class RotationAnimation: CABasicAnimation {
    
    enum Direction: String {
        case x, y, z
    }
    
    override init(){
        super.init()
    }
    
    public init(direction: Direction, fromValue: CGFloat, toValue: CGFloat, duration: Double, repeatCount: Float) {
        super.init()
        
        self.keyPath = "transform.rotation.\(direction.rawValue)"
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.repeatCount = repeatCount
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
