//
//  ArtPollReply.swift
//  SwiftyArtNet
//
//  Created by Jaime on 11/13/19.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import Foundation

struct ArtPollReply: ArtNetPacket {
    
    let nodeName: String
    
    // TODO: Make MAC address configurable since we are not getting it from the system
    private let macBlocks: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    
    private var IPv4Address: String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    func reply() -> Data? {
        // Make sure we have an IP Address
        guard let ipAddress = IPv4Address else {
            assert(false, "no wifi address :(")
            return nil
        }
        let ipBlocks = ipAddress.split(separator: ".").compactMap { UInt8($0) }

        // Initialize data
        var data = Data(count: 238)

        // Header [8 bytes]
        data.replaceSubrange(0..<8, with: header.data(using: .utf8)!)

        // OpCode [8 - 10]
        data.replaceSubrange(8..<10, with: withUnsafeBytes(of: ArtNetOpCode.pollReply.rawValue.littleEndian) {
            Data($0)
        })
        
        // IP Address [10 - 14]
        for block in 0..<4 {
            let range = (10 + block)..<(11 + block)
            data.replaceSubrange(range, with: withUnsafeBytes(of: ipBlocks[block]) { Data($0) })
        }
        
        // Port Number [14 - 16]
        data.replaceSubrange(14..<16, with: withUnsafeBytes(of: portNumber.littleEndian) { Data($0) })
        
        // NetSwitch [18] = 0
        // SubSwitch [19] = 0
        
        // Status1 [23]
        // bit 0 = 0 UBEA not present
        // bit 0 = 1 UBEA present
        // bit 1 = 0 Not capable of RDM (Uni-directional DMX)
        // bit 1 = 1 Capable of RDM (Bi-directional DMX)
        // bit 2 = 0 Booted from flash (normal boot)
        // bit 2 = 1 Booted from ROM (possible error condition)
        // bit 3 = Not used
        // bit 54 = 00 Universe programming authority unknown
        // bit 54 = 01 Universe programming authority set by front panel controls
        // bit 54 = 10 Universe programming authority set by network
        // bit 76 = 00 Indicators Normal
        // bit 76 = 01 Indicators Locate
        // bit 76 = 10 Indicators Mute
        data.replaceSubrange(23..<24, with: withUnsafeBytes(of: UInt8(0b0)) { Data($0) })
        
        // ESTA Code [24 - 26]
        data.replaceSubrange(24..<26, with: "tm".data(using: .utf8)!)
        
        // Short Name
        let shortHigherBound = min(nodeName.count, 18)
        data.replaceSubrange(26..<(26 + shortHigherBound), with: nodeName.data(using: .utf8)!)
        let longHigherBound = min(nodeName.count, 64)
        data.replaceSubrange(44..<(44 + longHigherBound), with: nodeName.data(using: .utf8)!)
        
        // Number of Ports
        data.replaceSubrange(173..<174, with: withUnsafeBytes(of: UInt8(1)) { Data($0) })
        
        // Port 1
        data.replaceSubrange(174..<175, with: withUnsafeBytes(of: UInt8(0b11000101)) { Data($0) })
        
        // Port 1 good input
        // data.replaceSubrange(178..<179, with: withUnsafeBytes(of: UInt8(0x10000)) { Data($0) })
        
        // Port 1 good output
        // data.replaceSubrange(183..<184, with: withUnsafeBytes(of: UInt8(0x0F)) { Data($0) })
        
        // Port 1 address
        data.replaceSubrange(190..<191, with: withUnsafeBytes(of: UInt8(1)) { Data($0) })
        
        // MAC Address [201 - 207]
        for block in 0..<6 {
            let range = (201 + block)..<(202 + block)
            data.replaceSubrange(range, with: withUnsafeBytes(of: macBlocks[block]) { Data($0) })
        }
        
        // Status2 [212]
        // bit 0 = 0 Node does not support web browser
        // bit 0 = 1 Node supports web browser configuration

        // bit 1 = 0 Node's IP address is manually configured
        // bit 1 = 1 Node's IP address is DHCP configured

        // bit 2 = 0 Node is not DHCP capable
        // bit 2 = 1 Node is DHCP capable

        // bit 2-7 not implemented, transmit as zero
        data.replaceSubrange(212..<213, with: withUnsafeBytes(of: UInt8(0b110)) { Data($0) })

        return data
    }

}
