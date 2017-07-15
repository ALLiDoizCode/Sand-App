//
//  Node.swift
//  Sand-App
//
//  Created by Jonathan Green on 7/15/17.
//  Copyright © 2017 Jonathan Green. All rights reserved.
//

import Foundation
import RealmSwift

class Node:Object {
    dynamic var averageTimeUp:Int64 = 0
    dynamic var recentTimeUp:Int64 = 0
    dynamic var averageTimeDown:Int64 = 0
    dynamic var recentTimeDOwn:Int64 = 0
}
