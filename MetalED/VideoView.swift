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
    var commandQueue: MTLCommandQueue!
    var threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
    var threadgroupsPerGrid: MTLSize!
    
    let colorConvert: ImageYCbCr2RGB!
    
    let videoBuffer:VideoBuffer
    var workTexture1: MTLTexture?
    var workTexture2: MTLTexture?
    
    var kernels = [MPSUnaryImageKernel]();

    override var drawableSize: CGSize {
        didSet {
            threadgroupsPerGrid = MTLSizeMake(Int(drawableSize.width) / threadsPerThreadgroup.width, Int(drawableSize.height) / threadsPerThreadgroup.height, 1)
        }
    }
    
    required init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        videoBuffer = VideoBuffer(frame: CGRectZero, device: device!)
        colorConvert = ImageYCbCr2RGB(device: device!)
        super.init(frame: frame, device:  device)
        framebufferOnly = false
        
        commandQueue = device!.newCommandQueue()
        
        let defaultLibrary = device!.newDefaultLibrary()!
        let kernelFunction = defaultLibrary.newFunctionWithName("YCbCr2RGB")
        
        do {
            pipelineState = try device!.newComputePipelineStateWithFunction(kernelFunction!)
        } catch {
            fatalError("Unable to create pipeline state")
        }
        
        
        kernels.append(MPSImageGaussianBlur(device: device!, sigma: 2));
        //kernels.append(MPSImageSobel(device: device!));
        kernels.append(ImageSobelAndDiZenzoCumani(device: device!));
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
    
    override func drawRect(dirtyRect: CGRect) {
        guard let drawable = currentDrawable, ytexture = videoBuffer.yTexture, cbcrTexture = videoBuffer.cbcrTexture else {
            return
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let inPlaceTexture = UnsafeMutablePointer<MTLTexture?>.alloc(1)
        inPlaceTexture.initialize(workTexture1)
        
        var inTexture = workTexture1!
        var outTexture = workTexture2!

        if (kernels.count == 0) {
            colorConvert.encodeToCommandBuffer(commandBuffer, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: drawable.texture)
        } else {
            colorConvert.encodeToCommandBuffer(commandBuffer, yTexture: ytexture, cbcrTexture: cbcrTexture, destinationTexture: inTexture)
        }
        
        for kernel in kernels {
            if kernel == kernels.last {
                runKernel(kernel, commandBuffer: commandBuffer, inTexture: inTexture, outTexture: drawable.texture)
            } else {
                (inTexture, outTexture) = runKernel(kernel, commandBuffer: commandBuffer, inTexture: inTexture, outTexture: outTexture)
            }
        }
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit();
    }
    
    func runKernel(kernel: MPSUnaryImageKernel, commandBuffer: MTLCommandBuffer, inTexture: MTLTexture!, outTexture: MTLTexture!) -> (MTLTexture, MTLTexture) {
        kernel.encodeToCommandBuffer(commandBuffer, sourceTexture: inTexture, destinationTexture: outTexture)
        return (outTexture, inTexture)
    }
}
