//
//  StrokeColorAnimation.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
// ref: https://medium.com/better-programming/lets-build-a-circular-loading-indicator-in-swift-5-b06fcdf1260d

import UIKit

class StrokeColorAnimation: CAKeyframeAnimation {
    
    override init() {
        super.init()
    }
    
    init(colors: [CGColor], duration: Double){
        super.init()
        
        self.keyPath = "strokeColor"
        self.values = colors
        self.duration = duration
        self.repeatCount = .greatestFiniteMagnitude
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
