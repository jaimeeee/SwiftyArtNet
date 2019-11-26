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
        case nonArtNet = "Foo\0"
        case artPollLowerVersion = "Art-Net\0\0 \0\u{0D}\u{02}\0"
    }

    func testArtNetHeader() {
        // GIVEN
        let artNet = SwiftyArtNet()
        let artNetMessage = Messages.artPoll.rawValue.data(using: .ascii)
        let nonArtNetMessage = Messages.nonArtNet.rawValue.data(using: .ascii)

        // THEN
        XCTAssert(artNet.isArtNetMessage(data: artNetMessage!), "Message is not ArtNet")
        XCTAssertFalse(artNet.isArtNetMessage(data: nonArtNetMessage!))
    }
    
    func testArtNetMinimumProtocolVersion() {
        // GIVEN
        let artNet = SwiftyArtNet()
        let artNetMessage = Messages.artPoll.rawValue.data(using: .ascii)!
        let artNetLowerVersionMessage = Messages.artPollLowerVersion.rawValue.data(using: .ascii)!

        // THEN
        XCTAssert(artNet.isArtNetMinimumProtocolVersion(data: artNetMessage), "Message is not minimum protocol version")
        XCTAssertFalse(artNet.isArtNetMinimumProtocolVersion(data: artNetLowerVersionMessage))
    }

}
