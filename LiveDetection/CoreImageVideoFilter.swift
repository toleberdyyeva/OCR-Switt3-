//
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
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore

class CoreImageVideoFilter: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    
    var previewUIView:UIView?
    public var previewLayer: AVCaptureVideoPreviewLayer?
  
    
  var stillImageOutput = AVCaptureStillImageOutput()
  var applyFilter: ((CIImage) -> CIImage?)?
  var videoDisplayView: GLKView!
  var videoDisplayViewBounds: CGRect!
  var renderContext: CIContext!
  
  var avSession: AVCaptureSession?
  var sessionQueue: DispatchQueue!
  
  var detector: CIDetector?
  
    
    var takenImage :UIImage?
    var uiimage : UIImage?
    
  init(superview: UIView, applyFilterCallback: ((CIImage) -> CIImage?)?) {
    self.applyFilter = applyFilterCallback
//    
    videoDisplayView = GLKView(frame: superview.bounds, context: EAGLContext(api: .openGLES2))
    videoDisplayView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    videoDisplayView.frame = superview.bounds
    videoDisplayView.backgroundColor = UIColor.black
    superview.addSubview(videoDisplayView)
    superview.sendSubview(toBack: videoDisplayView)
    
    previewUIView = superview
    renderContext = CIContext(eaglContext: videoDisplayView.context)
    sessionQueue = DispatchQueue(label: "AVSessionQueue", attributes: [])
    
    videoDisplayView.bindDrawable()
    videoDisplayViewBounds = CGRect(x: 0, y: 0, width: videoDisplayView.drawableWidth, height: videoDisplayView.drawableHeight)
    
  }
    
  
  deinit {
    stopFiltering()
  }
  
  func startFiltering() {
    // Create a session if we don't already have one
    if avSession == nil {
        do {
            avSession = try createAVSession()
        } catch {
            print(error)
        }
    }
    // And kick it off
    avSession?.startRunning()
  }
    
    
    func isOn() -> Bool {
        if avSession == nil {
            return true
        }else{
            return false
        }
    }
  
  func stopFiltering() {
    // Stop the av session
    avSession?.stopRunning()
  }
  
    
  func createAVSession() throws -> AVCaptureSession {
    // Input from video camera
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    if (device?.isFocusModeSupported(.continuousAutoFocus))! {
        print("AUTO FOCUS _ TRUE")
    }else{
        print("AUTO FOCUS _ FALSE")
    }
    let input = try AVCaptureDeviceInput(device: device)
    
    // Start out with low quality
    let session = AVCaptureSession()
    session.sessionPreset = AVCaptureSessionPresetHigh
    
    // Output
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    
    // Join it all together
    session.addInput(input)
    session.addOutput(videoOutput)
//    let stillSettings = [AVVideoCodecJPEG:AVVideoCodecKey]
//    self.stillImageOutput.outputSettings = stillSettings
//    if (session.canAddOutput(self.stillImageOutput)){
//        session.addOutput(self.stillImageOutput)
//        print("ADDED stillImageOutput")
//    }else{
//        print("PROBLEM")
//    }
    
    return session
  }
    


  
  //MARK: <AVCaptureVideoDataOutputSampleBufferDelegate
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
    
    connection.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
    
    
    
//     Need to shimmy this through type-hell
    let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//     Force the type change - pass through opaque buffer
    let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
    let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
    
    let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
//    var sourceImage = CIImage()
//    stillImageOutput.captureStillImageAsynchronously(from: connection) {(sampleBuffer, error) -> Void in
//        print("photo captured")
//        connection.videoOrientation = AVCaptureVideoOrientation.prtrait
//        if (sampleBuffer == nil) {
//            print("capture photo is nil")
//        }else{
//            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//            // Create an image. Note : it will have an orientation = right !
//            sourceImage = CIImage(data: imageData!)! //, scale: 1.0, orientation: UIImageOrientation.up)!
//        }
//    }
    // Do some detection on the image
    let detectionResult = applyFilter?(sourceImage)
    var outputImage = sourceImage
    
    if detectionResult != nil {
      outputImage = detectionResult!
    }
    
    // Do some clipping
    var drawFrame = outputImage.extent    
    let top_offset = (drawFrame.height - (drawFrame.width / 0.56)) / 2
    drawFrame.origin.y = top_offset
    drawFrame.size.height = drawFrame.width / 0.56
//    drawFrame.size.width = videoDisplayView.frame.width
//    drawFrame.size.height = drawFrame.width / 0.56
    
    
    videoDisplayView.bindDrawable()
    if videoDisplayView.context != EAGLContext.current() {
      EAGLContext.setCurrent(videoDisplayView.context)
    }
    
    renderContext.draw(outputImage, in: videoDisplayViewBounds, from: drawFrame)
    videoDisplayView.display()


}
    

//    
//    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
//        
//        if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer){
//            let image = UIImage(data: imageData)
//            return image
//        }
//
//        
//        
////        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
////            var result_image = UIImage()
////            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
////            let context = CIContext()
////            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//////            if let image = context.createCGImage(ciImage, from: imageRect) {
//////                result_image = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation:  .down)
//////                return result_image
//////            }
////        }
//        return nil
//    }
    
    
    public func capturePhoto() -> Bool{
        print("CAPTURE")
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
        videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                    (sampleBuffer, error) -> Void in
                    print("photo captured")
        
                    videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
    
                    if (sampleBuffer == nil) {
                        print("capture photo is nil")
                        return
                    }
        
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    // Create an image. Note : it will have an orientation = right !
                    //, scale: 1.0, orientation: UIImageOrientation.up)!
                    self.setCapturedImage(UIImage(data: imageData!)!)
                }
                return true
            }
            else {
                return false
            }
        }

    
    
    func setCapturedImage(_ image : UIImage){
        self.takenImage = image
    }
    
    func getCapturedImage() -> UIImage {
        return self.takenImage!
    }
    

}

