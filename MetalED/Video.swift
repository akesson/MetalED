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

struct Video {
    
    let assetReader: AVAssetReader
    let trackOutput: AVAssetReaderTrackOutput
    
    init(url: NSURL) {
        let asset = AVURLAsset(URL: url, options: nil)
        
        let track = asset.tracks[1]
        if track.mediaType != "vide" {
            print("Track wasnt a video")
        }
        let settings: [String : AnyObject] = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
        
        trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)

        assetReader = try! AVAssetReader(asset: asset)
        assert(assetReader.canAddOutput(trackOutput))
        
        assetReader.addOutput(trackOutput)
    }


    func nextFrame() -> CMSampleBuffer? {
        if (assetReader.status == .Completed) {
            return nil
        }
        
        if (assetReader.status != .Reading) {
            assert(assetReader.startReading())
            assert(assetReader.status == .Reading)
        }
        
        return trackOutput.copyNextSampleBuffer()
    }
}