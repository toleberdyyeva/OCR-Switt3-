//
//  OCRview.swift
//  LiveDetection
//
//  Created by Alisher Toleberdyyev on 07.06.17.
//  Copyright © 2017 ShinobiControls. All rights reserved.
//

import UIKit
import TesseractOCR

class OCRview: NSObject {
    
    func cropToBounds(image: UIImage, x:CGFloat , y :CGFloat , width: CGFloat, height: CGFloat) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let rect: CGRect = CGRect(x:x , y:y , width:width , height:height )
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image:UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return image
    }
    
    func designForView(view: UIView) {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 5
        view.layer.cornerRadius = 10
        view.layer.opacity = 0.6
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognation Progress \(tesseract.progress) %")
    }
    
    
    func performImageRecognition(_ image: UIImage) -> String {
        if let tesseract = G8Tesseract(language: "rus+kaz"){
//            tesseract.charWhitelist = "01234567890"
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
//            print(tesseract.recognizedText)
//            let text = self.filterForSearchOCR(text: tesseract.recognizedText).components(separatedBy: " ")
//            print(text)
            print(tesseract.recognizedText)
            return tesseract.recognizedText
        } else {
            return "null"
        }
    }
    
    
    func filterForSearchOCR(text:String) -> String {
        let rools = ["/","\n","\"",",","\\","°","’",".","‹","*","”","„","!","«","?","…","—","—",":","_","`","'"]
        var text_filter = text
        for (index,i) in rools.enumerated() {
            text_filter = text_filter.replacingOccurrences(of: i, with: "")
            print("Text Filtering - \((index+1)*(100/rools.count))%")
        }
        return text_filter
    }
    
    
    func searchIIN(_ iinArr : [String] ) -> [String] {
        var res:[String] =  []
        for (index,i) in iinArr.enumerated() {
            print("IIN Searching - \((index+1)*(100/iinArr.count))%")
            var item = i.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
            if item.digits.characters.count == 12 {
                res.append(item)
                break
            }else{
                if (item.digits.characters.count > 12 ) {
                    let dot = item.index(item.startIndex, offsetBy:12)
                    item = item.substring(to: dot)
                    print(item)
                    res.append(item)
                }
                
            }
        }
//        self.closModal()
        if (res.count > 0 ){
            return res
        }else{
            return []
        }
    }
}


extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
