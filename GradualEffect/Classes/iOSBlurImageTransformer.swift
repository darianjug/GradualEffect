//
//  iOSBlurImageTransformer.swift
//  GradualEffect
//
//  Created by Darian Jug on 25/06/16.
//
//

import UIKit

import GPUImage

/// Transforms image to match iOS frosted glass blur introduced in iOS 7.0.
public class iOSBlurImageTransformer: ImageTransformer {
    /// A radius in pixels to use for the blur, with a default of 12.0. This adjusts the sigma variable in the Gaussian distribution function.
    public var blurRadiusInPixels: CGFloat     = 12.0
    
    /// Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 0.8 as the normal level.
    public var saturation: CGFloat             = 0.8
    
    /// The degree to which to downsample, then upsample the incoming image to minimize computations within the Gaussian blur, default of 4.0.
    public var downsampling: CGFloat           = 4.0
    
    /// The degree to reduce the luminance range, from 0.0 to 1.0. Default is 0.6.
    public var rangeReductionFactor: CGFloat   = 0.6
    
    init(blurRadiusInPixels: CGFloat) {
        self.blurRadiusInPixels = blurRadiusInPixels
    }
    
    public func transform(originalImage: UIImage, completionBlock: CompletionBlock) {
        let stillImageSource: GPUImagePicture = GPUImagePicture(image: originalImage)
    
        let stillImageFilter = GPUImageiOSBlurFilter()
        
        // GPUImageFilter parameters.
        stillImageFilter.blurRadiusInPixels     = blurRadiusInPixels
        stillImageFilter.saturation             = saturation
        stillImageFilter.downsampling           = downsampling
        stillImageFilter.rangeReductionFactor   = rangeReductionFactor
        
        stillImageSource.addTarget(stillImageFilter)
        stillImageFilter.useNextFrameForImageCapture()
        stillImageSource.processImage()
        
        stillImageFilter.frameProcessingCompletionBlock = { (imageOutput, coreMediaTime) in
            let currentFilteredVideoFrame: UIImage = imageOutput.imageFromCurrentFramebuffer()
            
            // Call the completion block with the transformed image.
            completionBlock(currentFilteredVideoFrame)
        }
    }
}