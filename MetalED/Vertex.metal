//
//  Vertex.metal
//  MetalED
//
//  Created by Henrik Akesson on 05/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
#include "Common.metal"

using namespace metal;


vertex VertexOut defaultVertex( VertexIn vert [[ stage_in ]], unsigned int vid [[ vertex_id ]]) {
    VertexOut outVertices;
    outVertices.m_Position = float4(vert.m_Position,0.0,1.0);
    outVertices.m_TexCoord = vert.m_TexCoord;
    return outVertices;
}