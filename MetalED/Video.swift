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
    
    let url: URL
    let assetReader: AVAssetReader
    let trackOutput: AVAssetReaderVideoCompositionOutput
    let frameRate:Float
    
    var frameNumber:Int { return _frameNumber }
    fileprivate var _frameNumber = 0
    
    init(url: URL) {
        let asset = AVURLAsset(url: url, options: nil)
        self.url = url
        
        let track = asset.tracks[1]
        if track.mediaType != "vide" {
            print("Track wasnt a video")
        }

        frameRate = track.nominalFrameRate
        print("FPS: \(frameRate)")
        
        let settings: [String : AnyObject] = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange as UInt32)]
        
        trackOutput = AVAssetReaderVideoCompositionOutput(videoTracks: [asset.tracks[1]], videoSettings: settings)
        trackOutput.videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        
        assetReader = try! AVAssetReader(asset: asset)
        assert(assetReader.canAdd(trackOutput))
        
        assetReader.add(trackOutput)
    }


    mutating func nextFrame() -> CMSampleBuffer? {
        if (assetReader.status == .completed) {
            cleanup()
            return nil
        }
        
        if (assetReader.status != .reading) {
            assert(assetReader.startReading())
            assert(assetReader.status == .reading)
        }
        _frameNumber += 1
        let sampleBuffer = trackOutput.copyNextSampleBuffer()
        return sampleBuffer
    }
    
    func cleanup() {
        if (url as NSURL).checkResourceIsReachableAndReturnError(nil) {
            try! FileManager.default.removeItem(at: url)
        }
    }
}
