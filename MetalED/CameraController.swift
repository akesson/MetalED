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
    func captureBuffer(_ sampleBuffer:CMSampleBuffer!, frameNumber: Int)
}

class CameraController:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var delegate:CameraCaptureDelegate? = nil
    let captureSession = AVCaptureSession()
    
    var running:Bool {
        get {
            return captureSession.isRunning
        }
        set {
            if (newValue != captureSession.isRunning) {
                newValue == true ? captureSession.startRunning() : captureSession.stopRunning()
            }
        }
    }
    
    override init() {
        super.init()
        captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            captureSession.addInput(input)
            
        } catch {
            print("can't access camera")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        delegate?.captureBuffer(sampleBuffer, frameNumber: 0)
    }
}
