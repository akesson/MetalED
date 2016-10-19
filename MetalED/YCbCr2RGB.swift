//
//  YCbCr2RGB.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

protocol YCbCr2RGB {
    func encodeToBuffer(_ commandBuffer: MTLCommandBuffer,
                        descriptor: MTLRenderPassDescriptor,
                        yTexture: MTLTexture,
                        cbcrTexture: MTLTexture,
                        outTexture: MTLTexture)
}

open class YCbCr2RGBKernel: YCbCr2RGB {
    
    let commandEncoder = CommandEncoder(kernelName: "YCbCr2RGB_Kernel", threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
    
    open func encodeToBuffer(_ commandBuffer: MTLCommandBuffer,
                               descriptor: MTLRenderPassDescriptor,
                               yTexture: MTLTexture,
                               cbcrTexture: MTLTexture,
                               outTexture: MTLTexture) {
        
        let threadgroupsPerGrid = commandEncoder.threadgroupsPerGridFromTexture(outTexture)
        commandEncoder.encodeToCommandBuffer(commandBuffer, textures: [yTexture, cbcrTexture, outTexture], buffers: [], threadgroupsPerGrid: threadgroupsPerGrid)
    }
}


open class YCbCr2RGBFragment: YCbCr2RGB {
    
    let renderEncoder = RenderEncoder(renderName: "YCbCr2RGB", vertexFunction: "defaultVertex", fragmentFunction: "YCbCr2RGB_Fragment", threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
    
    open func encodeToBuffer(_ commandBuffer: MTLCommandBuffer,
                               descriptor: MTLRenderPassDescriptor,
                               yTexture: MTLTexture,
                               cbcrTexture: MTLTexture,
                               outTexture: MTLTexture) {
        
        let threadgroupsPerGrid = renderEncoder.threadgroupsPerGridFromTexture(outTexture)
        
        renderEncoder.encodeToRenderBuffer(commandBuffer, descriptor: descriptor, textures: [yTexture, cbcrTexture, outTexture], fragmentBuffers: [], threadgroupsPerGrid: threadgroupsPerGrid)
    }
}
