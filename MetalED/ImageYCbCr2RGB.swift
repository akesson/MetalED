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
    let renderEncoder: RenderEncoder
    
    public init() {
        commandEncoder = CommandEncoder(kernelName: "YCbCr2RGB_Kernel", threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
        renderEncoder = RenderEncoder(renderName: "YCbCr2RGB", vertexFunction: "defaultVertex", fragmentFunction: "YCbCr2RGB_Fragment")
    }
    
    public func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                      yTexture: MTLTexture,
                                      cbcrTexture: MTLTexture,
                                      destinationTexture destTexture: MTLTexture) {
        
        let threadgroupsPerGrid = commandEncoder.threadgroupsPerGridFromTexture(destTexture)
        commandEncoder.encodeToCommandBuffer(commandBuffer, textures: [yTexture, cbcrTexture, destTexture], buffers: [], threadgroupsPerGrid: threadgroupsPerGrid)
    }
    
    public func encodeToFragmentBuffer(commandBuffer: MTLCommandBuffer,
                                       descriptor: MTLRenderPassDescriptor,
                                       yTexture: MTLTexture,
                                       cbcrTexture: MTLTexture,
                                       destinationTexture destTexture: MTLTexture) {
        
        let threadgroupsPerGrid = commandEncoder.threadgroupsPerGridFromTexture(destTexture)

        renderEncoder.encodeToRenderBuffer(commandBuffer, descriptor: descriptor, textures: [yTexture, cbcrTexture, destTexture], fragmentBuffers: [], threadgroupsPerGrid: threadgroupsPerGrid)
    }
}