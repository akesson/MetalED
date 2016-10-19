//
//  VideoViewController.swift
//  MetalED
//
//  Created by Henrik Akesson on 30/07/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    var video:Video!
    let videoView = VideoView(frame: CGRect.zero)
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(videoView)
        timer = Timer.scheduledTimer(timeInterval: Double(1.0/video.frameRate), target: self, selector: #selector(VideoViewController.nextFrame), userInfo: nil, repeats: true)
        
        nextFrame()
    }
    
    func nextFrame() {
        if let frame = self.video.nextFrame() {
            self.videoView.videoBuffer.captureBuffer(frame, frameNumber: self.video.frameNumber)
        } else {
            self.timer?.invalidate()
            print("Finished video")
        }
    }
    
    override func viewDidLayoutSubviews() {
        videoView.frame = view.bounds
        videoView.drawableSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height * 2)
        print("frame: \(videoView.frame) drawableSize: \(videoView.drawableSize)")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscapeLeft
    }
}
