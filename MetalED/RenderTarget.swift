//
//  RenderTarget.swift
//  MetalED
//
//  Created by Henrik Akesson on 05/06/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import MetalKit

class RenderTarget {
    let texture: MTLTexture
    let descriptor: MTLRenderPassDescriptor
    
    init(_ texture: MTLTexture) {
        self.texture = texture
        self.descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = texture
        descriptor.colorAttachments[0].loadAction = .DontCare
        descriptor.colorAttachments[0].storeAction = .Store
    }
    
    init(_ texture: MTLTexture, _ descriptor: MTLRenderPassDescriptor) {
        self.texture = texture
        self.descriptor = descriptor
    }
}
