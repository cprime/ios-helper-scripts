//
//  Shell.swift
//  ProjectSetup
//
//  Created by Logan Wright on 3/22/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

func shell(input: String) -> (output: String, exitCode: Int32) {
    let arguments = split(input, maxSplit: Int.max, allowEmptySlices: true) {
        $0 == " "
    }
    
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = arguments
    task.environment = [
        "LC_ALL" : "en_US.UTF-8",
        "HOME" : NSHomeDirectory(),
        "PATH" : "/usr/bin"
    ]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    
    return (output, task.terminationStatus)
}
