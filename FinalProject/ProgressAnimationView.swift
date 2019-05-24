//
//  ProgressView.swift
//  FinalProject
//
//  Created by Zholdas on 5/2/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit
import CoreData

class ProgressAnimationView: UIView{
    
    var bgPath: UIBezierPath!
    var progressLayer: CAShapeLayer!
    let rotateAnimationKey = "rotation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgPath = UIBezierPath()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        simpleShape()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(_ progress: Float) {
        if progress <= 0{
            self.stopRotating()
        }
                
        if progress <= 1.0{
            self.progressLayer.strokeStart = 0.17
            self.progressLayer.strokeEnd = 0.17 + CGFloat(progress)
        }
    }
    
    func startCurvedCircleAnimation() {

        let duration: Float = 100
        var counter: Float = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            DispatchQueue.main.async {
                let progres = counter/duration
                if counter <= 17 {
                    if progres <= 0.17{
                        self.progressLayer.strokeEnd = CGFloat(progres)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07, execute: {
                        if progres <= 0.16{
                            self.progressLayer.strokeStart = CGFloat(progres)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                self.startRotating()
                            })
                        }
                    })
                    counter += 1
                } else {
                    timer.invalidate()
                }
            }
        }
        timer.fire()
    }
    
    func simpleShape() {
        createCirclePath()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        progressLayer = CAShapeLayer()
        progressLayer.path = bgPath.cgPath
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.lineWidth = 2.5
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.gray.cgColor
        progressLayer.strokeEnd = 0.0
        progressLayer.position = center
        
        self.layer.addSublayer(progressLayer)
    }
    
    private func createCirclePath() {
        let points = getCirclePoints(centerPoint: CGPoint.zero, radius: center.x/8, n: 12)

        bgPath.move(to: CGPoint.zero)
        bgPath.addCurve(to: points[4], controlPoint1: CGPoint(x: 0.0, y: points[4].y-(points[4].y)/4), controlPoint2: CGPoint(x: 0.0, y: points[4].y))

        bgPath.addArc(withCenter: CGPoint.zero, radius: center.x/8, startAngle: CGFloat(Double.pi / 2 + 0.5), endAngle: CGFloat(Double.pi * 2.5 + 0.5), clockwise: true)
    }
    
    
    
    func startRotating() {
        if self.progressLayer.animation(forKey: rotateAnimationKey) == nil {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.duration = 2
            rotateAnimation.repeatCount = Float.infinity
            rotateAnimation.fromValue = 0
            rotateAnimation.toValue = Float(Double.pi * 2)
            rotateAnimation.repeatCount = Float(TimeInterval.infinity)
            self.progressLayer.add(rotateAnimation, forKey: rotateAnimationKey)
        }
    }
    func stopRotating() {
        if self.progressLayer.animation(forKey: rotateAnimationKey) != nil {
            self.progressLayer.removeAnimation(forKey: rotateAnimationKey)
        }
    }
    
    func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int)->[CGPoint] {
        let result: [CGPoint] = stride(from: 0.0, to: 360.0, by: Double(360 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result
    }

}
