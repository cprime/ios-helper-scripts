//
//  main.swift
//  UIImageAssets
//
//  Created by Colden Prime on 3/20/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

extension String {
    /**
    Used to check if a String contains a given substring
    
    :param: find the substring to search for
    
    :returns: whether or not the substring exists
    */
    func contains(find: String) -> Bool {
        return self.rangeOfString(find) != nil
    }
}

let fileManager = NSFileManager.defaultManager()
let currentDirectory = fileManager.currentDirectoryPath

/*
This is a list of directories to ignore when recursively collecting all files
I'm not sure if we can put other things in this list, but .git is a big folder and there will never be an xcassets folder within it.
*/

let ignoredDirectories = [".git"]
let xcassetsSuffix = ".xcassets"
let imageSetSuffix = ".imageset"
let imageJsonName = "Contents.json"
func allImageJsonFilesAtPath(path: String) -> [String] {
    var err: NSError? = nil
    var allPaths: [String] = []
    if let contents = fileManager.contentsOfDirectoryAtPath(path, error: &err) as? [String] {
        if let error = err {
            println("ERROR: \(error)")
        }
        
        if !contents.isEmpty {
            for contentPath in contents {
                if contains(ignoredDirectories, contentPath) {
                    continue
                }
                
                let fullContentPath = path + "/" + contentPath
                if fullContentPath.contains(imageSetSuffix) && fullContentPath.hasSuffix(imageJsonName) {
                    allPaths += [fullContentPath]
                }
                allPaths += allImageJsonFilesAtPath(fullContentPath)
            }
        }
    }
    
    return  allPaths
}

typealias ImageJsonDictionary = [String : AnyObject]
typealias ImageJsonDictionariesArray = [ImageJsonDictionary]

func imageJsonPathsToDictionaries(imageJsonPaths: [String]) -> ImageJsonDictionariesArray {
    var imageDictionaries: ImageJsonDictionariesArray = []
    for path in imageJsonPaths {
        if let data = NSData(contentsOfFile: path) {
            var err: NSError? = nil
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as? ImageJsonDictionary {
                imageDictionaries += [json]
            } else if let error = err {
                println("ERROR: \(error) \n\n For Path: \(path)")
            }
        }
    }
    return imageDictionaries
}

let imageJsonFilePaths = allImageJsonFilesAtPath(currentDirectory)
let imageDictionaries = imageJsonPathsToDictionaries(imageJsonFilePaths)

var imageNames: [String] = []
for imageSetDict in imageDictionaries {
    if let imagesArray = imageSetDict["images"] as? [AnyObject] {
        if let first = imagesArray.first as? [String : String]{
            if let imageName = first["filename"] {
                imageNames.append(imageName)
            }
        }
    }
}

let header = ImageFileFormatter.generateUIImageCategoryWithName("Test", directoryPath: currentDirectory, imageNames: imageNames)
println("header: \(header)")


