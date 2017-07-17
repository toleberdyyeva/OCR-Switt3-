
// Copyright 2014 Scott Logic
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import Foundation
import AVKit
import AVFoundation
import TesseractOCR


//public protocol CameraControllerProtocol {
////    func cameraSessionPreview(sampleBuffer: CMSampleBuffer!)
//    func pictureCaptured(image: UIImage)
//}



extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    let imageProcessor = ImageProcessor()
    
    
    @IBOutlet weak var modal_for_scan: UIView!
    @IBOutlet weak var modal_for_scan_label: UILabel!
    @IBOutlet weak var modal_for_scan_indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var modal_retake_btn: UIButton!
    
    
    
    var taked : Bool = false
    var takenPhoto:UIImage!
    var videoFilter: CoreImageVideoFilter?
    var detector: CIDetector?
    
    

    
    var counter = 0
    var frame_template:UIView = UIView(frame: CGRect(x: 15, y: 100, width: UIScreen.main.bounds.width-30 , height: (UIScreen.main.bounds.width-30)/1.58))
    
    
    override func viewWillAppear(_ animated: Bool) {
        videoFilter?.startFiltering()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create the video filter
        videoFilter = CoreImageVideoFilter(superview: self.view, applyFilterCallback: nil)
        // Simulate a tap on the mode selector to start the process
        self.frame_template.layer.borderWidth = 3
        self.frame_template.layer.borderColor = UIColor.white.cgColor
        self.frame_template.layer.cornerRadius = 5
        self.frame_template.layer.opacity = 0.3
//        self.view.addSubview(frame_template)
        handleDetectorSelectionChange()
    }
    
    // Capture a photo, using full resolution of the lens
    
    

    @IBAction func retakeOCR(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) { 
            self.modal_for_scan.alpha = 0.0
            self.modal_for_scan_indicator.alpha = 1.0
            self.counter = 0
        }
    }

    

    
    func handleDetectorSelectionChange() {
        if let videoFilter = videoFilter {
            videoFilter.stopFiltering()
            detector = prepareRectangleDetector()
            videoFilter.applyFilter = {image in return self.performRectangleDetection(image)}
            videoFilter.startFiltering()
        }
    }
    
    
    //MARK: Utility methods
    func performRectangleDetection(_ image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        if let detector = detector {
            // Get the detections
            let features = detector.features(in: image)
            for feature in features as! [CIRectangleFeature] {
                resultImage = drawHighlightOverlayForPoints(image, topLeft: feature.topLeft, topRight: feature.topRight,bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
            }
        }
        return resultImage
    }

    
    func prepareRectangleDetector() -> CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.0]
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage? {
            var overlay = CIImage(color: CIColor(red: 255/255, green: 255/255, blue:255/255, alpha: 0.3))
    
//            print(counter)
        
        
        let top_width = abs(topLeft.x - topRight.x)
        let left_side = top_width / 1.58
    
        if counter == 50 {
            videoFilter?.stopFiltering()
            DispatchQueue.main.sync {
                let croppedImage = self.cropAndTransformForCi(image: image, topLeft: topLeft, topRight: topRight,bottomLeft: bottomLeft, bottomRight: bottomRight)
                self.takenPhoto = croppedImage.g8_blackAndWhite()
//
                    UIView.animate(withDuration: 0.2, animations: {
                        self.modal_for_scan.alpha = 1.0
                        self.modal_for_scan_indicator.alpha = 1.0
                    }, completion: { (Bool) in
                        let res_text = self.performImageRecognition(self.takenPhoto)
                        self.modal_for_scan_indicator.alpha = 0.0
                        if res_text.isEmpty {
                            self.modal_for_scan_label.text = "Fail"
                        }else{
                            self.modal_for_scan_label.text = res_text[0]
                        }
                        self.videoFilter?.startFiltering()
                    })
                
                // чтобы перейти в режим разработки отметируй эту нижную строку и за коменть верхнию анимацию
//                self.performSegue(withIdentifier: "OCR", sender: nil)
                }
        }
        if (top_width >= 900 && left_side >= (900)/1.58 ) && (left_side < top_width) {
            overlay = CIImage(color: CIColor(red: 66/255, green: 244/255, blue:149/255, alpha: 0.4))
            self.counter += 1
        }else{
            self.counter = 0
        }
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                             withInputParameters: [
                                                "inputExtent": CIVector(cgRect: image.extent),
                                                "inputTopLeft": CIVector(cgPoint: topLeft),
                                                "inputTopRight": CIVector(cgPoint: topRight),
                                                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                                "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
        return overlay.compositingOverImage(image)
        
    }
    
    func performImageRecognition(_ image: UIImage) -> [String] {
        if let tesseract = G8Tesseract(language: "rus+kaz"){
            
            tesseract.image = image
            tesseract.charWhitelist = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
            tesseract.recognize()
            let text = tesseract.recognizedText.components(separatedBy: " ")
            print(text)
            let res = (self.searchIIN(text))
            print(res)
            return res
        } else {
            return []
        }
    }
    
    func searchIIN(_ iinArr : [String] ) -> [String] {
        var res:[String] =  []
        for i in iinArr {
            var item = i.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
            if item.digits.characters.count == 12 {
                res.append(item)
                return res
            }
            /*           то что написано ниже это бля на самый крайняк там поидее и так все норм рабоает так что от комента не убирайте */
             else{
                
                if (item.digits.characters.count > 12 ) {
                    let dot = item.index(item.startIndex, offsetBy:12)
                    item = item.substring(to: dot)
                    print("<<<<<")
                    print(item)
                    print("<<<<<")
                    res.append(item)
                }
             }
            
        }
        if (res.count > 0 ){
            return res
        }else{
            return []
        }
    }
    
    
    func cropAndTransformForCi(image: CIImage,  topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> UIImage  {
        let ciImage = image
        
        // Apply a Contrast filter
        let filter = CIFilter(name:"CIColorControls")
        filter!.setValue(ciImage, forKey:kCIInputImageKey)
        filter!.setValue(1.1, forKey:"inputContrast")
        let contrasted = filter!.outputImage!
        
        // create cgImage
        let context = CIContext(options:nil)
        
        // transform the image to have a rectangle
        var rectangleCoordinates = [String : Any]()
        rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: topLeft)
        rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: topRight)
        rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: bottomLeft)
        rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: bottomRight)
        let outputImage = contrasted.applyingFilter("CIPerspectiveCorrection", withInputParameters: rectangleCoordinates)
        
        // Create an uiimage
        let cgimg2 = context.createCGImage(outputImage, from: outputImage.extent)
        let uiimg = UIImage(cgImage: cgimg2!, scale:1, orientation: UIImageOrientation.down)
        return uiimg
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OCR" {
            let dest = segue.destination as! OCRviewctrl
            dest.takenPhoto = self.takenPhoto
        }
    }
    
   
}

