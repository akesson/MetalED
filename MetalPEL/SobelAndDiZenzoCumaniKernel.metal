//
//  PEL.metal
//  MetalPEL
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
 Uses Sobel for calculating the edges for RGB and calculates the magnitude by using the DiZenzo-Cumani algo.
 */

kernel void SobelAndDiZenzoCumani(texture2d<float, access::read> inTexture [[texture(0)]],
                texture2d<float, access::write> outTexture [[texture(1)]],
                uint2 gid [[thread_position_in_grid]])
{
    uint x = gid[0];
    uint y = gid[1];
    
    /* Sobel convolution naming
    ----------------------------------------
    | -1,-1 (11) | -1, 0 (12) | -1,+1 (13) |
    ----------------------------------------
    |  0,-1 (21) |  0, 0 (22) |  0,+1 (23) |
    ----------------------------------------
    | +1,-1 (31) | +1, 0 (32) | +1,+1 (33) |
    ----------------------------------------
    */
    
    float3 m11 = inTexture.read(uint2(x+1, y-1)).rgb;
    float3 m12 = inTexture.read(uint2(x  , y+1)).rgb;
    float3 m13 = inTexture.read(uint2(x+1, y+1)).rgb;
    float3 m21 = inTexture.read(uint2(x-1, y  )).rgb;
    float3 m23 = inTexture.read(uint2(x+1, y  )).rgb;
    float3 m31 = inTexture.read(uint2(x-1, y-1)).rgb;
    float3 m32 = inTexture.read(uint2(x  , y-1)).rgb;
    float3 m33 = inTexture.read(uint2(x+1, y-1)).rgb;
    
    float3 m31m13 = m31 - m13;
    float3 m11m33 = m33 - m11;
    float3 m32m12 = m32 - m12;
    float3 m21m23 = m21 - m23;
    float3 H = m32m12 + m32m12 + m11m33 + m31m13;
    float3 V = m21m23 + m21m23 - m11m33 + m31m13;

    //contains sobel values for the three color channels
    //float3 sobel = sqrt(H*H+V*V);

    float AA = H.r * H.r + H.g * H.g + H.b * H.b;
    float BB = V.r * V.r + V.g * V.g + V.b * V.b;
    float CC = H.r * V.r + H.g * V.g + H.b * V.b;
    
    float mag = sqrt(0.5 * (AA + BB + sqrt( (AA-BB) * (AA-BB) + 4 * CC * CC)));
    
    outTexture.write(float4(mag, mag, mag, 1.0), gid);
}
