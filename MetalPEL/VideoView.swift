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
    var pipelineState: MTLComputePipelineState!
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
    var threadgroupsPerGrid: MTLSize!
    
    var blur: MPSImageGaussianBlur!
    var sobel: MPSImageSobel!
    var pel: ImageED!
    var colorConvert: ImageYCbCr2RGB!
    
    let videoBuffer:VideoBuffer
    var workTexture1: MTLTexture?
    var workTexture2: MTLTexture?

    override var drawableSize: CGSize {
        didSet {
            threadgroupsPerGrid = MTLSizeMake(Int(drawableSize.width) / threadsPerThreadgroup.width, Int(drawableSize.height) / threadsPerThreadgroup.height, 1)
        }
    }
    
    required init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        videoBuffer = VideoBuffer(frame: CGRectZero, device: device!)
        super.init(frame: frame, device:  device)
        framebufferOnly = false
        
        defaultLibrary = device!.newDefaultLibrary()!
        commandQueue = device!.newCommandQueue()
        
        let kernelFunction = defaultLibrary.newFunctionWithName("YCbCr2RGB")
        
        do {
            pipelineState = try device!.newComputePipelineStateWithFunction(kernelFunction!)
        } catch {
            fatalError("Unable to create pipeline state")
        }
        
        //let luminanceWeights: [Float] = [ 0.333, 0.334, 0.333 ]
        //sobel = MPSImageSobel(device: device!, linearGrayColorTransform: luminanceWeights)
        sobel = MPSImageSobel(device: device!)
        blur = MPSImageGaussianBlur(device: device!, sigma: 2)
        pel = ImageED(device: device!)
        colorConvert = ImageYCbCr2RGB(device: device!)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (workTexture1 == nil || workTexture2 == nil) {
            let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.BGRA8Unorm, width: Int(drawableSize.width), height: Int(drawableSize.height), mipmapped: false)
            workTexture1 = device!.newTextureWithDescriptor(desc)
            workTexture2 = device!.newTextureWithDescriptor(desc)
        }
    }
    
    func setBlurSigma(sigma: Float) {
        blur = MPSImageGaussianBlur(device: device!, sigma: sigma)
    }
    
    override func drawRect(dirtyRect: CGRect) {
        guard let drawable = currentDrawable, ytexture = videoBuffer.yTexture, cbcrTexture = videoBuffer.cbcrTexture else {
            return
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let inPlaceTexture = UnsafeMutablePointer<MTLTexture?>.alloc(1)
        inPlaceTexture.initialize(workTexture1)
        
        colorConvert.encodeToCommandBuffer(commandBuffer, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: workTexture1!)
        blur.encodeToCommandBuffer(commandBuffer, inPlaceTexture: inPlaceTexture, fallbackCopyAllocator: nil)
        sobel.encodeToCommandBuffer(commandBuffer, sourceTexture: workTexture1!, destinationTexture: workTexture2!)
        pel.encodeToCommandBuffer(commandBuffer, sourceTexture: workTexture2!, destinationTexture: drawable.texture)
        commandBuffer.presentDrawable(drawable)
        
        commandBuffer.commit();
    }
}
