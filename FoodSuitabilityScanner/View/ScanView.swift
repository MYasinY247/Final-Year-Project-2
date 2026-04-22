//
//  ScanView.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ScanView: View {
    @EnvironmentObject private var diet: DietaryPreferencesModel  // shares dietary preferences across app
    @Environment(\.modelContext) private var modelContext // saves barcode scan records
    @State private var cameraManager = CameraManager()  //manage camera session
    @State private var scanMode = CameraManager.ScanMode.idle //track current scan mode
    
    //toggle camera accessibility top row
    @State private var isHapticOn = false
    @State private var isTorchOn = false
    @State private var isSpeechOn = false
    
    @State private var resultPopup = false //controls pop up overlay
    @State private var scanResultData: ScanResultData? = nil //holds info to display on popup

    @State private var showAlert: Bool = false //used for showing camera error
    
    private let speechSynthesizer = AVSpeechSynthesizer() // reads scan result aloud when activated
    private let haptic = UINotificationFeedbackGenerator() //vibrate phone after scan
    
    var body: some View {
        ZStack{
            CameraPreview(session: cameraManager.session,
                          metadataOutput: cameraManager.metadataOutput)
                .edgesIgnoringSafeArea(.all) // Ensure the preview layer fills the screen
            
            // dark overlay with a full bright middle section to guide user to scan in that region
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
            
            //scan border box placed in middle section
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
                
                // barcode and ingredient buttons, turns green when active
                HStack(spacing: 40){
                    ButtonMode(icon: "barcode.viewfinder", label: "Barcode", isActive: scanMode == .barcode){
                        scanMode = .barcode
                        
                        cameraManager.switchCameraMode(to: .barcode)
                    }
                    
                    ButtonMode(icon:"text.viewfinder", label: "Ingredients", isActive: scanMode == .ingredients){
                        scanMode = .ingredients
                        
                        cameraManager.switchCameraMode(to: .ingredients)

                    }
                    
                }
                .padding()
            }
            //pop up shows after every scan
            if resultPopup, let data = scanResultData {
                ScanResultPopUp(data: data, isSpeechOn: isSpeechOn){
                    isTorchOn = false
                    resultPopup = false
                    scanResultData = nil
                    cameraManager.switchCameraMode(to: scanMode) //resumes scanning when pop up exited
                }
                
            }
        }
                .onAppear {
                    cameraManager.requestPermission() // request camera access when launched
                    haptic.prepare() // gets haptic feedback ready when toggled on
                  
                    cameraManager.switchCameraMode(to: scanMode)
                    
                    //barcode scan closure called when barcode detected
                    cameraManager.onBarcodeScan = { barcodeValue in
                        guard scanMode == .barcode else { return }
                        
                        BarcodeProcessor.getBarcode(barcode: barcodeValue) { result in
                            DispatchQueue.main.async{
                                switch result {
                                case .success(let product):
                                    let name = product.product_name ?? "Unknown"
                                
                                    //evaluates product ingredients against the active dietary filters
                                    let result = SuitabilityChecker.check(product: product, filters: diet.activeDietaryFilters)
                                    
                                    let resultString : String
                                    let flagged : String
                                    
                                    // gets suitability result ready, extracts the flagged ingredients
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
                                    
                                    //saves to swiftdata, replaces name with a placeholder name if absent from OFF
                                    if name.isEmpty{
                                        let noNameEntry = ScannedProduct(productName: "Name not found", dateScanned: Date(), suitabilityResult: resultString, flaggedIngredients: flagged, imageURL: product.image_url ?? "", activeFilters: diet.activeDietaryFilters.joined(separator: ", "))
                                        modelContext.insert(noNameEntry)
                                    }
                                    else{
                                        let entry = ScannedProduct(productName: name, dateScanned: Date(), suitabilityResult: resultString, flaggedIngredients: flagged, imageURL: product.image_url ?? "", activeFilters: diet.activeDietaryFilters.joined(separator: ", "))
                                        modelContext.insert(entry)
                                    }
                                    
                                    
                                    //show result pop up
                                    scanResultData = ScanResultData(productName: name, imageURL: product.image_url ?? "", ingredients: product.ingredients_text ?? "No ingredients available", result: result, flaggedIngredients: flagged)
                                    resultPopup = true
                                    
                                    
                                case .failure:
                                    //error haptic and shows product not found
                                    if isHapticOn{
                                        haptic.notificationOccurred(.error)
                                    }
                                    scanResultData = ScanResultData(productName: "Product Not Found", imageURL: "", ingredients: "This product could not be found on the database. Try scanning again or use the ingredient scanner.", result: .unknown, flaggedIngredients: "")
                                    resultPopup = true
                                }
                            }
                        }
                        
                    }
                    //ingredient scanning when CameraManager detects ingredients
                    cameraManager.onIngredientScan = {
                        scannedText in guard scanMode == .ingredients else { return }
                        
                        //evaluate text directly, no OFF needed
                        let result = SuitabilityChecker.checkRawIngredients(text: scannedText, filters: diet.activeDietaryFilters)
                        let flagged : String
                        
                        switch result{

                        case .notSuitable(let reasons):
                            flagged = Array(Set(reasons)).joined(separator: ", ")
                            cameraManager.stop() //stops once app finds unsuitable ingredients
                            
                        default:
                            flagged = ""
                        }
                        // Not saved to SwiftData but needed for the pop up
                        scanResultData = ScanResultData(productName: "", imageURL: nil, ingredients: scannedText, result: result, flaggedIngredients: flagged)
                        resultPopup = true
                        
                    }
                    //shows alert if camera session failed
                    cameraManager.cameraSetUpFailed = {
                        showAlert = true
                    }
                    
                }
                //turns off torch and stops camera session when user leaves ScanView
                .onDisappear{
                    cameraManager.stop()
                    if isTorchOn {toggleTorch()}
                }
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Camera Set Up Error"),
                          message: Text("Unable to access camera or configure scanning capabilities. Please try again later."),
                          dismissButton: .default(Text("OK"))

                    )
                    
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

//camera button top row, yellow means active, white means deactivated
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
// barcode and ingredient button, green means in use
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

