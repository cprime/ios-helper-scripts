//
//  String+CamelCase.swift
//  UIImageAssets
//
//  Created by Logan Wright on 3/21/15.
//  Copyright (c) 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

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
