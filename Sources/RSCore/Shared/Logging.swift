//
//  Logging.swift
//  
//
//  Created by Stuart Breckenridge on 04/08/2022.
//

import Foundation
import os.log


/// The `Logging` Protocol provides a convenient way to
/// log your app's behaviour.
///
/// Types that conform to the `Logging` protocol
/// have access to a [`Logger`](https://developer.apple.com/documentation/os/logger)
/// variable or static variable.
/// The `logger` can be used to log messages about the
/// app's behaviour.
@available(macOS 11, *)
@available(macOSApplicationExtension 11, *)
@available(iOS 14, *)
@available(iOSApplicationExtension 14, *)
public protocol Logging {
    
    var logger: Logger { get }
    static var logger: Logger { get }
    
}

@available(macOS 11, *)
@available(macOSApplicationExtension 11, *)
@available(iOS 14, *)
@available(iOSApplicationExtension 14, *)
public extension Logging  {
    
    var logger: Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: type(of: self)))
    }
    
    static var logger: Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: type(of: self)))
    }
    
}

