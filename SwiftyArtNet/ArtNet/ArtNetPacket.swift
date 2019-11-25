//
//  ArtNetPacket.swift
//  SwiftyArtNet
//
//  Created by Jaime on 11/13/19.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import Foundation

enum ArtNetOpCode: UInt16 {
    case poll = 0x2000
    case pollReply = 0x2100
    case dmx = 0x5000
    case nzs = 0x5100
}

protocol ArtNetPacket {
    var header: String { get }
    var portNumber: UInt16 { get }
    var minimumProtocolVersion: UInt16 { get }
}

extension ArtNetPacket {
    var header: String { return "Art-Net\0" }
    var portNumber: UInt16 { return 6454 } // 0x1936
    var minimumProtocolVersion: UInt16 { return 14 }
}
