//
//  ImageScraper.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

/*
This is a list of directories to ignore when recursively collecting all files
I'm not sure if we can put other things in this list, but .git is a big folder and there will never be an xcassets folder within it.
*/
private let kIgnoredDirectories = [".git"]
private let kImageSetSuffix = ".imageset"
private let kImageJsonName = "Contents.json"

class ImageScraper {
    
    // MARK: Properties
    
    private let parentDirectory: String
    private let fileManager = NSFileManager.defaultManager()
    
    // MARK: Initialization 
    
    required init(parentDirectory: String) {
        self.parentDirectory = currentDirectory
    }
    
    // MARK: Json File Paths
    
    private func allImageJsonFilePaths() -> [String] {
        return allImageJsonFilesAtStartPath(parentDirectory)
    }
    
    private func allImageJsonFilesAtStartPath(path: String) -> [String] {
        var err: NSError? = nil
        var allPaths: [String] = []
        if let contents = fileManager.contentsOfDirectoryAtPath(path, error: &err) as? [String] {
            if !contents.isEmpty {
                for contentPath in contents {
                    if contains(kIgnoredDirectories, contentPath) {
                        continue
                    }
                    
                    let fullContentPath = path + "/" + contentPath
                    if fullContentPath.contains(kImageSetSuffix) && fullContentPath.hasSuffix(kImageJsonName) {
                        allPaths += [fullContentPath]
                    }
                    allPaths += allImageJsonFilesAtStartPath(fullContentPath)
                }
            }
        } else if SHOULD_LOG, let error = err {
            println("ERROR: \n\n\(error)\n\nForPath: \(path)")
        }
        
        return  allPaths
    }
    
    // MARK: Image Json
    
    private func imageDictionaries() -> [[String : AnyObject]] {
        return imageDictionariesForPaths(allImageJsonFilePaths())
    }
    
    private func imageDictionariesForPaths(imageJsonPaths: [String]) -> [[String : AnyObject]] {
        var imageDictionaries: [[String : AnyObject]] = []
        for path in imageJsonPaths {
            let JSON: [String : AnyObject]? = NSData.jsonAtPath(path)
            if let json = JSON {
                imageDictionaries += [json]
            } else if SHOULD_LOG {
                println("ERR: Unable to load json at path: \(path)")
            }
        }
        return imageDictionaries
    }
    
    // MARK: Image Names
    
    private func imageNames() -> [String] {
        var imageNames: [String] = []
        for imageSetDict in imageDictionaries() {
            if let imagesArray = imageSetDict["images"] as? [AnyObject] {
                if let first = imagesArray.first as? [String : String]{
                    if let imageName = first["filename"] {
                        imageNames.append(imageName)
                    }
                }
            }
        }
        return imageNames
    }
    
    // MARK: Public Interface
    
    class func imageNames(#parentDirectory: String) -> [String] {
        return self(parentDirectory: parentDirectory).imageNames()
    }
}
