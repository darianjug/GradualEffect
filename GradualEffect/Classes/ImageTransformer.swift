//
//  ImageTransformer.swift
//  GradualEffect
//
//  Created by Darian Jug on 25/06/16.
//
//

import UIKit

/// Encapsulates logic that is used to transform images. Can be used to resize or apply effects to an image.
public protocol ImageTransformer {    
    /**
        Accepts an image, transforms it and returns it using the given completion block.
     
        - Parameters:
            - originalImage: Image that needs to be transformed.
            - completionBlock: Block that is going to be called with the transfomed image when the transformation is completed.
    */
    func transform(originalImage: UIImage, completionBlock: CompletionBlock)
}