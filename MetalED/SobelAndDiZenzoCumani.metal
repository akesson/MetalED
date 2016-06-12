//
//  SobelAndDiZenzoCumani.metal
//  MetalED
//
//  Created by Henrik Akesson on 16/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
 Uses Sobel for calculating the edges for RGB and calculates the magnitude by using the DiZenzo-Cumani algo.
 */

kernel void SobelAndDiZenzoCumani_Kernel(texture2d<half, access::read> inTexture [[texture(0)]],
                texture2d<half, access::write> outTexture [[texture(1)]],
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
    
    half3 m11 = inTexture.read(uint2(x+1, y-1)).rgb;
    half3 m12 = inTexture.read(uint2(x  , y+1)).rgb;
    half3 m13 = inTexture.read(uint2(x+1, y+1)).rgb;
    half3 m21 = inTexture.read(uint2(x-1, y  )).rgb;
    half3 m23 = inTexture.read(uint2(x+1, y  )).rgb;
    half3 m31 = inTexture.read(uint2(x-1, y-1)).rgb;
    half3 m32 = inTexture.read(uint2(x  , y-1)).rgb;
    half3 m33 = inTexture.read(uint2(x+1, y-1)).rgb;
    
    half3 m31m13 = m31 - m13;
    half3 m11m33 = m33 - m11;
    half3 m32m12 = m32 - m12;
    half3 m21m23 = m21 - m23;
    half3 H = m32m12 + m32m12 + m11m33 + m31m13;
    half3 V = m21m23 + m21m23 - m11m33 + m31m13;

    //contains sobel values for the three color channels
    //half3 sobel = sqrt(H*H+V*V);

    half AA = H.r * H.r + H.g * H.g + H.b * H.b;
    half BB = V.r * V.r + V.g * V.g + V.b * V.b;
    half CC = H.r * V.r + H.g * V.g + H.b * V.b;
    
    half mag = sqrt(0.5 * (AA + BB + sqrt( (AA-BB) * (AA-BB) + 4 * CC * CC)));
    
    outTexture.write(half4(mag, mag, mag, 1.0), gid);
}
