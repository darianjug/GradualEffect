//
//  ImageViewDelegate.swift
//  GradualEffect
//
//  Created by Darian Jug on 25/06/16.
//
//

import UIKit

/// ImageView delegte
public protocol ImageViewDelegate {
    /// This is being call when image view encounters a missing processed image for current stage. Processed images will be missing during image proccesing.
    func imageViewEncounteredMissingProcessedImage()
}