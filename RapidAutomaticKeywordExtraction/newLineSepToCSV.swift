//
//  newLineSepToCSV.swift
//  RapidAutomaticKeywordExtraction
//
//  Created by Avery Jones on 2017-10-16.
//  Copyright © 2017 AJ productions. All rights reserved.
//

import Foundation

var a = readLine()
var out : String = ""
while a != nil {
    if(a!.characters[a!.characters.startIndex] != "#"){
        out += "\(a!), "
    }
    a = readLine()
}
print(out)
