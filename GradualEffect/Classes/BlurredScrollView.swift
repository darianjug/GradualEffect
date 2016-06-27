//
//  BlurringScrollView.swift
//  Pods
//
//  Created by Darian Jug on 26/06/16.
//
//

import Foundation

public class BlurringScrollView: UIScrollView, UIScrollViewDelegate {
    public var imageView: BlurredImageView?
    
    override public var contentOffset: CGPoint {
        didSet {
            if imageView != nil {
                setBackgroundBlurForContentOffset(contentOffset)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = BlurredImageView(frame: bounds)
        imageView?.backgroundColor = UIColor.redColor()
        addSubview(imageView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = BlurredImageView()
        imageView?.backgroundColor = UIColor.redColor()
        addSubview(imageView!)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        imageView!.frame = bounds
    }
    
    func setBackgroundBlurForCurrentContentOffset() {
        setBackgroundBlurForContentOffset(contentOffset)
    }

    func setBackgroundBlurForContentOffset(contentOffset: CGPoint) {
        if imageView != nil {
            let r   : CGFloat           = contentOffset.y / (contentSize.height * 0.4)
            let traveledPath            = max(0, min(1, r))
            imageView!.effectStrength    = traveledPath
        }
    }
}