//
//  ImageTransformationOperation.swift
//  Pods
//
//  Created by Darian Jug on 26/06/16.
//
//

import Foundation

class ImageTransformationOperation: Operation {
    let job: ImageTransformationJob
    let imageFinishedProcessing: CompletionBlock?
    
    init(job: ImageTransformationJob, imageFinishedProcessing: CompletionBlock? = nil) {
        self.job                        = job
        self.imageFinishedProcessing    = imageFinishedProcessing
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        
        print("Job '\(job.identifier)' operation started")
        
        job.startedOn = self.getCurrentTime()
        
        job.transformer.transform(originalImage: job.originalImage, completionBlock: { (resultImage) in
            // Note the finish time, so we can calculate the duration of the operation.
            self.job.finishedOn = self.getCurrentTime()
            
            if self.isCancelled {
                return
            }
            
            print("Job '\(self.job.identifier)' operation finished")

            // Handle all completions on the main queue.
            DispatchQueue.main.async {
                self.imageFinishedProcessing?(resultImage)
                self.job.completionBlock?(resultImage)
            }
        })
    }
    
    /// Returns the current time, this is used to calculate the duration of each job upon completion.
    private func getCurrentTime() -> TimeInterval {
        // NSDate related methods for getting time are slow, so CoreAnimation ones are prefered.
        return CACurrentMediaTime()
    }
}
