//
//  Directory.swift
//  MetalED
//
//  Created by Henrik Akesson on 30/07/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation

struct Directory {
    
    let path: String
    
    func deleteAll() throws {
        let dir = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
        try dir.forEach { file in
            let pathString = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try NSFileManager.defaultManager().removeItemAtPath(pathString)
        }
    }
    
    static func temporary() -> Directory {
        return Directory(path: NSTemporaryDirectory())
    }
}