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
import SwiftWebSocket
import CryptoSwift
import SwiftyJSON

class ViewController: UIViewController {
    var data:Data!
    var newData = Data()
    var chunks:[Data] = []
    var image:UIImage!
    var imageView:UIImageView!
    var dataFromChunks = Data()
    let uploadChunkSize = 5002
    let ws = WebSocket("ws://localhost:8080/bounce")
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        
        guard let img = UIImage(named: "moutain") else {
            return
        }

        data = UIImageJPEGRepresentation(img, 1)
        
        echoTest()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func echoTest(){
        var count = 0
        ws.event.open = {
            print("opened")
            self.dataSize(theData: self.data)
            self.createChunks(forData: self.data, completion: {
                
                for i in 0 ..< self.chunks.count {
                    self.sendChunks(part: self.chunks[i],position:i)
                }
            })
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text:String = message as! String {
                //print("recv: \(text)")
                count = count + 1
                let json = JSON(parseJSON: text)
                let chunk = json["chunk"].stringValue
                print("recv: \(chunk)")
                print("recv: \(json)")
                let stringData = Data(base64Encoded: chunk)
                self.newData.append(stringData!)
                if count == self.chunks.count {
                    print("count is \(count)")
                    self.image = UIImage(data: self.newData)
                    self.imageView.image = self.image
                }
            }
        }
    }
    
    func saveChunk(chunk:Data){
        
        let newChunk = Chunk()
        newChunk.chunk = chunk
        newChunk.key = ""
        newChunk.position = ""
    }
    
    func createBlock(){
        
        let newBlock = Block()
        newBlock.address = ""
        newBlock.blockId = ""
        newBlock.size = 0
        newBlock.chunk = ""
    }
    
    func brodcastBlock(){
        
    }
    
    func newBlockHeard(){
        
    }
    
    func updateBlockChain(){
    }
    
    func updateNodeInfo(){
        
    }
    
    func dataSize(theData:Data){
        
        let byteCount = (theData as NSData).length // replace with data.count
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let size = bcf.string(fromByteCount: Int64(byteCount))
        print("compressed size is \(size)")
    }
    
    func createChunks(forData: Data,completion:() -> Void) {

        forData.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
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
            completion()
            print(chunks.count)
        }
    }
    
    func sendChunks(part:Data,position:Int) {
        
        let phrase = "test"
        let hash = phrase.sha256()
        print("public key is \(hash)")
        let chunkDictionary =  [
            "chunk":part.base64EncodedString(),
            "size": "\(uploadChunkSize)",
            "position":"\(position)",
            "key":hash
        ]
        
        let json = JSON(chunkDictionary)
        //print(json)
        self.ws.send(json)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}



