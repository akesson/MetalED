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

    var video: Video?
    
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
                self.video = Video(url: videoURL)
   
                /*
                var count = 0
                let start = NSDate()
                while self.video!.nextFrame() != nil {
                    count += 1
                }
                let end = NSDate()
                let time = end.timeIntervalSinceDate(start)
                let msPerFrame = time * 1000 / Double(count)
                print("Frames: \(count) frames in \(Int(msPerFrame))ms/frame")
                 */
                self.performSegueWithIdentifier("segueToVideoViewController", sender: self)
            }
        }
    }
}

extension ChoiceViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToVideoViewController" {
            let controller = segue.destinationViewController as! VideoViewController
            controller.video = self.video
        }
    }
}