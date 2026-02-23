//
//  CameraPreview.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    var session : AVCaptureSession
    var metadataOutput : AVCaptureMetadataOutput
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
         }
    func updateUIView(_ uiView: PreviewView, context: Context) {
            // Makes sure the preview layer resizes to match the bounds of the UIView
        DispatchQueue.main.async {
            let width = CGFloat(300)
            let height = CGFloat(200)
            
            let scanRect = CGRect(x: (uiView.bounds.width - width) / 2 ,
                                  y: (uiView.bounds.height - height) / 2,
                                  width: width, height: height
            )
            let conversion = uiView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
            metadataOutput.rectOfInterest = conversion
        }

    }
}




