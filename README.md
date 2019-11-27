**⚠️ Under development ⚠️**

# SwiftyArtNet

Simple framework to create an Art-Net node and receive DMX messages throught WiFi.

## How To Use

```
let swiftyArtNet = SwiftyArtNet()
swiftyArtNet.delegate = self
try swiftyArtNet.listen()
```

### SwiftyArtNetDMXDelegate

To receive DMX frames, is necessary to implement the `SwiftyArtNetDMXDelegate`, for now it only supports one method.

`func dmxFrame(sequence: UInt8, physical: UInt8, universe: UInt16, length: UInt16, dmx: [UInt8])`
