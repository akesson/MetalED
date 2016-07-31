//
//  CameraController.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 14/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import Foundation
import AVFoundation

protocol CameraCaptureDelegate {
    func captureBuffer(sampleBuffer:CMSampleBuffer!, frameNumber: Int)
}

class CameraController:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var delegate:CameraCaptureDelegate? = nil
    let captureSession = AVCaptureSession()
    
    var running:Bool {
        get {
            return captureSession.running
        }
        set {
            if (newValue != captureSession.running) {
                newValue == true ? captureSession.startRunning() : captureSession.stopRunning()
            }
        }
    }
    
    override init() {
        super.init()
        captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            captureSession.addInput(input)
            
        } catch {
            print("can't access camera")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()

        videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        delegate?.captureBuffer(sampleBuffer, frameNumber: 0)
    }
}
