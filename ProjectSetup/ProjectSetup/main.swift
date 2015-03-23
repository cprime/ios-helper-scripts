//
//  main.swift
//  ProjectSetup
//
//  Created by Logan Wright on 3/22/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

func println(err: NSError?) {
    var output = err == nil ? "SUCCESS" : "FAILURE: \(err!)"
    println(output)
}

// MARK: Gitignore

let gitignoreUrl = NSURL(string: "https://raw.githubusercontent.com/github/gitignore/master/Swift.gitignore")!
var gitignore = NSData(contentsOfURL: gitignoreUrl)!
var gitignoreString = NSString(data: gitignore, encoding: NSUTF8StringEncoding)!

gitignoreString = gitignoreString.stringByReplacingOccurrencesOfString(
    "# Pods",
    withString: "Pods"
)
gitignoreString = gitignoreString.stringByReplacingOccurrencesOfString(
    "# Carthage/Checkouts",
    withString: "Carthage/Checkouts"
)

var err: NSError? = nil
gitignoreString.writeToFile(
    ".gitignore",
    atomically: true,
    encoding: NSUTF8StringEncoding,
    error: &err
)
println(".gitignore")
println(err)

// MARK: Podfile

var podfile = "source 'https://github.com/CocoaPods/Specs.git'"
podfile += "\n\n"
// TODO: Allow args here?
podfile += "platform :ios, '7.1'"
podfile += "\n\n"
podfile.writeToFile(
    "Podfile",
    atomically: true,
    encoding: NSUTF8StringEncoding,
    error: &err
)
println("Podfile")
println(err)

// MARK: Pods installation
println("Loading Pods... \n")
let podResponse = shell("pod install")
println(podResponse.output)

// MARK: Open Workspace

let workspaceSuffix = ".xcworkspace"
let defaultManager = NSFileManager.defaultManager()
let currentDirectoryPath = defaultManager.currentDirectoryPath
func findWorkspacePath(_ path: String = currentDirectoryPath) -> String? {
    
    let contents = defaultManager.contentsOfDirectoryAtPath(
        path,
        error: nil
    ) as? [String] ?? []
    
    // First check if file in this folder.
    for file in contents {
        if file.hasSuffix(workspaceSuffix) {
            return path + "/" + file
        }
    }
    
    // Now check if any of these files contains a workspace
    for file in contents {
        let fullPath = path + "/" + file
        if let found = findWorkspacePath(fullPath) {
            return found
        }
    }
    
    // Now, fail
    return nil
}

if let workspacePath = findWorkspacePath() {
    shell("open \(workspacePath)")
}
