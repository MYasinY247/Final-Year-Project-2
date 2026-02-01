//
//  Camera.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI

struct ScanView: View {
    private let cameraManager = CameraManager()
    var body: some View {
        CameraPreview(session: cameraManager.session)
            .edgesIgnoringSafeArea(.all) // Ensure the preview layer fills the screen

            .onAppear {
                cameraManager.requestPermission()
                cameraManager.configureSession()
                
                cameraManager.onBarcodeScan = { result in
                    print("Scanned barcode ", result)
                }
                cameraManager.start()
            }
            .onDisappear{
                cameraManager.stop()
            }
    }
}
#Preview {
    ScanView()
}

