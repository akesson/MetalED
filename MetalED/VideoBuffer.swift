//
//  VideoBuffer.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 15/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation
import CoreVideo
import CoreMedia


class VideoBuffer: CameraCaptureDelegate {
    
    var yTexture:MTLTexture?
    var cbcrTexture: MTLTexture?

    var videoTextureCache : Unmanaged<CVMetalTextureCacheRef>?
    
    init() {
        let device = GPU.device
        // Texture for Y
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &videoTextureCache)
        
        // Texture for CbCr
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &videoTextureCache)
        
    }
    
    func captureBuffer(sampleBuffer: CMSampleBuffer!) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Y: luma
        var yTextureRef : Unmanaged<CVMetalTextureRef>?
        
        let yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer!, 0);
        let yHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer!, 0);
        
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  videoTextureCache!.takeUnretainedValue(),
                                                  pixelBuffer!,
                                                  nil,
                                                  MTLPixelFormat.R8Unorm,
                                                  yWidth, yHeight, 0,
                                                  &yTextureRef)
        
        // CbCr: Cb and Cr are the blue-difference and red-difference chroma components /
        
        var cbcrTextureRef : Unmanaged<CVMetalTextureRef>?
        
        let cbcrWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer!, 1);
        let cbcrHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer!, 1);
        
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  videoTextureCache!.takeUnretainedValue(),
                                                  pixelBuffer!,
                                                  nil,
                                                  MTLPixelFormat.RG8Unorm,
                                                  cbcrWidth, cbcrHeight, 1,
                                                  &cbcrTextureRef)
        
        yTexture = CVMetalTextureGetTexture((yTextureRef?.takeUnretainedValue())!)
        cbcrTexture = CVMetalTextureGetTexture((cbcrTextureRef?.takeUnretainedValue())!)
        
        yTextureRef?.release()
        cbcrTextureRef?.release()
    }
}