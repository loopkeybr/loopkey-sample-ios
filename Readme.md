# LoopKey Integration Sample Project

This project is a sample of how to integrate the LoopKey BLE communication technology with your Android project.

## LoopKey

LoopKey provides hardware and software libraries to empower Internet of Things applications. Use our technology
to reduce development cost and bring your product to market faster. This project exemplifies how easy it is to use
LoopKey to authenticate with real-world objects.

If you're interested in learning more about LoopKey, contact us at loopkey@loopkey.com.br.

## Getting Started

1. Add the Frameworks placed under **/Frameworks** folder, into your project.
2. At your project file, go to **Your Target > General > Frameworks, Libraries and Embbeded Content**, add the frameworks imported and at TTLock.framework, change the Embed option to **Do Not Embed**;
3. Go to Build Settings, change from Basic to All and search for **Other Linker Flags** and add **-ObjC**, which is necessary to load Objective-C Categories into Swift Code;
4. Copy all files under **SampleiOS > Shared > LKFiles**, into your project;

## Controling the Lockers

1. In order to scan for devices, your class will need to implement the LKScannerProtocol and request for notifications about reachable devices by providing a listener to the LKScanDevices instance.

```swift
class Example: LKScannerProtocol
{
    private var visibleDevices: [LKScanResult] = [LKScanResult]()
    private let _unlockDeviceInteractor = LKUnlockDeviceInteractor()
    private let _scanner = LKScanDevices.instance

    func onAppear()
    {
        _scanDevices.subscribe(self)
    }
}
```

4. Finally, you will need to implement the `func didUpdateVisible(_ devices: [LKScanResult])` method, wich will run every time a new device is detected or gets out of reach. It receives an array of `LKScanResult` containing the visible devices as the scan time:

5. After you make sure your device is reachable, you may use commands. You may check if a door is in the reachable devices by requesting to the scanner a visible device using the serial or the lockMac:

```swift
    let device = _scanner.get(serialBase32: serialBase32, lockMac: lockMac)
```

7. To send a Unlock command to any locker you must have the fields: `lockData`, `lockMac`, `serial`, `userKey`. Some of the fields could be null accordingly to the lock type. The field Serial may come as base64 and/or base32 encoding depending on how you fetch data from the API. **By default, the Scanner and Unlock classes uses the serial as Base32.**

8. To send a Unlock command to a locker you simple need to call the function on the UnlockInteractor Class.

```swift
_unlockDeviceInteractor.unlock(serialBase32: serialBase32,
                                       lockMac: lockMac,
                                       userKey: userKey,
                                       lockData: lockData) { result in
                switch result {
                case .failure(let error): break
                case .success(let device): print("Door Opened")
                }
        }
``` 

If the door is not in range, you will receive and error informing about it on the result callback. All possible values of results can be found at LKUnlockDeviceInteractor.swift file.

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

**The license is for this sample repository, not for the LoopKey BLE communication which is proprietary license.**

MIT License

Copyright (c) 2021 LoopKey

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
