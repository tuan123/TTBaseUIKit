//
//  UIView+Config.swift
//  TTBaseUIKit
//
//  Created by Truong Quang Tuan on 4/8/19.
//  Copyright © 2019 Truong Quang Tuan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func done(_ completion: (() -> Void)? = nil) {
        completion?()
    }

    public func setConerRadius(with radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat = TTBaseUIKitConfig.getSizeConfig().CORNER_RADIUS) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    public func setBgImageView(withImage image:UIImage?) {
        let backgroundImage = TTBaseUIImageView()
        backgroundImage.isUserInteractionEnabled = false
        backgroundImage.image = image
        self.insertSubview(backgroundImage, at: 0)
        backgroundImage.setFullContraints(view: self, constant: 0)
    }
    
    public func addBorder(borderColor:UIColor = UIColor.white, borderHeight:CGFloat = 1) {
        self.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: borderHeight)
        self.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: borderHeight)
        self.layer.addBorder(edge: UIRectEdge.top, color: borderColor, thickness: borderHeight)
        self.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor, thickness: borderHeight)
    }
    
    public func addBorder(withRectEdge rectEdge:UIRectEdge, borderColor:UIColor = UIColor.white, borderHeight:CGFloat = 1) {
        self.layer.sublayers?.filter({$0.name == "BORDER." + rectEdge.rawValue.description}).forEach({$0.removeFromSuperlayer()})
        self.layer.addBorder(edge: rectEdge, color: borderColor, thickness: borderHeight)
    }
    
    public func shakeAnimation(x _x: CGFloat, y _y:CGFloat, duration _duration:CFTimeInterval) {
        let keyFrame = CAKeyframeAnimation(keyPath: "position")
        
        let point = self.layer.position
        keyFrame.values = [NSValue(cgPoint: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - _x), y: CGFloat(point.y - _y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + _x), y: CGFloat(point.y + _y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - _x), y: CGFloat(point.y - _y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + _x), y: CGFloat(point.y + _y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - _x), y: CGFloat(point.y - _y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + _x), y: CGFloat(point.y + _y))),
                           NSValue(cgPoint: point)]
        
        keyFrame.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        keyFrame.duration = _duration
        self.layer.position = point
        self.layer.add(keyFrame, forKey: keyFrame.keyPath)
    }
    
    public func setAutoresizingMaskIntoConstraints() -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    /// Returns the first constraint with the given identifier, if available.
    ///
    /// - Parameter identifier: The constraint identifier.
    public func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        return self.constraints.filter({$0.identifier == identifier}).first
    }
    
    public func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
    
    public static func getGradientSkeletonLayer() -> CALayer {
        
        let startLocations : [NSNumber] = [-1.0,-0.5, 0.0]
        let endLocations : [NSNumber] = [1.0,1.5, 2.0]
        let gradientBackgroundColor : CGColor = TTView.viewBgGradientSkeleton.cgColor
        let gradientMovingColor : CGColor = TTView.viewBgGradientMoveSkeleton.cgColor
        
        let movingAnimationDuration : CFTimeInterval = 0.8
        let delayBetweenAnimationLoops : CFTimeInterval = 1.0
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.zPosition = CONSTANT.POSITION_VIEW.SKELETON_LAYER.rawValue
        gradientLayer.frame = CGRect.init(x: -4, y: 0, width: TTSize.W + 8, height: TTSize.H_CELL)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [ gradientBackgroundColor, gradientMovingColor, gradientBackgroundColor ]
        gradientLayer.locations = startLocations
        gradientLayer.name = "SkeletonAnimating"
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = startLocations
        animation.toValue = endLocations
        animation.duration = movingAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = movingAnimationDuration + delayBetweenAnimationLoops
        animationGroup.animations = [animation]
        animationGroup.repeatCount = .infinity
        gradientLayer.add(animationGroup, forKey: animation.keyPath)
        return gradientLayer
    }
    
    
    public func onStartSkeletonCustomViewAnimation() {
        if !(self.layer.sublayers?.filter({$0.name == "SkeletonAnimating"}) ?? []).isEmpty { return }
        self.clipsToBounds = true
        self.layer.addSublayer(UIView.getGradientSkeletonLayer())
        let views = self.subviewsRecursive()
        for view in views {
            view.backgroundColor = TTView.viewBgSkeleton
            if let lb = view as? TTBaseUILabel {lb.textColor = TTView.viewBgSkeleton}
            if let img = view as? TTBaseUIImageView {img.setAnimalForSkeletonView()}
        }
    }
    
    public func onStopSkeletonCustomViewAnimation() {
        self.layer.sublayers?.filter({$0.name == "SkeletonAnimating"}).first?.removeFromSuperlayer()
        let views = self.subviewsRecursive()
        for view in views {
            if let view = view as? TTBaseUIView {
                view.backgroundColor = view.viewDefBgColor
            } else if let lb = view as? TTBaseUILabel {
                lb.textColor = lb.textDefColor
                lb.backgroundColor = lb.viewDefBgColor
            } else if let img = view as? TTBaseUIImageView {
               img.backgroundColor = img.viewDefBgColor
              img.setRollBackViewForSkeletonAnimal()
            } else {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    
//    public func startSkeletonAnimating() {
//        if (self.layer.sublayers?.filter({$0.name == "SkeletonAnimating"}).isEmpty ?? false) {
//            self.layer.addSublayer(self.getGradientSkeletonLayer())
//        } else {
//            return
//        }
//    }
//    
//    public func stopSkeletonAnimating() {
//        self.layer.sublayers?.filter({$0.name == "SkeletonAnimating"}).forEach({$0.removeFromSuperlayer()})
//    }

}
