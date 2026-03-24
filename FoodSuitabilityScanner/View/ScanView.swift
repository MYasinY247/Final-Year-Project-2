//
//  Camera.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ScanView: View {
    @EnvironmentObject private var diet: DietaryPreferencesModel
    @Environment(\.modelContext) private var modelContext
    @State var scannedProduct = ""
    @State private var cameraManager = CameraManager()
    @State private var scanMode = CameraManager.ScanMode.idle
    
    @State private var isHapticOn = false
    @State private var isTorchOn = false
    @State private var isSpeechOn = false
    @State private var resultPopup = false
    @State private var scanResultData: ScanResultData? = nil

    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let haptic = UINotificationFeedbackGenerator()
    
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
                        .offset(y:-19)
                        .blendMode(.destinationOut)
            )
        )
                .edgesIgnoringSafeArea(.all)
            
            //scan border box
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white)
                .frame(width: 300, height: 200)
            
            VStack{
                //top row of buttons
                HStack(spacing: 24){
                    //flashlight
                    CameraIconButton(icon:isTorchOn ? "bolt.fill" : "bolt.slash.fill", isActive: isTorchOn){
                        toggleTorch()
                    }
                    
                    //hapric feedback
                    CameraIconButton(icon: "iphone.radiowaves.left.and.right" , isActive: isHapticOn){
                        isHapticOn.toggle()
                            
                        
                        
                    }
                    
                    
                    //text to speech
                    CameraIconButton(icon: isSpeechOn ? "speaker.wave.3.fill" : "speaker.wave.2", isActive: isSpeechOn){
                        isSpeechOn.toggle()
                    }
                    
                }
                .padding()
                
                
                Spacer()
                if !scannedProduct.isEmpty{
                    Text(scannedProduct)
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                // barcode and ingredient buttons
                HStack(spacing: 40){
                    ButtonMode(icon: "barcode.viewfinder", label: "Barcode", isActive: scanMode == .barcode){
                        scanMode = .barcode
                        scannedProduct = ""
                        cameraManager.switchCameraMode(to: .barcode)
                    }
                    
                    ButtonMode(icon:"text.viewfinder", label: "Ingredients", isActive: scanMode == .ingredients){
                        scanMode = .ingredients
                        scannedProduct = ""
                        cameraManager.switchCameraMode(to: .ingredients)

                    }
                    
                }
                .padding()
            }
            //pop up
            if resultPopup, let data = scanResultData {
                ScanResultPopUp(data: data, isSpeechOn: isSpeechOn){
                    isTorchOn = false
                    resultPopup = false
                    scanResultData = nil
                    cameraManager.switchCameraMode(to: scanMode)
                }
                
            }
        }
                .onAppear {
                    cameraManager.requestPermission()
                    haptic.prepare()
                  
                    cameraManager.switchCameraMode(to: scanMode)
                    
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
                                        let result = SuitabilityChecker.check(product: product, filters: diet.activeFilters)
                                        
                                        let resultString : String
                                        let flagged : String
                                        
                                        switch result{
                                        case .suitable:
                                            resultString = "Suitable"
                                            flagged = ""
                                        case .notSuitable(reasons: let reasons):
                                            resultString = "Not Suitable"
                                            flagged = reasons.joined(separator: ", ")
                                        case .unknown:
                                            resultString = "Unknown"
                                            flagged = ""
                                        }
                                        //haptic feedback on successful scan
                                        if isHapticOn{
                                            haptic.notificationOccurred(.success)
                                        }
                                        let entry = ScannedProduct(productName: name, dateScanned: Date(), suitabilityResult: resultString, flaggedIngredients: flagged, imageURL: product.image_url ?? "", activeFilters: diet.activeFilters.joined(separator: ", "))
                                        modelContext.insert(entry)
                                        
                                        //show result pop up
                                        scanResultData = ScanResultData(productName: name, imageURL: product.image_url ?? "", ingredients: product.ingredients_text ?? "No ingredients available", result: result, flaggedIngredients: flagged)
                                        resultPopup = true
                                    }
                                    
                                case .failure:
                                    if isHapticOn{
                                        haptic.notificationOccurred(.error)
                                    }
                                    scanResultData = ScanResultData(productName: "Product Not Found", imageURL: "", ingredients: "This product could not be found on the database. Try scanning again or use the ingredient scanner.", result: .unknown, flaggedIngredients: "")
                                    resultPopup = true
                                }
                            }
                        }
                        
                    }
                    //ingredient scanning
                    cameraManager.onIngredientScan = {
                        scannedText in guard scanMode == .ingredients else { return }
                        
                        let result = SuitabilityChecker.checkRawIngredients(text: scannedText, filters: diet.activeFilters)
                        let flagged : String
                        
                        switch result{

                        case .notSuitable(let reasons):
                            flagged = reasons.joined(separator: ", ")
                            cameraManager.stop()
                            
                        default:
                            flagged = ""
                        }
                        scanResultData = ScanResultData(productName: "", imageURL: "", ingredients: scannedText, result: result, flaggedIngredients: flagged)
                        resultPopup = true
                    
                        
                    }
                    
                }
                .onDisappear{
                    cameraManager.stop()
                    scannedProduct = ""
                    if isTorchOn {toggleTorch()}
                }
        
        
            
        
    }
    //torch
    private func toggleTorch(){
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        isTorchOn.toggle()
        device.torchMode = isTorchOn ? .on : .off
        device.unlockForConfiguration( )
    }
    
}

//camera button row
struct CameraIconButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View{
        Button(action:action){
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .yellow : .white)
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
    }
    
}
// barcode and ingredient button
struct ButtonMode: View {
    let icon : String
    let label : String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            VStack(spacing:8){
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isActive ? .black : .white)
            .frame(width: 90, height: 90)
            .background(isActive ? Color.green : Color.black.opacity(0.5))
            .clipShape(Circle())
        }
    }
}
#Preview {
    ScanView()
        .environmentObject(DietaryPreferencesModel())
}

