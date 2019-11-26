//
//  MACAddressTests.swift
//  SwiftyArtNetTests
//
//  Created by Jaime on 25/11/2019.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import XCTest
@testable import SwiftyArtNet

class MACAddressTests: XCTestCase {

    func testMACAddressCreation() {
        // GIVEN
        let correctMACAddress = MACAddress(string: "A1:A2:A3:B1:B2:B3")
        let emptyMACAddress = MACAddress(string: ":::::")
        let incompleteMACAddress = MACAddress(string: "A1:A2:A3:B1:B2")
        let invalidMACAddress = MACAddress(string: "what are you even trying?")
        
        // THEN
        XCTAssertNotNil(correctMACAddress)
        XCTAssertNil(incompleteMACAddress)
        XCTAssertNil(invalidMACAddress)
        XCTAssertNotNil(emptyMACAddress)
    }

}
