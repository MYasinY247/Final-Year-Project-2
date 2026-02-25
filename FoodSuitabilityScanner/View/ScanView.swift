//
//  Camera.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI

struct ScanView: View {
    @State var scannedProduct = ""
    @State private var cameraManager = CameraManager()
    @State private var scanMode = CameraManager.ScanMode.idle
    
    var body: some View {
        ZStack{
            CameraPreview(session: cameraManager.session,
                          metadataOutput: cameraManager.metadataOutput)
                .edgesIgnoringSafeArea(.all) // Ensure the preview layer fills the screen
            
            Color.black.opacity(0.6)
                .mask(Rectangle()
                    .overlay(
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 200)
                .blendMode(.destinationOut)
            )
        )
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white)
                .frame(width: 300, height: 200)
            
            VStack{
                Spacer()
                
                Text(scannedProduct.isEmpty ? "Scan a barcode" : "Scanned: \(scannedProduct)")
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                
                HStack(spacing: 40){
                    Button("Barcode"){
                        scanMode = .barcode
                        scannedProduct = ""
                        cameraManager.switchCameraMode(to: .barcode)
                    }
                    
                    Button("Ingredients"){
                        scanMode = .ingredients
                        scannedProduct = ""
                        cameraManager.switchCameraMode(to: .ingredients)
                        
                    }
                    
                }
                
                
                
            }
        }
                .onAppear {
                    cameraManager.requestPermission()
                    cameraManager.switchCameraMode(to: .idle)
                    
                    cameraManager.onBarcodeScan = { barcodeValue in
                        guard scanMode == .barcode else { return }
                        
                        BarcodeProcessor.getBarcode(barcode: barcodeValue) { result in
                            DispatchQueue.main.async{
                                switch result {
                                case .success(let product):
                                    let name = product.product_name ?? "Unknown"
                                    if name.isEmpty {
                                        scannedProduct = "Name not found on database"
                                    }
                                    else{
                                        scannedProduct = name
                                    }
                                    
                                case .failure(let error):
                                    scannedProduct = "product not found on database: \(error.localizedDescription)"
                                }
                            }
                        }
                        print("Scanned barcode ", barcodeValue)
                    }
                    
                }
                .onDisappear{
                    cameraManager.stop()
                    scannedProduct = ""
                }
            
        
    }
}
#Preview {
    ScanView()
}

