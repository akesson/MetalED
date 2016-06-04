//
//  GPU.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalKit

/* Represents the single GPU of the phone (will not use multi-GPU stuff) */
final class GPU {
    
    static let device = MTLCreateSystemDefaultDevice()!
    static let library = device.newDefaultLibrary()!
    static let commandQueue = device.newCommandQueue()
    
    static func computePipelineStateFor(function: String) -> MTLComputePipelineState {
        guard let computeFunction = library.newFunctionWithName(function) else {
            fatalError("Failed to retrieve kernel function \(function) from library")
        }
        var computePipelineState: MTLComputePipelineState
        do {
            try computePipelineState = device.newComputePipelineStateWithFunction(computeFunction)
        } catch {
            fatalError("Error occurred when compiling compute pipeline: \(error)")
        }
        return computePipelineState
    }
    
    static func newTexture(width width: Int, height: Int) -> MTLTexture {
        let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.BGRA8Unorm, width: width, height: height, mipmapped: false)
        return device.newTextureWithDescriptor(desc)
    }
    
    static func commandBuffer() -> MTLCommandBuffer {
        return commandQueue.commandBuffer()
    }
}
