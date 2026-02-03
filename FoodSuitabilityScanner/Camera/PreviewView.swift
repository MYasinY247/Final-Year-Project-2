//
//  PreviewView.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import UIKit
import AVFoundation

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

//Build input file cannot be found: '/Users/yasin/Documents/Uni/Year 3/Semester 1/Final Year Project/Final Year Project/FoodSuitabilityScanner/FoodSuitabilityScanner/Info.plist'. Did you forget to declare this file as an output of a script phase or custom build rule which produces it?

