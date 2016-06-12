//
//  StandardExtensions.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

extension Dictionary {
    
    mutating func lookupOrAdd(key: Key, add: () -> Value) -> Value {
        if let val = self[key] {
            return val
        } else {
            let val = add()
            self[key] = val
            return val
        }
    }
}

extension MPSUnaryImageKernel : RenderProtocol {
    
    func encodeToBuffer(commandBuffer: MTLCommandBuffer, renderDescriptor: MTLRenderPassDescriptor, inTexture: MTLTexture, outTexture: MTLTexture) {
        encodeToCommandBuffer(commandBuffer, sourceTexture: inTexture, destinationTexture: outTexture)
    }
}