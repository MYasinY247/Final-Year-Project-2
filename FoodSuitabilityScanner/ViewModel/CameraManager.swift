//
//  CameraManager.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import AVFoundation //working with time-based audiovisual media, I'm using the camera and barcode function


class CameraManager:NSObject {
    let session = AVCaptureSession()
    
    func requestPermission(){
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Camera access granted.")
                } else {
                    print("Camera access denied.")
                }
            }
        }
    }
    func start(){
        if !session.isRunning
        {
            session.startRunning()
        }
    }
    
    func stop(){
        if session.isRunning
        {
            session.stopRunning()
        }
    }
    
}
