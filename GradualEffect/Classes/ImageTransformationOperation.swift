//
//  ImageTransformationOperation.swift
//  Pods
//
//  Created by Darian Jug on 26/06/16.
//
//

import Foundation

class ImageTransformationOperation: NSOperation {
    let job: ImageTransformationJob
    let imageFinishedProcessing: CompletionBlock?
    
    init(job: ImageTransformationJob, imageFinishedProcessing: CompletionBlock? = nil) {
        self.job                        = job
        self.imageFinishedProcessing    = imageFinishedProcessing
    }
    
    override func main () {
        if self.cancelled {
            return
        }
        
        print("Job '\(job.identifier)' operation started")
        
        job.startedOn = self.getCurrentTime()
        
        job.transformer.transform(job.originalImage, completionBlock: { (resultImage) in
            // Note the finish time, so we can calculate the duration of the operation.
            self.job.finishedOn = self.getCurrentTime()
            
            if self.cancelled {
                return
            }
            
            print("Job '\(self.job.identifier)' operation finished")
            
            // Handle all completions on the main queue.
            dispatch_async(dispatch_get_main_queue(), {
                self.imageFinishedProcessing?(resultImage)
                self.job.completionBlock?(resultImage)
            })
        })
    }
    
    /// Returns the current time, this is used to calculate the duration of each job upon completion.
    private func getCurrentTime() -> NSTimeInterval {
        // NSDate related methods for getting time are slow, so CoreAnimation ones are prefered.
        return CACurrentMediaTime()
    }
}