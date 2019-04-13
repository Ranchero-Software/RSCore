//
//  FourCharCode.swift
//  RSCore
//
//  Created by Olof Hellman on 1/7/18.
//  Copyright © 2018 Olof Hellman. All rights reserved.
//

import Foundation

/*
   @function FourCharCode()
   @brief    FourCharCode values like OSType, DescType or AEKeyword  are really just 
             4 byte values commonly represented as values like 'odoc' where each byte is 
             represented as its ASCII character.  This function turns a swift string into 
             its FourCharCode equivalent, as swift doesn't recognize FourCharCode types 
             natively just yet.  With this extension, one can use
                  "odoc".fourCharCode()
             where one would really want to use 'odoc'
*/
public extension String {

    func fourCharCode() -> FourCharCode {
		precondition(count == 4)
        var sum: UInt32 = 0
        for scalar in self.unicodeScalars {
            sum = (sum * 256) + scalar.value
        }
        return sum
    }
}

public extension Int {

    func fourCharCode() -> FourCharCode {
        return (UInt32(self))
    }
}

