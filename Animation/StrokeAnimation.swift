//
//  StrokeAnimation.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
// ref: https://medium.com/better-programming/lets-build-a-circular-loading-indicator-in-swift-5-b06fcdf1260d

import UIKit

class StrokeAnimation: CABasicAnimation {
    
    enum StrokeType {
        case start
        case end
    }
    
    override init(){
        super.init()
    }
    
    init(type: StrokeType, beginTime: Double = 0.0, fromValue: CGFloat, toValue: CGFloat, duration: Double){
        super.init()
        
        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"
        
        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
