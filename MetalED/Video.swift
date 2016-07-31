//
//  Video.swift
//  MetalED
//
//  Created by Henrik Akesson on 30/07/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import VideoToolbox

struct Video {
    
    let url: NSURL
    let assetReader: AVAssetReader
    let trackOutput: AVAssetReaderVideoCompositionOutput
    let frameRate:Float
    
    var frameNumber:Int { return _frameNumber }
    private var _frameNumber = 0
    
    init(url: NSURL) {
        let asset = AVURLAsset(URL: url, options: nil)
        self.url = url
        
        let track = asset.tracks[1]
        if track.mediaType != "vide" {
            print("Track wasnt a video")
        }

        frameRate = track.nominalFrameRate
        print("FPS: \(frameRate)")
        
        let settings: [String : AnyObject] = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        
        trackOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [asset.tracks[1]], videoSettings: settings)
        trackOutput.videoComposition = AVMutableVideoComposition(propertiesOfAsset: asset)
        
        assetReader = try! AVAssetReader(asset: asset)
        assert(assetReader.canAddOutput(trackOutput))
        
        assetReader.addOutput(trackOutput)
    }


    mutating func nextFrame() -> CMSampleBuffer? {
        if (assetReader.status == .Completed) {
            cleanup()
            return nil
        }
        
        if (assetReader.status != .Reading) {
            assert(assetReader.startReading())
            assert(assetReader.status == .Reading)
        }
        _frameNumber += 1
        let sampleBuffer = trackOutput.copyNextSampleBuffer()
        return sampleBuffer
    }
    
    func cleanup() {
        if url.checkResourceIsReachableAndReturnError(nil) {
            try! NSFileManager.defaultManager().removeItemAtURL(url)
        }
    }
}