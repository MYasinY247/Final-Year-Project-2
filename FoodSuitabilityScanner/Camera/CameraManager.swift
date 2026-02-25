//
//  CameraManager.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import AVFoundation //working with time-based audiovisual media, I'm using the camera and barcode function
import SwiftUI
import Vision

class CameraManager:NSObject,AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    var onBarcodeScan: ((String)->Void)? //closure
    private var isScan = false
    private let videoOutput = AVCaptureVideoDataOutput()
    var scanMode: ScanMode = .idle
    let metadataOutput = AVCaptureMetadataOutput()
    
    enum ScanMode {
        case idle
        case barcode
        case ingredients
    }
    
    
    func requestPermission(){ //permission handling
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
    func start(){ //starting capture session
        DispatchQueue.global(qos: .userInitiated).async {
                if !self.session.isRunning {
                    print("camera is running")
                    self.session.startRunning()
                }
        }
    }
    
    func stop(){ //ending capture session
        if session.isRunning
        {
            print("camera stopped running")
            session.stopRunning()
        }
    }
    
    func cameraSetUp() -> AVCaptureDeviceInput? { //setting up camera
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
    
    func configureSession(){ //makes camera session, adding video inpout and metadata output
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
        
        switch scanMode {
            
        case .idle:
            break
        
        case .barcode:
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
        
        case .ingredients:
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                print("video output added")
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }
        }
        session.commitConfiguration()
    }
    
    //stops scanning when barcode is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard !isScan else { return }
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let barcodeValue = metadataObject.stringValue else { return }
        
        isScan = true
        stop() // might remove for a responsive camera scan rather than freezing each time 
        
        onBarcodeScan?(barcodeValue)
    }
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard scanMode == .ingredients else { return }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNRecognizeTextRequest{ (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedText = observations.compactMap{observations in observations.topCandidates(1).first?.string}.joined(separator: "\n")
            
            self.onBarcodeScan?(recognizedText)
            
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        
        
    }
    
    func resetScan(){
        isScan = false
    }
    
    func switchCameraMode(to newMode : ScanMode){
        stop()
        resetScan()
        scanMode = newMode
        configureSession()
        start()
    }
    
    
}
