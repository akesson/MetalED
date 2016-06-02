//
//  YCbCrKernel.metal
//  MetalPEL
//
//  Created by Henrik Akesson on 15/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;



kernel void YCbCr2RGB(texture2d<half, access::read> yTexture [[texture(0)]],
                      texture2d<half, access::read> cbcrTexture [[texture(1)]],
                      texture2d<half, access::write> outTexture [[texture(2)]],
                      uint2 gid [[thread_position_in_grid]])
{
    
    half3 colorOffset = half3(-(16.0/255.0), -0.5, -0.5);
    half3x3 colorMatrix = half3x3(
                                    half3(1.164,  1.164, 1.164),
                                    half3(0.000, -0.392, 2.017),
                                    half3(1.596, -0.813, 0.000)
                                    );
    
    uint2 cbcrCoordinates = uint2(gid.x / 2, gid.y / 2); // half the size because we are using a 4:2:0 chroma subsampling
    
    half y = yTexture.read(gid).r;
    half2 cbcr = cbcrTexture.read(cbcrCoordinates).rg;
    
    half3 ycbcr = half3(y, cbcr);
    
    half3 rgb = colorMatrix * (ycbcr + colorOffset);
    
    outTexture.write(half4(half3(rgb), 1.0), gid);
}