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
        let dir = try FileManager.default.contentsOfDirectory(atPath: path)
        try dir.forEach { file in
            let pathString = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try FileManager.default.removeItem(atPath: pathString)
        }
    }
    
    static func temporary() -> Directory {
        return Directory(path: NSTemporaryDirectory())
    }
}
