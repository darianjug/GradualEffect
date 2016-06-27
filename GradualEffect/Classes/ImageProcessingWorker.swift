//
//  Worker.swift
//  GradualEffect
//
//  Created by Darian Jug on 25/06/16.
//
//

public class Worker: NSObject {
    /// Shared instance is useful for app-wide image transformation worker.
    public static let sharedInstance = Worker()
    
    typealias JobQueue  = [String: ImageTransformationJob]
    typealias JobQueues = [String: JobQueue]
    
    /// This contains all the queues with all jobs.
    var jobQueues: JobQueues = [:]
    
    /// Operation queue is used to process image transformation operations.
    private var operationQueue: NSOperationQueue = NSOperationQueue()
    
    override init() {
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    //
    // MARK: - Job manipulation
    //
    
    /// Adds the job to the queue, and assigns an operation to the job. CompletionBlock will be called on completion of this job.
    public func addJob(queueKey        : String,
                job             : ImageTransformationJob,
                completionBlock : CompletionBlock?          = nil) {
        // Get all jobs running for that key as an array.
        var jobsForKey = getOrCreateJobQueueForKey(queueKey)
        
        // Create an NSOperation and assign it to the job.
        let operation = ImageTransformationOperation(job: job, imageFinishedProcessing: { (resultImage) in
            completionBlock?(resultImage)
            self.jobFinishedWithImage(queueKey, job: job, resultImage: resultImage)
        })
        
        // Assign the exsisting operation to the job.
        job.operation = operation
        
        // Add operation to the queue.
        operationQueue.addOperation(operation)
        
        // Log the job completion.
        print("Job '\(job.identifier)' added to queue '\(queueKey)'")
        
        // Add job to list of jobs with that key.
        addJobToJobQueue(queueKey, job: job)
    }
    
    public func addJobs(key             : String,
                        jobs            : [ImageTransformationJob],
                        completionBlock : QueueCompletionBlock?        = nil) {
        // Add each job.
        jobs.forEach { (job) in
            addJob(key, job: job, completionBlock: { image in
                // If all jobs are finished call.
                if self.isJobQueueEmpty(key) {
                    // All jobs in a queue are finished.
                    completionBlock?()
                }
            })
        }
    }
    
    /// Cancels all jobs from the queue with the queueKey name, and removes them from the queue.
    public func cancelQueueJobs(queueKey: String) {
        print("Canceling all jobs in job queue '\(queueKey)'")
        
        if let jobQueue = jobQueues[queueKey] {
            jobQueue.forEach({ (key, job) in
                print("Canceled job '\(key)'")
                
                // Cancel the job.
                job.operation?.cancel()
                
                // Remove it from the queue.
                removeJobFromQueue(queueKey, job: job)
            })
        }
    }
    
    //
    // MARK: - Private methods
    //
    
    /// Method called upon job completion. The job is here removed from the queue.
    private func jobFinishedWithImage(queueKey: String, job: ImageTransformationJob, resultImage: UIImage?) {
        // Time it took to complete the job.
        let operationDuration: NSTimeInterval = job.finishedOn! - job.startedOn!
        
        print("Job '\(job.identifier)' finished in \(operationDuration)ms")
        
        removeJobFromQueue(queueKey, job: job)
    }
    
    /**
        Removes the given job from the queue.
 
        - Parameters:
            - queueKey: Name, key of the queue.
            - job:      Job that needs to be removed.
     
        - Returns: If job was removed, if it even existed.
    */
    private func removeJobFromQueue(queueKey: String, job: ImageTransformationJob) -> Bool {
        if var jobQueue = jobQueues[queueKey] {
            let didRemove = jobQueue.removeValueForKey(job.identifier) != nil
            
            // Swift returns struct values in functions instead of references, and Swift dictionary and arrays are based on structs. So, we need to set the value again.
            jobQueues[queueKey] = jobQueue
            
            return didRemove
        } else {
            return false
        }
    }
    
    /// Gets the job queue and creates if it doesn't exist.
    private func getOrCreateJobQueueForKey(queueKey: String) -> JobQueue {
        // Create queue with that key if it doesn't exist.
        if jobQueues[queueKey] == nil {
            jobQueues[queueKey] = [:]
        }
        
        return jobQueues[queueKey]!
    }
    
    /// Adds the job to job queue.
    private func addJobToJobQueue(queueKey: String, job: ImageTransformationJob) {
        var queue = getOrCreateJobQueueForKey(queueKey)
        
        queue[job.identifier] = job
        
        // Swift returns struct values in functions instead of references, and Swift dictionary and arrays are based on structs. So, we need to set the value again.
        jobQueues[queueKey] = queue
    }
    
    /// Returns if the job queue with that queue empty.
    private func isJobQueueEmpty(queueKey: String) -> Bool {
        return jobQueues[queueKey]?.count ?? 0 == 0
    }
    
    /// Returns the current time, this is used to calculate the duration of each job upon completion.
    private func getCurrentTime() -> NSTimeInterval {
        // NSDate related methods for getting time are slow, so CoreAnimation ones are prefered.
        return CACurrentMediaTime()
    }
}
