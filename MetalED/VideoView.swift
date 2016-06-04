//
//  VideoView.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 14/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation
import MetalKit
import MetalPerformanceShaders


class VideoView:MTKView {

    let colorConvert: ImageYCbCr2RGB
    
    let videoBuffer:VideoBuffer
    let workTexture1: MTLTexture
    let workTexture2: MTLTexture
    
    let kernels:[MPSUnaryImageKernel];

    required init(frame: CGRect) {
        videoBuffer = VideoBuffer()
        colorConvert = ImageYCbCr2RGB()
        
        workTexture1 = GPU.newTexture(width: 1920, height: 1080)
        workTexture2 = GPU.newTexture(width: 1920, height: 1080)

        kernels = [
            MPSImageGaussianBlur(device: GPU.device, sigma: 2),
            //MPSImageSobel(device: GPU.device),
            ImageSobelAndDiZenzoCumani()
        ]

        super.init(frame: frame, device:  GPU.device)
        framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: CGRect) {
        guard let drawable = currentDrawable, ytexture = videoBuffer.yTexture, cbcrTexture = videoBuffer.cbcrTexture else {
            return
        }
        
        let commandBuffer = GPU.commandBuffer()
        
        var inTexture = workTexture1
        var outTexture = kernels.isEmpty ? drawable.texture : workTexture2

        colorConvert.encodeToCommandBuffer(commandBuffer, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: outTexture)
        
        for kernel in kernels {
            let last = kernel == kernels.last
            swap(&inTexture, &outTexture)
            kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: inTexture, destinationTexture: last ? drawable.texture : outTexture)
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit();
    }
}
