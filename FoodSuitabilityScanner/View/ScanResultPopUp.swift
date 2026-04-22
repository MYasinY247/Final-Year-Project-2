//
//  ScanResultPopUp.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 22/03/2026.
//

import SwiftUI
import AVFoundation

//needed to display result of scan, created in scanview and passed to scanresultpopup
struct ScanResultData{
    let productName: String
    let imageURL: String?
    let ingredients: String
    let result: SuitabilityResult
    let flaggedIngredients: String
    
    
}

//displays outcome of scan as an overlay, if tts enabled, result is read out
struct ScanResultPopUp: View {
    let data:ScanResultData
    var isSpeechOn : Bool // passed from scanview, tts is active if true
    let onDismiss: () -> Void  //called when user exits the popup
    
    private let speechSynthesizer = AVSpeechSynthesizer() // reads the result aloud
    
    //using if statement makes error, returns true if product is unknown
    var isUnknown: Bool{
        switch data.result {
        case .unknown:
            return true
        default:
            return false
        }
    }

    var body: some View
    {
        
        ZStack{
            //dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            //pop up
            VStack( spacing: 20){
                HStack{
                    //x button to dismiss
                    Spacer()
                    Button(action: onDismiss){
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                            .padding()
                            .clipShape(Circle())
                    }
                   
                    
                }
                // green tick, red X, amber triangle for unknown
                resultIcon
                    .font(.system(size: 50))
                    .padding()
                
                Divider()
                
                //result message beneath icon
                Text(resultTitle)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                //product info shown for suitable and unsuitable only, no useful info to show for unknown products
                if !isUnknown{
                    HStack(alignment: .top, spacing: 10){
                        //product image loaded from url
                        
                        AsyncImage(url: URL(string: data.imageURL ?? "")){ image in
                            image.resizable().scaledToFit()
                        }
                        placeholder: {
                            Image(systemName: "photo")
                                .foregroundStyle(Color.gray)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        
                        
                        VStack(alignment: .leading, spacing: 3){
                            //product name
                            Text(data.productName)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            //full ingredients
                            ScrollView{
                                Text(data.ingredients)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .frame(maxHeight: 50)
                            
                            //flagged ingredients shown in red
                            if !data.flaggedIngredients.isEmpty{
                                Text("Flagged: \(data.flaggedIngredients)")
                                    .font(.caption)
                                    .foregroundStyle(Color.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                        }
                        
                        
                    }
                    .padding()
                    
                }
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius:15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0))
            
            .padding()
            //result spoken if tts enabled
            .onAppear{
                if isSpeechOn{
                    speakResult()
                }
            }
            
        }
    }
    //returns icon depending on outcome
    private var resultIcon: some View {
        switch data.result {
        case .suitable:
            return Image(systemName: "checkmark")
                .foregroundStyle(Color(.systemGreen))
        case .notSuitable:
            return Image(systemName: "xmark")
                .foregroundStyle(Color(.systemRed))
        case .unknown:
            return Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color(.systemOrange))
        }
    }
    //returns result message to show beneath icon
    private var resultTitle: String{
        switch data.result{
        case .suitable:
            "This product is suitable for you"
        case .notSuitable:
            "This product is not suitable for you"
        case .unknown:
            "Status unclear, please double check the ingredients"
        }
    }
    
    
    //text to speech, for unsuitable results, includes the unsuitable ingredients
    private func speakResult(){
        var tts = ""
        switch data.result {
        case .notSuitable:
            tts = "\(data.productName). Flagged ingredients: \(data.flaggedIngredients)"
        case .suitable:
            tts = "\(data.productName) is suitable for you"
        case .unknown:
            tts = "Status unclear, please double check the ingredients"
        
        }
        //speaks the text in English
        let utterance = AVSpeechUtterance(string: tts)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
        
        
    }

}
