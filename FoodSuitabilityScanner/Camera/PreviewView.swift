//
//  PreviewView.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import SwiftUI
import AVFoundation

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}


