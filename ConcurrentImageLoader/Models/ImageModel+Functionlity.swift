//
//  ImageModel+Functionlity.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 17/07/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import CoreImage
import UIKit

//MARK: Different state of image
enum ImageRecordState{
    case new, downloaded, filtered, failed
}

//MARK: Image Model
class ImageRecord {
    let name: String
    let url: URL
    var state: ImageRecordState = .new
    var image: UIImage? = UIImage(named: "placeholder")
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

//MARK: Track of different Operation
class PendingOperation {
    var pendingDownloadOperation = [IndexPath: Operation]()
    let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var pendingFilterationOperation = [IndexPath: Operation]()
    let filterQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}

//MARK: Download image from url
class ImageDownloader: Operation {
    let imageRecord: ImageRecord
    
    init(imageRecord: ImageRecord) {
        self.imageRecord = imageRecord
    }
    
    override func main() {
        if isCancelled{
            return
        }
        do{
            let data = try Data(contentsOf: imageRecord.url)
            if isCancelled{
                return
            }
            if let image = UIImage(data: data){
                imageRecord.image = image
                imageRecord.state = .downloaded
            }else{
                imageRecord.image = UIImage(named: "failed")
                imageRecord.state = .failed
            }
        }catch let error as NSError{
            print(error.domain)
        }
    }
}


//MARK: Apply Sepia image filteration.
class ImageFilter: Operation{
    let imageRecord: ImageRecord
    
    init(imageRecord: ImageRecord) {
        self.imageRecord = imageRecord
    }
    
    func applySepiaFilteration(image: UIImage) -> UIImage?{
        if isCancelled{
            return nil
        }
        let inputImage = CIImage(data: image.pngData()!)
        let context = CIContext(options: nil)
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(0.7, forKey: "inputIntensity")
        
        if isCancelled{
            return nil
        }
        
        if let outputImage = sepiaFilter?.outputImage, let outImage = context.createCGImage(outputImage, from: outputImage.extent){
            return UIImage(cgImage: outImage)
        }else{
            return nil
        }
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        if imageRecord.state != .downloaded {
            return
        }
        
        if let image = imageRecord.image, let filterImage = applySepiaFilteration(image: image){
            imageRecord.image = filterImage
            imageRecord.state = .filtered
        }
    }
}
