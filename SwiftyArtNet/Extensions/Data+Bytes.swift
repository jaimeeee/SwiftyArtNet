//
//  Data+Bytes.swift
//  SwiftyArtNet
//
//  Created by Jaime on 11/12/19.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import Foundation

extension Data {
    
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    /// Creates an Data instace based on a hex string (example: "ffff" would be <FF FF>).
    ///
    /// - parameter hex: The hex string without any spaces; should only have [0-9A-Fa-f].
    init?(hex: String) {
        if hex.count % 2 != 0 {
            return nil
        }

        let hexArray = Array(hex)
        var bytes: [UInt8] = []

        for index in stride(from: 0, to: hexArray.count, by: 2) {
            guard let byte = UInt8("\(hexArray[index])\(hexArray[index + 1])", radix: 16) else {
                return nil
            }

            bytes.append(byte)
        }

        self.init(bytes: bytes, count: bytes.count)
    }

    /// Gets one byte from the given index.
    ///
    /// - parameter index: The index of the byte to be retrieved. Note that this should never be >= length.
    ///
    /// - returns: The byte located at position `index`.
    func getByte(at index: Int) -> UInt8 {
        return subdata(in: index ..< (index + 1)).withUnsafeBytes { $0.load(as: UInt8.self) }
    }

    /// Gets an unsigned int (16 bits => 2 bytes) from the given index.
    ///
    /// - parameter index: The index of the uint to be retrieved. Note that this should never be >= length -
    ///                    3.
    ///
    /// - returns: The unsigned int located at position `index`.
    func getUInt16(at index: Int, bigEndian: Bool = true) -> UInt16 {
        let data = subdata(in: index ..< (index + 2)).withUnsafeBytes { $0.load(as: UInt16.self) }
        return bigEndian ? data.bigEndian : data.littleEndian
    }
    
}
