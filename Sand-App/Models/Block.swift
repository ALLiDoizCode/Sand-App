//
//  Block.swift
//  Sand-App
//
//  Created by Jonathan Green on 7/15/17.
//  Copyright © 2017 Jonathan Green. All rights reserved.
//

import Foundation
import RealmSwift

class Block:Object {
    dynamic var blockAddress:String!
    dynamic var address:String!
    dynamic var chunk:Data!
    dynamic var size:Int64 = 0

}
