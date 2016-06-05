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
    
    private let vertexBuffer:MTLBuffer
    private let vertexDesc = MTLVertexDescriptor()
    
    private static let instance = FullScreenVertexes()
    
    private init() {
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
        vert.format = .Float2
        vert.bufferIndex = 0
        vert.offset = 0
        
        let tex = MTLVertexAttributeDescriptor()
        tex.format = .Float2
        tex.bufferIndex = 0
        tex.offset = 2 * sizeof(Float)
        
        let layout = MTLVertexBufferLayoutDescriptor()
        layout.stride = 4 * sizeof(Float)
        layout.stepFunction = MTLVertexStepFunction.PerVertex
        
        vertexDesc.layouts[0] = layout
        vertexDesc.attributes[0] = vert
        vertexDesc.attributes[1] = tex
    }
}