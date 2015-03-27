//
//  ImageFileFormatter.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

class ImageFileWriter {
    
    // MARK: Properties
    
    private var categoryName: String
    private var rawImageNames: [String]
    private var includeNonnull: Bool
    
    // MARK: Lazy 
    
    lazy var camelCaseImageNames: [String : String] = {
        var camelCaseImageNames: [String : String] = [:]
        for rawImageName in self.rawImageNames {
            camelCaseImageNames[rawImageName] = rawImageName.camelCaseVersion()
        }
        return camelCaseImageNames
        }()
    
    // MARK: Initialization
    
    convenience init(categoryName: String, rawImageNames: [String]) {
        self.init(categoryName: categoryName, rawImageNames: rawImageNames, includeNonnull: false)
    }
    
    required init(categoryName: String, rawImageNames: [String], includeNonnull: Bool) {
        self.categoryName = categoryName
        self.rawImageNames = rawImageNames
        self.includeNonnull = includeNonnull
    }
    
    // MARK: Data Write
    
    func writeToDirectoryPath(directoryPath: String) -> Bool {
        fatalError("This method should be overridden by subclass")
    }
    
    private func writeData(data: NSData, toFilePath filePath: String) -> Bool {
        var success: Bool = false
        let defaultManager = NSFileManager.defaultManager()
        if !defaultManager.fileExistsAtPath(filePath) {
            success = defaultManager.createFileAtPath(filePath, contents: data, attributes: nil)
            if SHOULD_LOG && !success {
                println("Error overwriting data: \n\nCode: \(errno)\nMessage: \(strerror(errno))\n\nFilePath: \(filePath)")
            }
        } else {
            var err: NSError? = nil
            success = data.writeToFile(filePath, options: .AtomicWrite, error: &err)
            if SHOULD_LOG, let error = err {
                println("Error overwriting data:\n\n\(error) \n\nFilePath: \(filePath)")
            }
        }
        return success
    }
}

class ImageWriterObjC : ImageFileWriter {
    
    // Perhaps add option to `@import UIKit;`
    private let importStatement: String = "#import <UIKit/UIKit.h>"
    
    private lazy var classType: String = {
        var classType = "UIImage *"
        if self.includeNonnull {
            classType = "nonnull \(classType)"
        }
        return classType
        }()
    
    private func headerFileName() -> String {
        return "UIImage+\(self.categoryName).h"
    }
    
    private func declarations() -> [String] {
        var declarations: [String] = []
        for rawImageName in rawImageNames {
            if let camelCaseImageName = camelCaseImageNames[rawImageName] {
                let declaration = "+ (\(classType))\(camelCaseImageName);"
                declarations.append(declaration)
            } else if SHOULD_LOG {
                println("ERR: No camel case name found for \(rawImageName)")
            }
        }
        return declarations
    }
    
    private func formattedDeclarations() -> String {
        return join("\n", declarations())
    }
    
    // MARK: Implementation
    
    private func implementationFileName() -> String {
        return "UIImage+\(self.categoryName).m"
    }
    
    private func definitions() -> [String] {
        var imageMethodDefinitions: [String] = []
        for rawImageName in rawImageNames {
            if let camelCaseName = camelCaseImageNames[rawImageName] {
                var definition = "+ (\(classType))\(camelCaseName) {"
                definition += "\n"
                definition += "    return [UIImage imageNamed:@\"\(rawImageName)\"];"
                definition += "\n"
                definition += "}"
                imageMethodDefinitions.append(definition)
            } else if SHOULD_LOG {
                println("ERR: No camel case name found for \(rawImageName)")
            }
        }
        
        return imageMethodDefinitions
    }
    
    private func formattedDefinitions() -> String {
        return join("\n\n", definitions())
    }
    
    private func generateHeader() -> String {
        var headerString = importStatement
        headerString += "\n\n"
        headerString += "@interface UIImage(\(categoryName))"
        headerString += "\n\n"
        headerString += formattedDeclarations()
        headerString += "\n\n"
        headerString += "@end"
        headerString += "\n"
        return headerString
    }
    
    private func generateHeaderData() -> NSData {
        return generateHeader().dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func generateImplementation() -> String {
        var headerString = "#import \"UIImage+\(categoryName).h\""
        headerString += "\n\n"
        headerString += "@implementation UIImage(\(categoryName))"
        headerString += "\n\n"
        headerString += formattedDefinitions()
        headerString += "\n\n"
        headerString += "@end"
        headerString += "\n"
        return headerString
    }
    
    private func generateImplementationData() -> NSData {
        return generateImplementation().dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    override func writeToDirectoryPath(directoryPath: String) -> Bool {
        var success = false
        
        let header = generateHeaderData()
        let fullHeaderFileName = "\(directoryPath)/\(headerFileName())"
        success = writeData(header, toFilePath: fullHeaderFileName)
        
        let implementation = generateImplementationData()
        let fullImplementationFileName = "\(directoryPath)/\(implementationFileName())"
        success = writeData(implementation, toFilePath: fullImplementationFileName)
        
        return success
    }
}
