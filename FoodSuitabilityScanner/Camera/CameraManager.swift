//
//  CameraManager.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import AVFoundation // handles camera access, sessions and barcode detection
import SwiftUI
import Vision // handles OCR text recognition

//nso needed for the object
//and buffer delegate to work
//                               handles barcode detection               handles live video frames for ocr
class CameraManager:NSObject,AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session = AVCaptureSession() // main camera session that connects camera to barcode and video output
    
    //closures get called when barcode or ingredient is detected, they hold the string value of a barcode
    var onBarcodeScan: ((String)->Void)?
    var onIngredientScan: ((String)->Void)?
    
    var cameraSetUpFailed: (()->Void)? // if camera set up fails, a pop up alert will show
    
    private var barcodeScan = false //prevents multiple barcodes processing at once
    private var processingIngredient = false // prevents multiple video frames processing at once
    private let videoOutput = AVCaptureVideoDataOutput() // captures life video frames for ocr
    
    var scanMode: ScanMode = .idle //tracks the mode the camera is in
    let metadataOutput = AVCaptureMetadataOutput()//detect the barcode
    
    //the 3 modes the camera can be in
    enum ScanMode {
        case idle
        case barcode
        case ingredients
    }
    
    
    func requestPermission(){ //request permission to use camera, pops up only once for first time users
        AVCaptureDevice.requestAccess(for: .video){_ in}
        
    }
    func start(){ //starts camera session, user initiated, a high priority, user waiting for a response
        DispatchQueue.global(qos: .userInitiated).async {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
        }
    }
    
    func stop(){ //stops capture session
        if session.isRunning
        {
            session.stopRunning()
        }
    }
    
    // setting up camera as an input, returns nil if permission denied
    func cameraSetUp() -> AVCaptureDeviceInput? {
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
    
    //configures camera session based on current scan mode, clears existing inputs and outputs.
    func configureSession(){
        session.beginConfiguration()
        session.sessionPreset = .high

        //clearing existing inputs and outputs before reconfiguring
        session.inputs.forEach{session.removeInput($0)}
        session.outputs.forEach{session.removeOutput($0)}

        //camera added as video input
        if let videoInput = cameraSetUp() {
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)   
            }
            else{
                cameraSetUpFailed?()
            }
        } else {
            cameraSetUpFailed?()
        }
        
        
        switch scanMode {
            
            //camera on but no scanning
        case .idle:
            break
        
            
        case .barcode:
            //adds metadata for barcode scanner
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                // when camera detects barcode, this class is called
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                
                //only scan for common barcode types
                let supportedTypes = metadataOutput.availableMetadataObjectTypes
                let desiredTypes = [AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.upce] //common barcodes for euorpe and North America
                
                metadataOutput.metadataObjectTypes = desiredTypes.filter{
                    supportedTypes.contains( $0 )
                }
            }
        
        case .ingredients:
            //add video output to process individual frames for OCR to process
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                
                //frames processed on background thread to avoid it blocking the UI and keeping UI running smooth
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }
        }
        session.commitConfiguration()
    }
    
    //stops scanning when barcode is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //prevents multiple barcodes being processed
        guard !barcodeScan else { return }
        
        //extracts the barcode value as a string
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let barcodeValue = metadataObject.stringValue else { return }
        
        barcodeScan = true
        stop()
        
        //send barcode value to the scanView by using the closure
        onBarcodeScan?(barcodeValue)
    }
    
    
    //reads text frame to frame with OCR
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //keywords indicating the ingredient section on food packaging
        let keywords = ["ingredients", "contains:", "contain"]
        guard scanMode == .ingredients else { return }
        
        //frame is skipped if one is being processed
        guard !processingIngredient else { return }
        
        self.processingIngredient = true
        
        //extract pixel frame, raw image data from the camera to be processed
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.processingIngredient = false
            return
        }
        
        //creates a vision text recognition request
        let request = VNRecognizeTextRequest{ (request, error) in
            
            //gets the recognised text from the video
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            //joins all recognised text into a string
            let recognizedText = observations.compactMap{observations in observations.topCandidates(1).first?.string}.joined(separator: "\n")
            let scannedText = recognizedText.lowercased()
            
            //checks if ingredients are found in the scanned text
            if let keyword = keywords.first (where: {scannedText.contains($0)}){
                
                //splits text and takes info after "keywords" constant, removes non ingredient info
                let parts = recognizedText.components(separatedBy: keyword)
                if parts.count>1{
                    let ingredientSection = parts[1].lowercased()
                    
                    //builds a list of all known ingredients from Suitability Checker, removes any duplicates by using set
                    let knownIngredients = Array(Set(SuitabilityChecker.nonVeganIngredients + SuitabilityChecker.nonVegetarianIngredients + SuitabilityChecker.nonPescatarianIngredients + SuitabilityChecker.dairy + SuitabilityChecker.nut + SuitabilityChecker.gluten + SuitabilityChecker.otherAnimal + SuitabilityChecker.haramIngredients + SuitabilityChecker.nonKosherIngredients))
                    
                    //filters ingredients to ones found in the text
                    let found = knownIngredients.filter{ingredient in ingredientSection.contains(ingredient)}
                    
                    //only sends back results to scanview once known ingredients are found
                    if !found.isEmpty{
                        DispatchQueue.main.async{
                            self.onIngredientScan?(found.joined(separator: ", "))
                        }
                    
                    }
            
                }
            }
            self.processingIngredient = false
        }
        //performs text recognition request on current frame
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
   
    //switches camera mode by stopping, reconfiguring session and restarting
    func switchCameraMode(to newMode : ScanMode){
        stop()
        barcodeScan = false
        scanMode = newMode
        configureSession()
        start()
    }
    
    
}
