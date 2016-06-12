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
    
    let colorConvert: YCbCr2RGB
    
    let videoBuffer:VideoBuffer
    let tmpTarget1: RenderTarget!
    let tmpTarget2: RenderTarget!
    var viewTarget: RenderTarget { //always recreated as the drawable is uing double buffering
        return RenderTarget(self.currentDrawable!.texture, self.currentRenderPassDescriptor!)
    }
    
    let kernels:[RenderProtocol];

    required init(frame: CGRect) {
        videoBuffer = VideoBuffer()
        
        tmpTarget1 = RenderTarget(GPU.newTexture(width: 1920, height: 1080))
        tmpTarget2 = RenderTarget(GPU.newTexture(width: 1920, height: 1080))
        
        //colorConvert = YCbCr2RGBKernel()
        colorConvert = YCbCr2RGBFragment()
        
        kernels = [
            MPSImageGaussianBlur(device: GPU.device, sigma: 2),
            //MPSImageSobel(device: GPU.device),
            SobelAndDiZenzoCumaniKernel()
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

        colorConvert.encodeToBuffer(commandBuffer, descriptor: outTexture.descriptor, yTexture: ytexture, cbcrTexture: cbcrTexture, outTexture: outTexture.texture)
        
        for (index,kernel) in kernels.enumerate() {
            let last = index == kernels.count - 1
            swap(&inTexture, &outTexture)
            kernel.encodeToBuffer(commandBuffer, renderDescriptor: outTexture.descriptor, inTexture: inTexture.texture, outTexture: (last ? viewTarget : outTexture).texture)
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit();
    }
}
