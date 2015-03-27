//
//  NSData+Json.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

extension NSData {
    class func jsonAtPath<T>(path: String) -> T? {
        let data = NSData(contentsOfFile: path)
        return data?.asJson()
    }
    
    func asJson<T>() -> T? {
        var err: NSError? = nil
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments, error: &err)
        if SHOULD_LOG, let error = err {
            println("Error loading JSON!\n\n\(error)")
        }
        return json as? T
    }
}
