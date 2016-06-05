//
//  VideoView.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 14/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

class VideoView:MTKView {
    
    let colorConvert: ImageYCbCr2RGB
    
    let videoBuffer:VideoBuffer
    let tmpTarget1: RenderTarget!
    let tmpTarget2: RenderTarget!
    var viewTarget: RenderTarget { //always recreated as the drawable is uing double buffering
        return RenderTarget(self.currentDrawable!.texture, self.currentRenderPassDescriptor!)
    }
    
    let kernels:[MPSUnaryImageKernel];

    required init(frame: CGRect) {
        videoBuffer = VideoBuffer()
        colorConvert = ImageYCbCr2RGB()
        
        tmpTarget1 = RenderTarget(GPU.newTexture(width: 1920, height: 1080))
        tmpTarget2 = RenderTarget(GPU.newTexture(width: 1920, height: 1080))
        
        kernels = [
            //MPSImageGaussianBlur(device: GPU.device, sigma: 2),
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
        
        var inTexture = tmpTarget1
        var outTexture = kernels.isEmpty ? viewTarget : tmpTarget2

        colorConvert.encodeToFragmentBuffer(commandBuffer, descriptor: outTexture.descriptor, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: outTexture.texture)
        //colorConvert.encodeToCommandBuffer(commandBuffer, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: outTexture.texture)
        
        for kernel in kernels {
            let last = kernel == kernels.last
            swap(&inTexture, &outTexture)
            kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: inTexture.texture, destinationTexture: (last ? viewTarget : outTexture).texture)
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit();
    }
}
