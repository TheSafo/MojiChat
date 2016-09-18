//
//  BigImageVC.swift
//  MojiChat
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseDatabase

protocol BigImageDelegate {
    
    func didReactWithEmotion(emote: EmojiType)
}

class BigImageVC : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var delegate: BigImageDelegate? = nil
    
    let imageVw = UIImageView()
    
    init(imageURL: NSURL!) {
        super.init(nibName: nil, bundle: nil)
        
        imageVw.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "loading"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageVw)
        
        imageVw.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private var tmr: NSTimer! = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        tmr = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(takeReaction), userInfo: nil, repeats: false)
    }
    
    
    let session = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let stillCameraOutput = AVCaptureStillImageOutput()

    func takeReaction() {
        
#if (arch(i386) || arch(x86_64)) && os(iOS)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            //TODO: handle
            self.delegate?.didReactWithEmotion(.Neutral)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
#else
        session.sessionPreset = AVCaptureSessionPresetPhoto
    
        var frontCam: AVCaptureDevice! = nil
        
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Front {
                frontCam = device
            }
        }
        
        let possibleCameraInput: AnyObject? = try! AVCaptureDeviceInput(device: frontCam)
        if let actualInput = possibleCameraInput as? AVCaptureDeviceInput {
            if session.canAddInput(actualInput) {
                session.addInput(actualInput)
            }
        }
    
//        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
//        switch authorizationStatus {
//        case .NotDetermined:
//            // permission dialog not yet presented, request authorization
//            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
//                                                      completionHandler: { (granted:Bool) -> Void in
//                                                        if granted {
//                                                            // go ahead
//                                                        }
//                                                        else {
//                                                            // user denied, nothing much to do
//                                                        }
//            })
//        case .Authorized:
//        // go ahead
//            break
//        case .Denied, .Restricted:
//            // the user explicitly denied camera usage or is not allowed to access the camera devices
//            break
        
//        videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
//        if session.canAddOutput(videoOutput) {
//            session.addOutput(videoOutput)
//        }
    
        if session.canAddOutput(stillCameraOutput) {
            session.addOutput(stillCameraOutput)
        }
    
    
    session.startRunning()
//        glContext = EAGLContext(API: .OpenGLES2)
//        glView = GLKView(frame: viewFrame, context: glContext)
//        ciContext = CIContext(EAGLContext: glContext)
    
//    dispatch_async(sessionQueue) { () -> Void in
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { 
        
    
    
        let connection = self.stillCameraOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // update the video orientation to the device one
        connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue) ?? AVCaptureVideoOrientation.Portrait
        
        self.stillCameraOutput.captureStillImageAsynchronouslyFromConnection(connection) {
            (imageDataSampleBuffer, error) -> Void in
            
            if error == nil {
                
                // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                // we get the data already compressed as JPEG
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                // the sample buffer also contains the metadata, in case we want to modify it
//                let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)).takeUnretainedValue()
                
//                if let image = UIImage(data: imageData) {
                    // save the image or do something interesting with it
                    
                    self.handleReactionImage(imageData)
//                }
            }
            else {
                NSLog("error while capturing still image: \(error)")
            }
        }
    })

    
#endif
    }
    
    func handleReactionImage(imgData: NSData) {
        
        let storage = FIRStorage.storage()
        let fileName = "\(imgData.hash).jpg"
        let imgRef = storage.referenceForURL("gs://mojichat-afe91.appspot.com").child("images").child(fileName)
        
        let uploadTask = imgRef.putData(imgData)
        
        // Add a progress observer to an upload task
        let _ = uploadTask.observeStatus(.Success) { snapshot in
            
            
            imgRef.downloadURLWithCompletion({ (url, err) in
                
                
//
//                let dialogRef = FIRDatabase.database().reference().child("dialogs/\(self.dialogID)")
//                let msgInfo = ["type":"Photo", "url":url!.absoluteString, "sender":FIRAuth.auth()!.currentUser!.uid, "timestamp":NSDate().timeIntervalSinceReferenceDate, "wasRead":false]
//                dialogRef.updateChildValues(["\(curInd)":msgInfo])
//                self.currentIndex! += 1
            })
        }

    }
}