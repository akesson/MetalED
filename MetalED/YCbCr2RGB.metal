//
//  YCbCr2RGB.metal
//  MetalPEL
//
//  Created by Henrik Akesson on 15/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
#include "Common.metal"

using namespace metal;


fragment half4 YCbCr2RGB_Fragment(VertexOut       inFrag    [[ stage_in ]],
                                  texture2d<half> lumaTex   [[ texture(0) ]],
                                  texture2d<half> chromaTex [[ texture(1) ]],
                                  sampler         bilinear  [[ sampler(1) ]]) {
    
    half3 colorOffset = half3(-(16.0/255.0), -0.5, -0.5);
    half3x3 colorMatrix = half3x3(
                                  half3(1.164,  1.164, 1.164),
                                  half3(0.000, -0.392, 2.017),
                                  half3(1.596, -0.813, 0.000)
                                  );
    half3 yuv;
    yuv.x = lumaTex.sample(bilinear, inFrag.m_TexCoord).r;
    yuv.yz = chromaTex.sample(bilinear,inFrag.m_TexCoord).rg;
    half3 rgb = colorMatrix * (yuv + colorOffset);
    
    return half4(rgb, 1.0);
}

kernel void YCbCr2RGB_Kernel(texture2d<half, access::read>  lumaTex   [[ texture(0) ]],
                             texture2d<half, access::read>  chromaTex [[ texture(1) ]],
                             texture2d<half, access::write> outTex    [[ texture(2) ]],
                             uint2                          gid       [[thread_position_in_grid]]) {
        
   
    half3 colorOffset = half3(-(16.0/255.0), -0.5, -0.5);
    half3x3 colorMatrix = half3x3(
                                  half3(1.164,  1.164, 1.164),
                                  half3(0.000, -0.392, 2.017),
                                  half3(1.596, -0.813, 0.000)
                                );
    // half the size because we are using a 4:2:0 chroma subsampling
    uint2 chromaCoord = uint2(gid.x / 2, gid.y / 2);
    
    half y = lumaTex.read(gid).r;
    half2 cbcr = chromaTex.read(chromaCoord).rg;
    
    half3 ycbcr = half3(y, cbcr);
    
    half3 rgb = colorMatrix * (ycbcr + colorOffset);
    
    outTex.write(half4(half3(rgb), 1.0), gid);
}