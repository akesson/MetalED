//
//  ImageYCbCr2RGB.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

public class ImageYCbCr2RGB {
    
    let commandEncoder: CommandEncoder
    
    public init(device: MTLDevice) {
        commandEncoder = CommandEncoder(device: device, kernelName: "YCbCr2RGB_Kernel", threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
    }
    
    public func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                      yTexture: MTLTexture,
                                      cbcrTexture: MTLTexture,
                                      destinationTexture destTexture: MTLTexture) {
        
        let threadgroupsPerGrid = commandEncoder.threadgroupsPerGridFromTexture(destTexture)
        commandEncoder.encodeToCommandBuffer(commandBuffer, textures: [yTexture, cbcrTexture, destTexture], threadgroupsPerGrid: threadgroupsPerGrid)
    }
}