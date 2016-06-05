//
//  Common.metal
//  MetalED
//
//  Created by Henrik Akesson on 05/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ColorMatrix {
    float3x3 matrix;
};

struct ColorOffset {
    float3 offset;
};

struct VertexIn {
    float2 m_Position [[ attribute(0) ]];
    float2 m_TexCoord [[ attribute(1) ]];
};

struct VertexOut {
    float4 m_Position [[ position ]];
    float2 m_TexCoord [[ user(texturecoord) ]];
};
