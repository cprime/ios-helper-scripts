//
//  ImageFileFormatter.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation


class ImageFileFormatter: NSObject {
    
    var categoryName: String = ""
    var directoryPath: String = ""
    var rawImageNames: [String] = []
    var includeNonnull: Bool = false
    
    
    class func generateUIImageCategoryWithName(categoryName: String, directoryPath: String, imageNames: [String], nonnullFlag: Bool = false) -> Bool {
        var success = false
        success = generateHeaderWithCategoryName(categoryName, directoryPath: directoryPath, imageNames: imageNames, nonnullFlag: nonnullFlag)
        success = generateImplementationWithCategoryName(categoryName, directoryPath: directoryPath, imageNames: imageNames, nonnullFlag: nonnullFlag)
        return success
    }
    
    class func generateHeaderWithCategoryName(categoryName: String, directoryPath: String, imageNames: [String], nonnullFlag: Bool = false) -> Bool {
        let headerString = headerFileAsStringCategoryName(categoryName, imageNames: imageNames, nonnullFlag: nonnullFlag)
        let headerData = headerString.dataUsingEncoding(NSUTF8StringEncoding)
        let path = "\(directoryPath)/UIImage+\(categoryName).h"
        var err: NSError? = nil
        var success: Bool = false
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            success = NSFileManager.defaultManager().createFileAtPath(path, contents: headerData, attributes: nil)
            if !success {
                NSLog("Error was code: %d - message: %s", errno, strerror(errno));
            }
        } else {
            success = headerData?.writeToFile(path, atomically: true) ?? false
        }
        return success
    }
    
    class func generateImplementationWithCategoryName(categoryName: String, directoryPath: String, imageNames: [String], nonnullFlag: Bool = false) -> Bool {
        let implementationString = implementationFileAsStringWithCategoryName(categoryName, imageNames: imageNames, nonnullFlag: nonnullFlag)
        let implementationData = implementationString.dataUsingEncoding(NSUTF8StringEncoding)
        let path = "\(directoryPath)/UIImage+\(categoryName).m"
        var err: NSError? = nil
        var success: Bool = false
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            success = NSFileManager.defaultManager().createFileAtPath(path, contents: implementationData, attributes: nil)
            if !success {
                NSLog("Error was code: %d - message: %s", errno, strerror(errno));
            }
        } else {
            success = implementationData?.writeToFile(path, atomically: true) ?? false
        }
        return success
    }
    
    class func headerFileAsStringCategoryName(categoryName: String, imageNames: [String], nonnullFlag: Bool = false) -> String {
        let camelCaseNames = camelCaseNamesForImageNames(imageNames)
        let declarations = imageMethodDeclarationsForImageNames(camelCaseNames, nonnullFlag: nonnullFlag)
        let formattedDeclarations = join("\n", declarations)
        var headerString = "@import UIKit;"
        headerString += "\n\n"
        headerString += "@interface UIImage(\(categoryName))"
        headerString += "\n\n"
        headerString += formattedDeclarations
        headerString += "\n\n"
        headerString += "@end"
        headerString += "\n"
        return headerString
    }
    
    class func implementationFileAsStringWithCategoryName(categoryName: String, imageNames: [String], nonnullFlag: Bool = false) -> String {
        let definitions = imageMethodDefinitionsForRawImageNames(imageNames, nonnullFlag: nonnullFlag)
        let formattedDefinitions = join("\n\n", definitions)
        var headerString = "#import \"UIImage+\(categoryName).h\""
        headerString += "\n\n"
        headerString += "@implementation UIImage(\(categoryName))"
        headerString += "\n\n"
        headerString += formattedDefinitions
        headerString += "\n\n"
        headerString += "@end"
        headerString += "\n"
        return headerString
    }
    
    class func camelCaseNamesForImageNames(imageNames: [String]) -> [String] {
        var filteredNames: [String] = []
        for imageName in imageNames {
                filteredNames.append(imageName.camelCaseVersion())
        }
        return filteredNames
    }
    
    class func imageMethodDeclarationsForImageNames(imageNames: [String], nonnullFlag: Bool = false) -> [String] {
        var imageMethodDeclarations: [String] = []
        var classType = "UIImage *"
        if nonnullFlag {
            classType = "nonnull \(classType)"
        }
        for imageName in imageNames {
            imageMethodDeclarations.append("+ (\(classType))\(imageName);")
        }
        return imageMethodDeclarations
    }
    
    class func imageMethodDefinitionsForRawImageNames(rawImageNames: [String], nonnullFlag: Bool = false) -> [String] {
        var imageMethodDeclarations: [String] = []
        var classType = "UIImage *"
        if nonnullFlag {
            classType = "nonnull \(classType)"
        }
        for imageName in rawImageNames {
            let camelCaseName = imageName.camelCaseVersion()
            var definition = "+ (\(classType))\(imageName.camelCaseVersion()) {"
            definition += "\n"
            definition += "    return [UIImage imageNamed:@\"\(imageName)\"];"
            definition += "\n"
            definition += "}"
            imageMethodDeclarations.append(definition)
        }
        return imageMethodDeclarations
    }
    
    func imageNameToCamelCase(imageName: String) -> String {
        return ""
    }
}

extension String {
    func camelCaseVersion() -> String {
        let arr = split(self, maxSplit: Int.max, allowEmptySlices: true) {
            return ".@".contains(String($0))
        }
        
        let originalImageName = arr.first! as String
        let imageNameComponents = split(originalImageName, maxSplit: Int.max, allowEmptySlices: true) {
            return "-_ ".contains(String($0))
        }
        
        var camelCaseName = ""
        for (idx,component) in enumerate(imageNameComponents) {
            camelCaseName += idx == 0 ? component.lowercaseString : component.capitalizedString
        }
        
        return camelCaseName
    }
}