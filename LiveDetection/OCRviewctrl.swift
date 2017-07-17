//
//  OCRviewctrl.swift
//  LiveDetection
//
//  Created by Alisher Toleberdyyev on 08.06.17.
//  Copyright © 2017 ShinobiControls. All rights reserved.
//

import UIKit
import TesseractOCR



class OCRviewctrl: UIViewController {

    var takenPhoto:UIImage?
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if takenPhoto != nil{
            
            self.takenPhoto = self.takenPhoto?.g8_blackAndWhite()
//            self.takenPhoto = self.takenPhoto?.g8_blackAndWhite()
//            self.takenPhoto = self.takenPhoto?.

            
            self.image.image = self.takenPhoto
            let ocr_result = self.performImageRecognition(self.takenPhoto!)
            print(ocr_result)
            print("READY FOR OCR")
            
            
        }else{
            print("NO IMAGE?")
        }

    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognation Progress \(tesseract.progress) %")
    }
    
    func performImageRecognition(_ image: UIImage) -> [String] {
        if let tesseract = G8Tesseract(language: "rus+kaz"){
            //            tesseract.charWhitelist = "01234567890"
//            tesseract.image = 
            tesseract.image = image
            tesseract.charWhitelist = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
//            tesseract.charBlacklist = "\n\n"
            tesseract.recognize()
            //            print(tesseract.recognizedText)
            let text = tesseract.recognizedText.components(separatedBy: " ")
            print(text)
            return self.searchIIN(text)
        } else {
            return []
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
        for i in iinArr {
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


