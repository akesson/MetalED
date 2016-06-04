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
    var commandQueue: MTLCommandQueue!
    
    let colorConvert: ImageYCbCr2RGB
    
    let videoBuffer:VideoBuffer
    let workTexture1: MTLTexture
    let workTexture2: MTLTexture
    
    let kernels:[MPSUnaryImageKernel];

    required init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        videoBuffer = VideoBuffer(frame: CGRectZero, device: device!)
        colorConvert = ImageYCbCr2RGB(device: device!)
        
        let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.BGRA8Unorm, width: Int(1920), height: Int(1080), mipmapped: false)
        workTexture1 = device!.newTextureWithDescriptor(desc)
        workTexture2 = device!.newTextureWithDescriptor(desc)

        kernels = [
            MPSImageGaussianBlur(device: device!, sigma: 2),
            //MPSImageSobel(device: device!),
            ImageSobelAndDiZenzoCumani(device: device!)
        ]

        super.init(frame: frame, device:  device)
        framebufferOnly = false
        
        commandQueue = device!.newCommandQueue()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: CGRect) {
        guard let drawable = currentDrawable, ytexture = videoBuffer.yTexture, cbcrTexture = videoBuffer.cbcrTexture else {
            return
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        
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
