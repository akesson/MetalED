//
//  PredictiveEdgeLinking.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

public class PredictiveEdgeLinking: MPSUnaryImageKernel {
    
    let PELKernelName = "PEL"
    var computePipeline: MTLComputePipelineState!

    public override init(device: MTLDevice) {
        super.init(device: device)
        
        //self.edgeMode = .Zero
        
        if let library = device.newDefaultLibrary() {
            if let computeFunction = library.newFunctionWithName(PELKernelName) {
                do {
                    try computePipeline = device.newComputePipelineStateWithFunction(computeFunction)
                } catch {
                    print("Error occurred when compiling compute pipeline: \(error)")
                }
            } else {
                print("Failed to retrieve kernel function \(PELKernelName) from library")
            }
        }
    }
    
    public override func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer,
                                               sourceTexture: MTLTexture,
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
        commandEncoder.pushDebugGroup("Dispatch PEL kernel")
        commandEncoder.setComputePipelineState(computePipeline)
        commandEncoder.setTexture(sourceTexture, atIndex: 0)
        commandEncoder.setTexture(destTexture, atIndex: 1)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.popDebugGroup()
        commandEncoder.endEncoding()
    }
}