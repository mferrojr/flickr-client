//
//  BaseOperation.swift
//  flickr-client
//
//  Created by Michael Ferro, Jr. on 6/22/20.
//  Copyright © 2020 Michael Ferro, Jr. All rights reserved.
//

import Foundation

// Reference: https://github.com/mferrojr/github-filediff/blob/master/filediff/Persistence/Operations/BaseOperation.swift
class BaseOperation: Operation {
    
    // MARK: - Variables
    
    // MARK: Public
    var errorCallback: ((Error?) -> Void)?
    var dataTask : URLSessionDataTask?
    
    // MARK: Private
    fileprivate var _executing = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished = false
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func cancel() {
        guard !self.isCancelled else { return }
        
        completionBlock = nil
        dataTask?.cancel()
    }

    //MARK: Ending Functions
    func done() {
        isExecuting = false
        isFinished = true
    }
    
    func errorCB(_ error : Error?) {
        self.errorCallback?(error)
    }

}
