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


// MARK: Image Scrape

/*
Right now, this just finds all imageset folders in the current directory, perhaps add a way to differentiate for WatchKit App, WatchKit Extension, Project, etc.

Temporary work around, navigate to that directory before generating file
*/
var imageNames = ImageScraper.imageNames(parentDirectory: currentDirectory)


// MARK: File Write

let imageWriter = ImageWriterObjC(
    categoryName: categoryName,
    rawImageNames: imageNames,
    includeNonnull: nonnull
)

let success = imageWriter.writeToDirectoryPath(toPath)
if success {
    println("Successfully wrote to path: \(currentDirectory)")
} else {
    println("Process failed!")
}
