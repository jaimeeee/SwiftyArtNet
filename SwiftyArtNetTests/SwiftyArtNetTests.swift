//
//  SwiftyArtNetTests.swift
//  SwiftyArtNetTests
//
//  Created by Jaime on 20/11/2019.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import XCTest
@testable import SwiftyArtNet

class SwiftyArtNetTests: XCTestCase {

    private enum Messages: String, CaseIterable {
        case artPoll = "Art-Net\0\0 \0\u{0E}\u{02}\0"
    }

    func testArtNetHeader() {
        let artNet = SwiftyArtNet()
        for message in Messages.allCases {
            let artNetMessage = message.rawValue.data(using: .ascii)!
            XCTAssert(artNet.isArtNetMessage(data: artNetMessage), "Message is not Art-Net")
        }
    }
    
    func testArtNetMinimumProtocolVersion() {
        let artNet = SwiftyArtNet()
        for message in Messages.allCases {
            let artNetMessage = message.rawValue.data(using: .ascii)!
            XCTAssert(artNet.isArtNetMinimumProtocolVersion(data: artNetMessage))
        }
    }

}
