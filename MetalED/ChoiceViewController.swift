//
//  ChoiceViewController.swift
//  MetalED
//
//  Created by Henrik Akesson on 30/07/2016.
//  Copyright © 2016 Henrik Akesson. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChoiceViewController: UIViewController {

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction func onVideoTapped() {
        startMediaBrowserFromViewController(self, usingDelegate: self)
    }
    
    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .SavedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        presentViewController(mediaUI, animated: true, completion: nil)
        return true
    }

}


// MARK: - UINavigationControllerDelegate
extension ChoiceViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ChoiceViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismissViewControllerAnimated(true) {
            if mediaType == kUTTypeMovie {
                let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
                print("video: \(videoURL)")
                //TODO call method that decompresses the video and send it to the metal
            }
        }
    }
}