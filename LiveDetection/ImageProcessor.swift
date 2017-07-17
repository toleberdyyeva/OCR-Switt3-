//
//  ImageProcessor.swift
//  Filterer
//
//  Created by Patrick Riley on 1/16/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import Foundation

/**
 Define Filter Protocol
 **/

protocol FilterProtocol {
    var name: String { get set }
    func applyFilter(_ image: RGBAImage) -> RGBAImage
    func applyFilter(_ image: RGBAImage, factor: Int) -> RGBAImage
}

/**
 Define Filter Classes
 **/

class ContrastFilter: FilterProtocol {
    var name: String
    var contrastRatio: Int
    
    init(name: String){
        self.name = name
        self.contrastRatio = 1
    }
    
    init(name: String, factor: Int){
        self.name = name
        self.contrastRatio = factor
    }
    
    func applyFilter(_ image: RGBAImage) -> RGBAImage {
        return contrastFilter(self.contrastRatio, image: image);
    }
    func applyFilter(_ image: RGBAImage, factor: Int) -> RGBAImage {
        return contrastFilter(factor, image: image);
    }
    
    func contrastFilter(_ contrastRatio: Int, image: RGBAImage) -> RGBAImage {
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                
                var pixel = image.pixels[index]
                
                let newRed = Int((contrastRatio * (Int(pixel.red) - 128)) + 128)
                let newGreen = Int((contrastRatio * (Int(pixel.green) - 128)) + 128)
                let newBlue = Int((contrastRatio * (Int(pixel.blue) - 128)) + 128)
                
                pixel.red = UInt8(min(max(newRed,0),255))
                pixel.green = UInt8(min(max(newGreen,0),255))
                pixel.blue = UInt8(min(max(newBlue,0),255))
                
                image.pixels[index] = pixel
            }
        }
        return image;
    }
}

class BrightnessFilter: FilterProtocol {
    var name: String
    var brightnessFactor: Int
    
    init(name: String){
        self.name = name
        self.brightnessFactor = 0
    }
    
    init(name: String, factor: Int){
        self.name = name
        self.brightnessFactor = factor
    }
    
    func applyFilter(_ image: RGBAImage) -> RGBAImage {
        return brightnessFilter(self.brightnessFactor, image: image);
    }
    func applyFilter(_ image: RGBAImage, factor: Int) -> RGBAImage {
        return brightnessFilter(factor, image: image);
    }
    
    func brightnessFilter(_ brightnessFactor: Int, image: RGBAImage) -> RGBAImage {
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                
                var pixel = image.pixels[index]
                
                let newRed = Int(brightnessFactor + Int(pixel.red))
                let newGreen = Int(brightnessFactor + Int(pixel.green))
                let newBlue = Int(brightnessFactor + Int(pixel.blue))
                
                pixel.red = UInt8(min(max(newRed,0),255))
                pixel.green = UInt8(min(max(newGreen,0),255))
                pixel.blue = UInt8(min(max(newBlue,0),255))

                image.pixels[index] = pixel
            }
        }
        return image;
    }
}

class GrayscaleFilter: FilterProtocol {
    var name: String
    var intensity: Int
    
    init(name: String){
        self.name = name
        self.intensity = 1
    }
    
    init(name: String, factor: Int){
        self.name = name
        self.intensity = factor
    }
    
    func applyFilter(_ image: RGBAImage) -> RGBAImage {
        return grayScaleFilter(self.intensity, image: image);
    }
    func applyFilter(_ image: RGBAImage, factor: Int) -> RGBAImage {
        return grayScaleFilter(factor, image: image)
    }
    
    func grayScaleFilter(_ intensity: Int, image: RGBAImage) -> RGBAImage {
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                
                var pixel = image.pixels[index]
                
                var grayValue = Int((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3)
                grayValue = Int((intensity * (grayValue - 128)) + 128)
                
                pixel.red = UInt8(min(max(grayValue,0),255))
                pixel.green = UInt8(min(max(grayValue,0),255))
                pixel.blue = UInt8(min(max(grayValue,0),255))
                
                image.pixels[index] = pixel
            }
        }
        return image;
    }
}

class SepiaFilter: FilterProtocol {
    var name: String
    var intensity: Int
    
    init(name: String){
        self.name = name
        self.intensity = 1
    }
    
    init(name: String, factor: Int){
        self.name = name
        self.intensity = factor
    }
    
    func applyFilter(_ image: RGBAImage) -> RGBAImage {
        return sepiaFilter(self.intensity, image: image);
    }
    func applyFilter(_ image: RGBAImage, factor: Int) -> RGBAImage {
        return sepiaFilter(factor, image: image)
    }
    
    func sepiaFilter(_ intensity: Int, image: RGBAImage) -> RGBAImage {
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                
                var pixel = image.pixels[index]
                
                var newRed = Int((393 * Int(pixel.red) + 769 * Int(pixel.green) + 189 * Int(pixel.blue)) / 1000)
                newRed = Int((intensity * (newRed - 128)) + 128)
                
                var newGreen = Int((349 * Int(pixel.red) + 686 * Int(pixel.green) + 168 * Int(pixel.blue)) / 1000)
                newGreen = Int((intensity * (newGreen - 128)) + 128)
                
                var newBlue = Int((272 * Int(pixel.red) + 534 * Int(pixel.green) + 131 * Int(pixel.blue)) / 1000)
                newBlue = Int((intensity * (newBlue - 128)) + 128)
                
                pixel.red = UInt8(min(max(newRed,0),255))
                pixel.green = UInt8(min(max(newGreen,0),255))
                pixel.blue = UInt8(min(max(newBlue,0),255))
                
                image.pixels[index] = pixel
            }
        }
        return image;
    }
}


/**
 Define Image Processor Protocol
 **/

protocol ImageProcessorProtocol {
    /**
     applyFilter: Does lookup of predefined filter instance for given `filterName` and
     applies a single filter on input `image`
     **/
    func applyFilter(_ image: RGBAImage, filterName: String) -> RGBAImage
    
    /**
     applyFilters: Finds predefined filter instances for given `filterNames` array and
     applies all filters in order they are provided
     **/
    func applyFilters(_ image: RGBAImage, filterNames: [String]) -> RGBAImage
    
    /**
     applyFilters: applies an array of filterSettings (settings tuple: filter name and filter factor)
     in the order provided
     **/
    func applyFilters(_ image: RGBAImage, filterSettings: [(filter: String, factor: Int)]) -> RGBAImage
}


/**
 Define Image Processor Class
 **/

class ImageProcessor {
    var predefinedFilters = [String: FilterProtocol]()
    var filters = [String: FilterProtocol]()
    
    init(){
        //init predefined filters with specified factors
        self.predefinedFilters["+55Brightness"] = BrightnessFilter(name: "+55Brightness", factor: 55)
        self.predefinedFilters["-40Brightness"] = BrightnessFilter(name: "-30Brightness", factor: -40)
        self.predefinedFilters["3xContrast"] = ContrastFilter(name: "3xContrast", factor: 3)
        self.predefinedFilters["Sepia"] = SepiaFilter(name: "Sepia", factor: 1)
        self.predefinedFilters["Grayscale"] = GrayscaleFilter(name: "Grayscale", factor: 1)
        
        //init filters with default factors
        self.filters["Brightness"] = BrightnessFilter(name: "Brightness")
        self.filters["Grayscale"] = GrayscaleFilter(name: "Grayscale")
        self.filters["Sepia"] = SepiaFilter(name: "Sepia")
        self.filters["Contrast"] = ContrastFilter(name: "Contrast")
    }
    
    func applyFilter(_ image: RGBAImage, filterName: String) -> RGBAImage {
        if let filterInstance = self.predefinedFilters[filterName] {
            filterInstance.applyFilter(image)
        }
        else {
            print("Filter \(filterName) does not exist")
        }
        return image
    }
    
    func applyFilters(_ image: RGBAImage, filterNames: [String]) -> RGBAImage {
        if(filterNames.isEmpty){
            print("Input filter array is empty.")
        }
        else{
            for name in filterNames {
                if let filterInstance = self.predefinedFilters[name] {
                    filterInstance.applyFilter(image)
                }
                else {
                    print("Filter \(name) does not exist")
                }
            }
        }
        return image
    }
    
    func applyFilters(_ image: RGBAImage, filterSettings: [(filter: String, factor: Int)]) -> RGBAImage {
        if(filterSettings.isEmpty){
            print("Input filter settings array is empty.")
        }
        else{
            for settings in filterSettings {
                if let filterInstance = self.filters[settings.filter] {
                    filterInstance.applyFilter(image, factor: settings.factor)
                }
                else {
                    print("Filter \(settings.filter) does not exist")
                }
            }
        }
        return image
        
    }
}
