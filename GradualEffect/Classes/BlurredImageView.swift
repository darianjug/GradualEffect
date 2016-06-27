//
//  BlurredImageView.swift
//  GradualEffect
//
//  Created by Darian Jug on 24/06/16.
//
//

import UIKit

public class BlurredImageView: UIView {
    public var delegate: ImageViewDelegate?
    
    public var image: UIImage? {
        didSet {
            if image != nil {
                processImage(image!)
            }
        }
    }
    
    /// A number from 0.0 to 1.0. Where 1.0 is where filter is at it's maximum, and 0.0 where the filter is a minimum value.
    public var effectStrength: CGFloat = 0.0 {
        didSet {
            setUpImagesForCurrentFilterStrength(effectStrength)
        }
    }
    
    /// The first stage always has 0 blur radius, the second stage is the one with the minimum blur radius.
    public var minimumBlurRadius          : CGFloat   = 5.0
    
    /// Maximal blur radius that is going to be used, the last stage.
    public var maximumBlurRadius          : CGFloat   = 15.0
    
    /// Number of stages used, the fewer the faster, the more transitions are smoother.
    public var numberOfStages             : Int       = 5
    
    /// Idenfitifer is randomly created upon creation of BlurredImageView, and is used for worker job queue names.
    public var identifier                   = NSUUID().UUIDString
    
    /// First image view. To give the user illusion of blazing fast progressive blurring two image views are used, using opacity and multiple images generated in stages/phases a smooth experience is given. Unfortunately it's static.
    private var firstImageView: UIImageView?

    /// Second image view. To give the user illusion of blazing fast progressive blurring two image views are used, using opacity and multiple images generated in stages/phases a smooth experience is given. Unfortunately it's static.
    private var secondImageView: UIImageView?
    
    /// Original image.
    private var originalImage: UIImage?     = nil
    
    /// Array of blurred images for each phase.
    private var processedImages: [UIImage?] = []
    
    /// Number of images processed.
    private var imagesProcessed: Int        = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        processedImages = [UIImage?] (count: numberOfStages + 2, repeatedValue: nil)
        
        // Initalize image views.
        self.firstImageView     = UIImageView(frame: bounds)
        self.secondImageView    = UIImageView(frame: bounds)
        
        self.firstImageView!.contentMode     = .ScaleAspectFill
        self.secondImageView!.contentMode    = .ScaleAspectFill
        
        self.addSubview(firstImageView!)
        self.addSubview(secondImageView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        processedImages = [UIImage?] (count: numberOfStages + 2, repeatedValue: nil)
        
        // Initalize image views.
        self.firstImageView     = UIImageView(frame: bounds)
        self.secondImageView    = UIImageView(frame: bounds)
        
        self.firstImageView!.contentMode     = .ScaleAspectFill
        self.secondImageView!.contentMode    = .ScaleAspectFill
        
        self.addSubview(firstImageView!)
        self.addSubview(secondImageView!)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.firstImageView!.frame   = bounds
        self.secondImageView!.frame  = bounds
    }
    
    public typealias ImageProcessingCompleteBlock = () -> ()
    
    public func processImage(image: UIImage, onImageProcessingComplete: ImageProcessingCompleteBlock? = nil) {
        // Initalize the array for processed images.
        processedImages = [UIImage?] (count: numberOfStages + 2, repeatedValue: nil)
        
        // If the strenght is 0, set the given original image, since the first stage is always the original image.
        if effectStrength == 0 {
            secondImageView!.image = image
        }
        
        // Cancel all jobs in the shared worker for this image view.
        Worker.sharedInstance.cancelQueueJobs(identifier)
        
        self.imagesProcessed    = 0
        self.originalImage      = image
        self.processedImages[0] = image
        
        let range = 1...numberOfStages
        
        // Generate all image transformation jobs.
        let jobs: [ImageTransformationJob] = range.map({ i in
            let percentageOfStage = CGFloat(i) / CGFloat(self.numberOfStages)
            
            // Formula for calculating blur radius is, where a is percentage of stage number/number of stages (I/Imax): easingFunction(a) * (max - min) + min
            let blurRadius: CGFloat = self.blurEasingFunction(percentageOfStage) * (self.maximumBlurRadius - self.minimumBlurRadius) + self.minimumBlurRadius
            
            let transformer = iOSBlurImageTransformer(blurRadiusInPixels: blurRadius)
            
            // Generate the job. We're using the image hash value as the job identifier.
            let job = ImageTransformationJob(identifier: String("\(image.hashValue)_stage\(i)"),
                originalImage   : image,
                transformer     : transformer,
                completionBlock: { (processedImageForStage) in
                    // Add the processed image to processed images.
                    self.processedImages[i]     = processedImageForStage
                    self.imagesProcessed       += 1
                    
                    // The last stage is the same as the the one before it.
                    if i == self.numberOfStages {
                        self.processedImages[i + 1] = processedImageForStage
                        self.imagesProcessed       += 1
                    }
                    
                    self.setUpImagesForCurrentFilterStrength()
            })
            
            return job
        })
        
        Worker.sharedInstance.addJobs(identifier, jobs: jobs, completionBlock: { (image) in
            // Call the ImageProcessingCompleteBlock.
            onImageProcessingComplete?()
        })
    }
    
    // Inputs X [0, 1] => [0, 1] for easing blurring.
    // Ease in out quad: acceleration until halfway, then deceleration.
    func easeInOutQuadEasingFunction(x: CGFloat) -> CGFloat {
        return x < 0.5 ? 2*x*x : -1+(4-2*x)*x
    }
    
    // We're using quad easing function.
    func blurEasingFunction(x: CGFloat) -> CGFloat {
        return easeInOutQuadEasingFunction(x)
    }
    
    func setUpImagesForCurrentFilterStrength() {
        setUpImagesForCurrentFilterStrength(effectStrength)
    }
    
    func setUpImagesForCurrentFilterStrength(strenght: CGFloat) {
        let effect: CGFloat   = strenght * CGFloat(numberOfStages)
        let effectIndex: Int  = Int(effect)
        let effectRemainder   = effect - CGFloat(effectIndex)
        
        let firstImage      = processedImages[effectIndex]
        let secondImage     = processedImages[effectIndex + 1]
        
        if firstImage != nil {
            firstImageView!.image = firstImage
        } else {
            delegate?.imageViewEncounteredMissingProcessedImage()
        }
        
        if secondImage != nil {
            secondImageView!.image = processedImages[effectIndex + 1]
            secondImageView!.alpha = CGFloat(effectRemainder)
        } else {
            delegate?.imageViewEncounteredMissingProcessedImage()
        }
        
    }
}
