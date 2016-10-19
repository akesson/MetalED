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
    
    override func viewWillDisappear(_ animated: Bool) {
        //cleanup temporary videos created by the image picker
        try! Directory.temporary().deleteAll()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func onVideoTapped() {
        startMediaBrowserFromViewController(self, usingDelegate: self)
    }
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        present(mediaUI, animated: true, completion: nil)
        return true
    }
}


// MARK: - UINavigationControllerDelegate
extension ChoiceViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ChoiceViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true) {
            if mediaType == kUTTypeMovie {
                let videoURL = info[UIImagePickerControllerMediaURL] as! URL
                self.video = Video(url: videoURL)
                self.performSegue(withIdentifier: "segueToVideoViewController", sender: self)
            }
        }
    }
}

extension ChoiceViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVideoViewController" {
            let controller = segue.destination as! VideoViewController
            controller.video = self.video
        }
    }
}
