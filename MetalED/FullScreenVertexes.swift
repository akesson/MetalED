//
//  FullScreenVertexes.swift
//  MetalED
//
//  Created by Henrik Akesson on 02/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation
import MetalKit


class FullScreenVertexes {
    
    static var buffer:MTLBuffer {
        return instance.vertexBuffer
    }
    
    static var descriptor:MTLVertexDescriptor {
        return instance.vertexDesc
    }
    
    fileprivate let vertexBuffer:MTLBuffer
    fileprivate let vertexDesc = MTLVertexDescriptor()
    
    fileprivate static let instance = FullScreenVertexes()
    
    fileprivate init() {
        // set up the full screen quads
        let data:[Float] = [  -1.0,  -1.0,  0.0, 1.0,
                               1.0,  -1.0,  1.0, 1.0,
                              -1.0,   1.0,  0.0, 0.0,
                               1.0,  -1.0,  1.0, 1.0,
                              -1.0,   1.0,  0.0, 0.0,
                               1.0,   1.0,  1.0, 0.0]
        
        vertexBuffer = GPU.newBuffer(data)
        
        // create the full screen quad vertex attribute descriptor
        let vert = MTLVertexAttributeDescriptor()
        vert.format = .float2
        vert.bufferIndex = 0
        vert.offset = 0
        
        let tex = MTLVertexAttributeDescriptor()
        tex.format = .float2
        tex.bufferIndex = 0
        tex.offset = 2 * MemoryLayout<Float>.size
        
        let layout = MTLVertexBufferLayoutDescriptor()
        layout.stride = 4 * MemoryLayout<Float>.size
        layout.stepFunction = MTLVertexStepFunction.perVertex
        
        vertexDesc.layouts[0] = layout
        vertexDesc.attributes[0] = vert
        vertexDesc.attributes[1] = tex
    }
}
