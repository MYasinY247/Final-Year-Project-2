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
    var onIngredientScan: ((String)->Void)? //closure
    private var barcodeScan = false
    private var processingIngredient = false
    private let videoOutput = AVCaptureVideoDataOutput()
    var scanMode: ScanMode = .idle
    let metadataOutput = AVCaptureMetadataOutput()
    
    enum ScanMode {
        case idle
        case barcode
        case ingredients
    }
    
    
    func requestPermission(){ //permission handling to access the camera, no logging required
        AVCaptureDevice.requestAccess(for: .video){_ in}
        
    }
    func start(){ //starting capture session
        DispatchQueue.global(qos: .userInitiated).async {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
        }
    }
    
    func stop(){ //ending capture session
        if session.isRunning
        {
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
            }
        }
        
        switch scanMode {
            
        case .idle:
            break
        
        case .barcode:
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                
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
                
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }
        }
        session.commitConfiguration()
    }
    
    //stops scanning when barcode is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard !barcodeScan else { return }
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let barcodeValue = metadataObject.stringValue else { return }
        
        barcodeScan = true
        stop() // might remove for a responsive camera scan rather than freezing each time
        
        onBarcodeScan?(barcodeValue)
    }
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let keywords = ["ingredients", "contains:", "contain"]
        guard scanMode == .ingredients else { return }
        guard !processingIngredient else { return }
        
        self.processingIngredient = true
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.processingIngredient = false
            return
        }
        
        let request = VNRecognizeTextRequest{ (request, error) in
            
            
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedText = observations.compactMap{observations in observations.topCandidates(1).first?.string}.joined(separator: "\n")
            
            let scannedText = recognizedText.lowercased()
            
            if let keyword = keywords.first (where: {scannedText.contains($0)}){
                let parts = recognizedText.components(separatedBy: keyword)
                if parts.count>1{
                    let ingredientSection = parts[1].lowercased()
                    
                    let knownIngredients = SuitabilityChecker.nonVeganIngredients + SuitabilityChecker.nonVegetarianIngredients + SuitabilityChecker.nonPescatarianIngredients + SuitabilityChecker.dairy + SuitabilityChecker.nut + SuitabilityChecker.gluten + SuitabilityChecker.otherAnimal + SuitabilityChecker.haramIngredients + SuitabilityChecker.nonKosherIngredients
                    
                    let found = knownIngredients.filter{ingredient in ingredientSection.contains(ingredient)}
                    
                    if !found.isEmpty{
                        DispatchQueue.main.async{
                            self.onIngredientScan?(found.joined(separator: ", "))
                        }
                    
                    }
            
                }
            }
            self.processingIngredient = false
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
   
    
    func switchCameraMode(to newMode : ScanMode){
        stop()
        barcodeScan = false
        scanMode = newMode
        configureSession()
        start()
    }
    
    
}
