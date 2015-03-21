//
//  String+Substring.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
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