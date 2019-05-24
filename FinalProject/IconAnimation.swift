//
//  GlassView.swift
//  FinalProject
//
//  Created by Zholdas on 5/23/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

class IconAnimation: UIView {
    
    let liquidView = UIView()
    
    let shapeView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.gray
        self.liquidView.backgroundColor = UIColor.white
        
        self.shapeView.contentMode = .scaleAspectFit        
        self.addSubview(liquidView)
        self.mask = shapeView
        
        layoutIfNeeded()
        resetToTop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        liquidView.frame = CGRect(x: self.bounds.origin.x, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        shapeView.frame = self.bounds
    }
    
    func resetToTop() {
        liquidView.frame.origin.y = -self.bounds.height
    }
    func resetToBottom() {
        liquidView.frame.origin.y = 0
    }
    
    func animateTopToBottom() {
        resetToTop()
        UIView.animate(withDuration: 0.3) {
            self.liquidView.frame.origin.y = 0
        }
    }
    func animateBottomToTop() {
        resetToBottom()
        UIView.animate(withDuration: 0.3) {
            self.liquidView.frame.origin.y = -self.bounds.height
        }
    }
}

