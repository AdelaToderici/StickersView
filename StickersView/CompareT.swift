//
//  CompareT.swift
//  image-tests
//
//  Created by Adela Toderici on 2018-02-05.
//  Copyright © 2018 Mykel. All rights reserved.
//

import Foundation

struct CompareT {
    
    func MIN <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return b
        }
        return a
    }
    
    func MAX <T : Comparable> (a: T, b: T) -> T {
        if a > b {
            return a
        }
        return b
    }
}
