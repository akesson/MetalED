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
    
    let videoBuffer:VideoBuffer

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
        
        let kernelFunction = defaultLibrary.newFunctionWithName("YCbCrColorConversion")
        
        do {
            pipelineState = try device!.newComputePipelineStateWithFunction(kernelFunction!)
        } catch {
            fatalError("Unable to create pipeline state")
        }
        
        blur = MPSImageGaussianBlur(device: device!, sigma: 0)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBlurSigma(sigma: Float) {
        blur = MPSImageGaussianBlur(device: device!, sigma: sigma)
    }
    
    override func drawRect(dirtyRect: CGRect) {
        guard let drawable = currentDrawable, ytexture = videoBuffer.yTexture, cbcrTexture = videoBuffer.cbcrTexture else {
            return
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(pipelineState)
        
        commandEncoder.setTexture(ytexture, atIndex: 0)
        commandEncoder.setTexture(cbcrTexture, atIndex: 1)
        commandEncoder.setTexture(drawable.texture, atIndex: 2) // out texture
        
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
        
        let inPlaceTexture = UnsafeMutablePointer<MTLTexture?>.alloc(1)
        inPlaceTexture.initialize(drawable.texture)
        
        blur.encodeToCommandBuffer(commandBuffer, inPlaceTexture: inPlaceTexture, fallbackCopyAllocator: nil)
        
        commandBuffer.presentDrawable(drawable)
        
        commandBuffer.commit();
    }
}
