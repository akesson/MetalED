//
//  SobelAndDiZenzoCumani.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

open class SobelAndDiZenzoCumaniKernel: MPSUnaryImageKernel {
    
    let commandEncoder:CommandEncoder
    
    public init() {
        commandEncoder = CommandEncoder(kernelName: "SobelAndDiZenzoCumani_Kernel", threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
        super.init(device: GPU.device)
    }
    
    open override func encode(commandBuffer: MTLCommandBuffer,
                                               sourceTexture: MTLTexture,
                                               destinationTexture destTexture: MTLTexture) {
        
        let threadgroupsPerGrid = commandEncoder.threadgroupsPerGridFromTexture(destTexture)
        commandEncoder.encodeToCommandBuffer(commandBuffer, textures: [sourceTexture, destTexture], buffers: [], threadgroupsPerGrid: threadgroupsPerGrid)
    }
}
