# LoopKey Integration Sample Project

[![Documentation Coverage Badge](https://loopce.github.io/loopkey-sample-ios/badge.svg)](https://loopce.github.io/loopkey-sample-ios/)

This project is a sample of how to integrate the LoopKey BLE communication technology with your iOS project.

## LoopKey

LoopKey provides hardware and software libraries to empower Internet of Things applications. Use our technology
to reduce development cost and bring your product to market faster. This project exemplifies how easy it is to use
LoopKey to authenticate with real-world objects.

If you're interested in learning more about LoopKey, contact us at loopkey@loopkey.com.br.

### Scanning for devices

In order to scan for devices, your class will need to implement the `LKDiscoveryProtocol`, for example:

```swift
class Example: LKDiscoveryProtocol
{
    var _devices: [LKCommDevice]
…
}
```

The array of reachable devices will be used by the scanner, but may not be useful to you. Then, you will need to subscribe for notifications as soon as possible on your class lifecycle (`init`, `viewDidLoad`, `beforeEach`, etc):

```swift
    LKBLEScanner.shared.subscribeForNotifications(self)
```

On your `deinit` or your `viewDidDisappear`, unsubscribe for notifications:

```swift
    LKBLEScanner.shared.unsubscribeForNotifications(self)
```

Finally, you will need to implement the `didUpdateVisible(_:)` method, which will run every time a new device is detected or gets out of reach. It receives an array of `LKCommDevice` containing the visible devices at the scan time:

```swift
func didUpdateVisible(_ devices: [LKCommDevice])
{
    _devices.removeAll()
    _devices.append(contentsOf: devices)
}
```

Now you have an array of `LKCommDevice`, that you can use for your device retrieval logic.

After you make sure your device is reachable, you may use commands. You may check if a door is in the reachable devices by checking if the serial of the device is in the `LKCommDevices` array, for example:

```swift
func getReachableDoor(serial: LKSerial) -> LKCommDevice?
{
    return _devices.first(where: {$0.serial.raw == serial.raw})
}
```

### Using commands

The next step is to set the admin and user keys to this device. You may set them directly on the device you’ve just retrieved.

```swift
    let device = getReachableDoor(serial: YOUR_SERIAL)
    device?.adminKey = YOUR_ADMIN_KEY
    device?.userKey = YOUR_USER_KEY
```

*Both the keys and the serial need to be `Data`. They come as base64 encoded string from the server API.*

A Data may be obtained from a base64 encoded string using our built in method `dataFromDecimalString()`:

```swift
    let serialData = yourSerial.dataFromHexadecimalString()
```

With your device ready, you’ll need to get a reference for the command runner:

```swift
    let commandRunner = LKCommandRunner.shared
```

And then you’ll need to instantiate your command. To do this, use the `LKCommandRepository`’s class static methods. You will need your device and an user - which uses your CommUser’s ID, but for integration purposes, may be 0). For example, an unlock command:

```swift
    let unlockCommand = LKCommandRepository.createUnlockCommand(commDevice: device,
                                                                     user: LKCommUser(id: 0)) { device, response in
                                                                        …
                                                                     }
```

The response in the closure is the command response (`.ok`, `.okAlreadyOpen`, etc).

Finally, use the enqueue command to run it:

```swift
    commandRunner.enqueue(command: unlockCommand)
```

That’s it. Your command will be run by the command runner as soon as possible in its queue.

Note that the unlock command was used as an example, but other commands are similar. Just check the documentation on the `LKCommandRepository` for more information.

### Retrieving data from server

The first thing you'll want to do is login. The endpoint is:

```
/login
POST
Parameters:
- email
- pass
Response:
- authorization
- user
```

This will return the token used for authentication and usage of other endpoints.

You will also want to retrieve the doors list. Simply use the endpoint:

```
/permission
GET
Response:
- id
- whoShared
- door
- referenceType
- referenceValue
- type
- contact
```

Which will return a list of devices for that user. The door will contain both the serial and the keys for your devices.

You may check a more complete reference on the server API by checking the link: https://dev.loopkey.com.br/

## License

MIT License

Copyright (c) 2017 LoopKey

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
