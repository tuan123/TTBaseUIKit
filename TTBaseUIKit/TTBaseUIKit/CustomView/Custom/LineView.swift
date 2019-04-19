//
//  LineView.swift
//  TTBaseUIKit
//
//  Created by Truong Quang Tuan on 4/15/19.
//  Copyright © 2019 Truong Quang Tuan. All rights reserved.
//

import Foundation

open class TTLineView: TTBaseUIView {
    
    var bgColor:UIColor = TTBaseUIKitConfig.getViewConfig().lineColor
    
    override open func updateUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewDefBgColor = bgColor
        self.drawView()
    }
    
}

extension TTLineView {
    public func setLineColor(_ color:UIColor) {
        self.setBgColor(color)
    }
}