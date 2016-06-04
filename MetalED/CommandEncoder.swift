//
//  CommandEncoder.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

public class CommandEncoder {
    
    let computePipeline: MTLComputePipelineState
    let kernelName: String
    let threadsPerThreadgroup: MTLSize
    
    public init(device: MTLDevice, kernelName: String, threadsPerThreadgroup: MTLSize) {
        self.kernelName = kernelName
        self.threadsPerThreadgroup = threadsPerThreadgroup
        guard let library = device.newDefaultLibrary() else {
            fatalError("Failed to read kernel library")
        }
        guard let computeFunction = library.newFunctionWithName(kernelName) else {
            fatalError("Failed to retrieve kernel function \(kernelName) from library")
        }
        
        do {
            try computePipeline = device.newComputePipelineStateWithFunction(computeFunction)
        } catch {
            fatalError("Error occurred when compiling compute pipeline: \(error)")
        }
    }
    
    public func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                      textures: [MTLTexture],
                                      threadgroupsPerGrid: MTLSize) {
        // Set up and dispatch the work
        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.pushDebugGroup("Dispatch \(kernelName) kernel")
        commandEncoder.setComputePipelineState(computePipeline)
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