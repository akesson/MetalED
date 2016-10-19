//
//  CommandEncoder.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

class CommandEncoder: Encoder {
    
    let computePipelineState: MTLComputePipelineState
    
    init(kernelName: String, threadsPerThreadgroup: MTLSize) {
        computePipelineState = GPU.computePipelineStateFor(kernelName)
        super.init(name: kernelName, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func encodeToCommandBuffer(_ commandBuffer: MTLCommandBuffer,
                                      textures: [MTLTexture],
                                      buffers: [MTLBuffer],
                                      threadgroupsPerGrid: MTLSize) {
        // Set up and dispatch the work
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.pushDebugGroup("Dispatch \(name) kernel")
        commandEncoder.setComputePipelineState(computePipelineState)
        for (index, buffer) in buffers.enumerated() {
            commandEncoder.setBuffer(buffer, offset: 0, at: index)
        }
        for (index,texture) in textures.enumerated() {
            commandEncoder.setTexture(texture, at: index)
        }
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.popDebugGroup()
        commandEncoder.endEncoding()
    }
    
    
}
