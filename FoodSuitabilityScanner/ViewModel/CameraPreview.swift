//
//  CameraPreview.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    var session = AVCaptureSession()
    
    func makeUIView(context: Context) -> UIView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
         }
    func updateUIView(_ uiView: UIView, context: Context) {
            // Make sure the preview layer resizes to match the bounds of the UIView

        }
    }


