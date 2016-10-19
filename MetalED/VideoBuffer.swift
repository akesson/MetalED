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
    var frameNumber = 0
    
    var videoTextureCache : CVMetalTextureCache?
    
    init() {
        let device = GPU.device
        // Texture for Y
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &videoTextureCache)
        
        // Texture for CbCr
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &videoTextureCache)
    }
    
    func captureBuffer(_ sampleBuffer: CMSampleBuffer!, frameNumber: Int) {
        self.frameNumber = frameNumber
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Y: luma
        var yTextureRef : CVMetalTexture? = nil
        
        let yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer!, 0);
        let yHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer!, 0);
        
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  videoTextureCache!,
                                                  pixelBuffer!,
                                                  nil,
                                                  MTLPixelFormat.r8Unorm,
                                                  yWidth, yHeight, 0,
                                                  &yTextureRef)
        
        // CbCr: Cb and Cr are the blue-difference and red-difference chroma components /
        
        var cbcrTextureRef : CVMetalTexture? = nil
        
        let cbcrWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer!, 1);
        let cbcrHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer!, 1);
        
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  videoTextureCache!,
                                                  pixelBuffer!,
                                                  nil,
                                                  MTLPixelFormat.rg8Unorm,
                                                  cbcrWidth, cbcrHeight, 1,
                                                  &cbcrTextureRef)
        
        yTexture = CVMetalTextureGetTexture(yTextureRef!)
        cbcrTexture = CVMetalTextureGetTexture(cbcrTextureRef!)
    }
}
