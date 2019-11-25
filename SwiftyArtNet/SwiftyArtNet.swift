//
//  ArtNet.swift
//  HueDMX
//
//  Created by Jaime on 11/8/19.
//  Copyright © 2019 Jaimeeee. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol SwiftyArtNetDMXDelegate {
    func dmxFrame(sequence: UInt8, physical: UInt8, universe: UInt16, length: UInt16, dmx: [UInt8])
}



class SwiftyArtNet: NSObject {
    
    var delegate: SwiftyArtNetDMXDelegate?
    
    static func == (lhs: SwiftyArtNet, rhs: SwiftyArtNet) -> Bool {
        return false
    }
    
    private enum Configuration {
        static let portNumber: UInt16 = 6454
        static let header = "Art-Net\0"
        static let minimumProtocolVersion = 14
    }
    
    func listen() throws {
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        socket.isIPv4()
        do {
            try socket.bind(toPort: Configuration.portNumber)
        } catch {
            print("Error binding to port")
            throw error
        }
        do {
            try socket.enableBroadcast(true)
        } catch {
            print("error enabling broadcast")
            throw error
        }
        do {
            try socket.beginReceiving()
        } catch {
            print("error begin receiving")
            throw error
        }
    }
    
    func isArtNetMessage(data: Data) -> Bool {
        guard let header = String(data: data.subdata(in: 0..<8), encoding: .utf8) else {
            return false
        }
        guard header == Configuration.header else {
            print("not Art-Net")
            return false
        }
        return true
    }
    
    func isArtNetMinimumProtocolVersion(data: Data) -> Bool {
        let version = data.getUInt16(at: 10)
        guard version >= Configuration.minimumProtocolVersion else { return false }
        return true
    }
    
}

extension SwiftyArtNet: GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard isArtNetMessage(data: data) else { return }
        guard isArtNetMinimumProtocolVersion(data: data) else {
            print("lower than minimum, ignore")
            return
        }
        guard let opCode = ArtNetOpCode(rawValue: data.getUInt16(at: 8, bigEndian: false)) else {
            // Not supported message yet
            return
        }
        switch opCode {
        case .poll:
            guard let artPollReply = ArtPollReply(nodeName: "📲 iPhone Node").reply() else {
                assert(false, "Error: couldn't make ArtPollReply :(")
                return
            }
            sock.send(artPollReply, toHost: "255.255.255.255", port: UInt16(6454), withTimeout: 0, tag: 0)
        case .pollReply: return
        case .dmx:
            let dmxLength = data.getUInt16(at: 16)
            let datta: [UInt8] = data.subdata(in: 18 ..< Int(dmxLength)).map { $0 }
            delegate?.dmxFrame(sequence: data.getByte(at: 12),
                               physical: data.getByte(at: 13),
                               universe: data.getUInt16(at: 14, bigEndian: false),
                               length: dmxLength,
                               dmx: datta)
        case .nzs:
            return
        }
    }
    
}
