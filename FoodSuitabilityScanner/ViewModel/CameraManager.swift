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
        DispatchQueue.global(qos: .userInitiated).async {
                if !self.session.isRunning {
                    print("sratr")
                    self.session.startRunning()
                }
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
    
    func configureSession(){
        session.beginConfiguration()
        session.sessionPreset = .high

        session.inputs.forEach{session.removeInput($0)}
        session.outputs.forEach{session.removeOutput($0)}

        
        if let videoInput = cameraSetUp() {
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("Video added")
            } else {
                print("Could not add video input to session")
            }
            
        } else{
            print("failed to input")
        }
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            print("metadata added")
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            let supportedTypes = metadataOutput.availableMetadataObjectTypes
            let desiredTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code128]
            
            metadataOutput.metadataObjectTypes = desiredTypes.filter{
                supportedTypes.contains( $0 )
            }
                    }
        session.commitConfiguration()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let barcodeValue = metadataObject.stringValue else { return }
        stop()
        onBarcodeScan?(barcodeValue)
    }
    
}
