//
//  CommandEncoder.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

public class CommandEncoder {
    
    let computePipelineState: MTLComputePipelineState
    let kernelName: String
    let threadsPerThreadgroup: MTLSize
    
    public init(kernelName: String, threadsPerThreadgroup: MTLSize) {
        self.kernelName = kernelName
        self.threadsPerThreadgroup = threadsPerThreadgroup
        computePipelineState = GPU.computePipelineStateFor(kernelName)
    }
    
    public func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                      textures: [MTLTexture],
                                      buffers: [MTLBuffer],
                                      threadgroupsPerGrid: MTLSize) {
        // Set up and dispatch the work
        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.pushDebugGroup("Dispatch \(kernelName) kernel")
        commandEncoder.setComputePipelineState(computePipelineState)
        for (index, buffer) in buffers.enumerate() {
            commandEncoder.setBuffer(buffer, offset: 0, atIndex: index)
        }
        for (index,texture) in textures.enumerate() {
            commandEncoder.setTexture(texture, atIndex: index)
        }
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.popDebugGroup()
        commandEncoder.endEncoding()
    }
    
    public func threadgroupsPerGridFromTexture(texture: MTLTexture) -> MTLSize {
        // Determine how many threadgroups we need to dispatch to fully cover the destination region
        // There will almost certainly be some wasted threads except when both textures are neat
        // multiples of the thread-per-threadgroup size and the offset and clip region are agreeable.
        let widthInThreadgroups = (texture.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (texture.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height

        return MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
    }
}