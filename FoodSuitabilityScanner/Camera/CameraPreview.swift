//
//  CameraPreview.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import SwiftUI
import AVFoundation


//SwiftUI doesn't have a camera preview so UIKit is used here alongside SwiftUI
struct CameraPreview: UIViewRepresentable {
    var session : AVCaptureSession
    var metadataOutput : AVCaptureMetadataOutput //restricting camera to scan within the scan box area
    
    //shows camera feed via UIView
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        
        //connect camera to preview layer
        view.videoPreviewLayer.session = session
        
        //resizes aspect ratio for camera to fit entire screen
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
         }
    
    //called when UI is updated, keeps scan box aligned
    func updateUIView(_ uiView: PreviewView, context: Context) {
        
        //runs on main thread cos we're working with UI
        DispatchQueue.main.async {
            
            //making scan box
            let width = CGFloat(300)
            let height = CGFloat(200)
            
            //position the scan box in the centre
            let scanRect = CGRect(x: (uiView.bounds.width - width) / 2 ,
                                  y: (uiView.bounds.height - height) / 2,
                                  width: width,
                                  height: height
            )
            
            //barcode scanner only scans within the box area, converts scan box area to be in line with camera coordinates
            let conversion = uiView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
            metadataOutput.rectOfInterest = conversion
        }

    }
}




