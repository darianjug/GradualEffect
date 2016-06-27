//
//  ImageTransformationJob.swift
//  GradualEffect
//
//  Created by Darian Jug on 25/06/16.
//
//

import UIKit

public class ImageTransformationJob {
    /// Identifier of this job, it should be unique. Image name along with transformator name should be used. For example: "HelloWorldImage.jpg_blurring_12.0". This is used to insure that jobs can't be duplicated.
    let identifier: String
    
    /// Original image that is going to be transformed.
    let originalImage: UIImage
    
    /// Transformer that is going to be used to transform the original image.
    let transformer: ImageTransformer
    
    /// Optional completion block to be called on completing this job.
    let completionBlock: CompletionBlock?
    
    /// Current operation of this job execution, it's created when the job is added.
    var operation: NSOperation?
    
    /// Time interval when this job was started.
    var startedOn: NSTimeInterval?
    
    /// Time interval when this job was completed.
    var finishedOn: NSTimeInterval?
    
    init(identifier: String, originalImage: UIImage, transformer: ImageTransformer, completionBlock: CompletionBlock? = nil) {
        self.identifier         = identifier
        self.originalImage      = originalImage
        self.transformer        = transformer
        self.completionBlock    = completionBlock
    }
}