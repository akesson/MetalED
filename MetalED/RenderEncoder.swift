//
//  RenderEncoder.swift
//  MetalED
//
//  Created by Henrik Akesson on 04/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

class RenderEncoder: Encoder {
    
    let renderPipelineState: MTLRenderPipelineState
    let samplerStates: [MTLSamplerState]
    
    init(renderName: String, vertexFunction: String, fragmentFunction: String, threadsPerThreadgroup: MTLSize) {
        
        renderPipelineState = GPU.renderPipelineStateFor(renderName, vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
        let nearest = MTLSamplerDescriptor()
        nearest.label = "nearest"
        
        let bilinear = MTLSamplerDescriptor()
        bilinear.label = "bilinear"
        bilinear.minFilter = .Linear
        bilinear.magFilter = .Linear
        samplerStates = [nearest, bilinear].map {GPU.newSamplerState($0)}
        super.init(name: renderName, threadsPerThreadgroup: threadsPerThreadgroup)

    }
    
    func encodeToRenderBuffer(commandBuffer: MTLCommandBuffer,
                              descriptor: MTLRenderPassDescriptor,
                              textures: [MTLTexture],
                              fragmentBuffers: [MTLBuffer],
                              threadgroupsPerGrid: MTLSize) {
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(descriptor)
        
        renderEncoder.pushDebugGroup(name)
        renderEncoder.label = name
        
        //Sets the viewport, which is used to transform vertices from normalized device coordinates to window coordinates.
        //renderEncoder.setViewport(view)  //MTLViewport only last render
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(FullScreenVertexes.buffer, offset: 0, atIndex: 0)
        for (index, buffer) in fragmentBuffers.enumerate() {
            renderEncoder.setFragmentBuffer(buffer, offset: 0, atIndex: index)
        }
        for (index, texture) in textures.enumerate() {
            renderEncoder.setFragmentTexture(texture, atIndex: index)
        }
        for (index, samplerState) in samplerStates.enumerate() {
            //the sampler states are always set, it's up to the shaders if they use them or not
            renderEncoder.setFragmentSamplerState(samplerState, atIndex: index)
        }
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}