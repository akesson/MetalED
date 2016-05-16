//
//  PEL.metal
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;



kernel void PEL(texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                uint2 gid [[thread_position_in_grid]])
{
    float3 rgb = inTexture.read(gid).rgb;
    outTexture.write(float4(float3(rgb), 1.0), gid);
}