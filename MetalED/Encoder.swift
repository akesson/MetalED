//
//  Encoder.swift
//  MetalED
//
//  Created by Henrik Akesson on 12/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

class Encoder {
    
    let threadsPerThreadgroup: MTLSize
    let name: String
    
    init(name: String, threadsPerThreadgroup: MTLSize) {
        self.name = name
        self.threadsPerThreadgroup = threadsPerThreadgroup
    }
    
    func threadgroupsPerGridFromTexture(texture: MTLTexture) -> MTLSize {
        // Determine how many threadgroups we need to dispatch to fully cover the destination region
        // There will almost certainly be some wasted threads except when both textures are neat
        // multiples of the thread-per-threadgroup size and the offset and clip region are agreeable.
        let widthInThreadgroups = (texture.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (texture.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
        
        return MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
    }
}
