//
//  RenderProtocol.swift
//  MetalED
//
//  Created by Henrik Akesson on 12/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalPerformanceShaders

protocol RenderProtocol {
    func encodeToBuffer(_ commandBuffer: MTLCommandBuffer, renderDescriptor: MTLRenderPassDescriptor, inTexture: MTLTexture, outTexture: MTLTexture);
}
