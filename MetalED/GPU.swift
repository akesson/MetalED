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
    
    private static var compiledFunctions = [String:MTLFunction]()
    
    static let device = MTLCreateSystemDefaultDevice()!
    static let library = device.newDefaultLibrary()!
    static let commandQueue = device.newCommandQueue()
    
    static func computePipelineStateFor(function: String) -> MTLComputePipelineState {
        let computeFunction = getFunction(function)
        var computePipelineState: MTLComputePipelineState
        do {
            try computePipelineState = device.newComputePipelineStateWithFunction(computeFunction)
        } catch {
            fatalError("Error occurred when compiling compute pipeline: \(error)")
        }
        return computePipelineState
    }
    
    static func renderPipelineStateFor(name: String, vertexFunction: String, fragmentFunction: String) -> MTLRenderPipelineState {
        // create a pipeline state descriptor for a vertex/fragment shader combo
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = name
        descriptor.vertexFunction = getFunction(vertexFunction)
        descriptor.fragmentFunction = getFunction(fragmentFunction)
        descriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        descriptor.vertexDescriptor = FullScreenVertexes.descriptor
        
        // create the actual pipeline state
        var info:MTLRenderPipelineReflection? = nil
        do {
            let pipelineState = try device.newRenderPipelineStateWithDescriptor(descriptor, options: MTLPipelineOption.BufferTypeInfo, reflection: &info)
            return pipelineState
            
        } catch let pipelineError as NSError {
            fatalError("Failed to create pipeline state for shaders \(vertexFunction):\(fragmentFunction) error \(pipelineError)")
        }
    }
    
    static func getFunction(name: String) -> MTLFunction {
        return compiledFunctions.lookupOrAdd(name) { newFunction(name) }
    }
    
    private static func newFunction(name: String) -> MTLFunction {
        guard let function = library.newFunctionWithName(name) else {
            fatalError("Failed to retrieve kernel function \(name) from library")
        }
        return function;
    }
    
    static func newSamplerState(descriptor: MTLSamplerDescriptor) -> MTLSamplerState {
        return device.newSamplerStateWithDescriptor(descriptor)
    }
 
    static func newTexture(width width: Int, height: Int) -> MTLTexture {
        let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.BGRA8Unorm, width: width, height: height, mipmapped: false)
        return device.newTextureWithDescriptor(desc)
    }
    
    static func newBuffer(data:[Float]) -> MTLBuffer {
        // set up vertex buffer
        let dataSize = data.count * sizeofValue(data[0]) // 1
        
        let options:MTLResourceOptions = MTLResourceOptions.StorageModeShared.union(MTLResourceOptions.CPUCacheModeDefaultCache)
        return device.newBufferWithBytes(data, length: dataSize, options: options)
    }
    
    static func commandBuffer() -> MTLCommandBuffer {
        return commandQueue.commandBuffer()
    }
}
