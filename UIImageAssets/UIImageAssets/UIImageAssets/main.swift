//
//  main.swift
//  UIImageAssets
//
//  Created by Colden Prime on 3/20/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation


// MARK: Global Logging

var SHOULD_LOG = false


// MARK: Working Directory

let fileManager = NSFileManager.defaultManager()
let currentDirectory = fileManager.currentDirectoryPath


// MARK: Arguments

let arguments = Process.arguments

// required: the category name to use
let categoryName = arguments[1].capitalizedString

// include nonnull keyword
let nonnull = contains(arguments, "--nonnull")
// Generate a swift file -- not yet implemented
let swift = contains(arguments, "--swift")

/*
Eventually, there should be a way to pass a path as an argument.  
Perhaps in addition, we should search for a category that exists with the same name and overwrite that automatically.
*/
let toPath = currentDirectory

//func shell(args: String...) -> Int32 {
//    let task = NSTask()
//    task.launchPath = "/usr/bin/env"
//    task.arguments = args
//    task.launch()
//    task.waitUntilExit()
//    return task.terminationStatus
//}

import Foundation

//let task = NSTask()
//task.launchPath = "/usr/local/bin/./git"
//task.arguments = ["log", "--oneline"]
//
//let pipe = NSPipe()
//task.standardOutput = pipe
//task.launch()
//
//let data = pipe.fileHandleForReading.readDataToEndOfFile()
//let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
//
//print(output)
//assert(output == "first-argument second-argument\n")

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

println(shell("pod install").output)


// MARK: Image Scrape

/*
Right now, this just finds all imageset folders in the current directory, perhaps add a way to differentiate for WatchKit App, WatchKit Extension, Project, etc.

Temporary work around, navigate to that directory before generating file
*/
//var imageNames = ImageScraper.imageNames(parentDirectory: currentDirectory)


// MARK: File Write

//let imageWriter = ImageWriterObjC(
//    categoryName: categoryName,
//    rawImageNames: imageNames,
//    includeNonnull: nonnull
//)
//
//let success = imageWriter.writeToDirectoryPath(toPath)
//if success {
//    println("Successfully wrote to path: \(currentDirectory)")
//} else {
//    println("Process failed!")
//}
