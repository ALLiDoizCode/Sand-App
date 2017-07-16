//
//  Chunk.swift
//  Sand-App
//
//  Created by Jonathan Green on 7/15/17.
//  Copyright © 2017 Jonathan Green. All rights reserved.
//

import Foundation
import RealmSwift

class Chunk:Object {
    dynamic var chunk:Data!
    dynamic var key:String!
    dynamic var position:String!
}
