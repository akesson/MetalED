//
//  ImageYCbCr2RGB.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

public class ImageYCbCr2RGB {
    
    let kernelName = "YCbCr2RGB"
    var computePipeline: MTLComputePipelineState!
    
    public init(device: MTLDevice) {
        if let library = device.newDefaultLibrary() {
            if let computeFunction = library.newFunctionWithName(kernelName) {
                do {
                    try computePipeline = device.newComputePipelineStateWithFunction(computeFunction)
                } catch {
                    print("Error occurred when compiling compute pipeline: \(error)")
                }
            } else {
                print("Failed to retrieve kernel function \(kernelName) from library")
            }
        }
    }
    
    public func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                               yTexture: MTLTexture,
                                               cbcrTexture: MTLTexture,
                                               destinationTexture destTexture: MTLTexture) {
        // We choose a fixed thread per threadgroup count here out of convenience, but could possibly
        // be more efficient by using a non-square threadgroup pattern like 32x16 or 16x32
        let threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        
        // Determine how many threadgroups we need to dispatch to fully cover the destination region
        // There will almost certainly be some wasted threads except when both textures are neat
        // multiples of the thread-per-threadgroup size and the offset and clip region are agreeable.
        let widthInThreadgroups = (destTexture.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (destTexture.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
        let threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
        
        // Set up and dispatch the work
        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.pushDebugGroup("Dispatch \(kernelName) kernel")
        commandEncoder.setComputePipelineState(computePipeline)
        commandEncoder.setTexture(yTexture, atIndex: 0)
        commandEncoder.setTexture(cbcrTexture, atIndex: 1)
        commandEncoder.setTexture(destTexture, atIndex: 2)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.popDebugGroup()
        commandEncoder.endEncoding()
    }

}