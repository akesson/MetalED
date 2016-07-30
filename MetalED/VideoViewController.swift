//
//  ViewController.swift
//  MetalPEL
//
//  Created by Henrik Akesson on 14/05/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import UIKit


class VideoViewController: UIViewController {

    let camera = CameraController()
    let videoView = VideoView(frame: CGRectZero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(videoView)
        
        camera.delegate = videoView.videoBuffer
        camera.running = true
    }

    override func viewDidLayoutSubviews() {
        videoView.frame = view.bounds
        videoView.drawableSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height * 2)
        print("frame: \(videoView.frame) drawableSize: \(videoView.drawableSize)")
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeLeft
    }
}

