//
//  CameraManager.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import AVFoundation //working with time-based audiovisual media, I'm using the camera and barcode function


class CameraManager:NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    var onBarcodeScan: ((String)->Void)? //used when a barcode is scanned
    private let metadataOutput = AVCaptureMetadataOutput()
    
    // makes permission
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
    
    func cameraSetUp() -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            print("Error setting up camera input: \(error)")
            return nil
        }
        
    }
    
}
