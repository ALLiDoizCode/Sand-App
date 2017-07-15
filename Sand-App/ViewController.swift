//
//  ViewController.swift
//  Sand-App
//
//  Created by Jonathan Green on 7/14/17.
//  Copyright © 2017 Jonathan Green. All rights reserved.
//

import UIKit
import Gzip
import Alamofire
class ViewController: UIViewController {

    var data:Data!
    var newData = Data()
    var decompressedData = Data()
    var chunks:[Data] = []
    //var compressedData:Data!
    var optimizedData:Data!
    var image:UIImage!
    var imageView:UIImageView!
    var dataFromChunks = Data()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        
        guard let img = UIImage(named: "moutain") else {
            return
        }
        data = UIImageJPEGRepresentation(img, 1)
        
        // gzip
         //compressedData = try! data.gzipped()
         //optimizedData = try! data.gzipped(level: .bestCompression)
        
        // gunzip
        
        //dataSize(theData: compressedData)
        dataSize(theData: data)
        createChunks(forData: data)
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataSize(theData:Data){
        
        let byteCount = (theData as NSData).length // replace with data.count
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let size = bcf.string(fromByteCount: Int64(byteCount))
        print("compressed size is \(size)")
    }
    
    func createChunks(forData: Data) {

        forData.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
            let uploadChunkSize = 97152
            let totalSize = (forData as NSData).length
            var offset = 0
            
            while offset < totalSize {
            
                let chunkSize = offset + uploadChunkSize > totalSize ? totalSize - offset : uploadChunkSize
                let chunk = Data(bytesNoCopy: mutRawPointer+offset, count: chunkSize, deallocator: Data.Deallocator.none)
                offset += chunkSize
                chunks.append(chunk)
                dataFromChunks.append(chunk)
                dataSize(theData: chunk)
            }
            
            print(chunks.count)
            
            /*for part in dataFromChunks {
                

                newData.append(decompressedData)
            }*/
            
            /*if decompressedData.isGzipped {
                print("is zipped")
                decompressedData = try! dataFromChunks.gunzipped()
            } else {
                print("is not zipped")
                decompressedData = dataFromChunks
            }*/
            //decompressedData = try! dataFromChunks.gunzipped()
            sendChunks(parts: chunks)
        }
    }
    
    func sendChunks(parts:[Data]) {
        var count = 0
        
        let headers:HTTPHeaders = [
            "Content-Type":"application/json"
        ]
        for part in parts {
         
            
            
            let param = [
                "data":part.base64EncodedString()
            ]
            print(part.base64EncodedString())
            Alamofire.request("http://localhost:8080/bounce/data", method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { (response) in
                
                print(response)
                print(response.data)
                print(response.value)
                print(response.result.value)
                
                count = count + 1
                let stringData = Data(base64Encoded: response.result.value!)
                self.newData.append(stringData!)
                if count == self.chunks.count {
                    print("count is \(count)")
                    self.image = UIImage(data: self.newData)
                    self.imageView.image = self.image
                }
            })
        }
    }


}



