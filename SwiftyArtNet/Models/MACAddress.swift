//
//  MACAddress.swift
//  SwiftyArtNet
//
//  Created by Jaime on 25/11/2019.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import Foundation

struct MACAddress {
    
    let blocks: [UInt8]
    
    var stringValue: String {
        return blocks.map { String($0) }.joined(separator: ":")
    }
    
    init?(string: String) {
        let macBlocks = string.split(separator: ":", maxSplits: 5)
        blocks = macBlocks.compactMap { UInt8($0) }
        guard blocks.count == 6 else { return nil }
    }
    
}
