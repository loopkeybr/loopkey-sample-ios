//
//  UnlockLK.swift
//  SampleiOS (iOS)
//
//  Created by SUPRISUL on 18/07/22.
//

import Foundation
import LKLib_Light

class UnlockLK: LKDiscoveryProtocol
{
    var serialBase32: String = "LLKFAABAAADABO33"
    var userKey: String = "vsCizabvvnH1Sl0ioB9dfdw8TBxOoUW24G5hornvVF4="
    
    init()
    {
        LKBLEScanner.shared.subscribeForNotifications(self)
    }
    
    func didUpdateVisible(_ devices: [LKCommDevice])
    {
        guard var commDevice = devices.first(where: { $0.serial.serialBase32 == serialBase32 }) else {
            return
        }
        
        commDevice.userKey = Data(base64Encoded: userKey)
        
        _unlockLoopKey(device: commDevice, user: LKCommUser(id: 0))
    
    }
    
    private func _unlockLoopKey(device: LKCommDevice,
                                user: LKCommUser)
    {
        let unlockCommand = LKCommandRepository.createUnlockCommand(device: device, user: user)
        { _, response in
            switch response {
            case .ok, .okTimer, .alreadyOpen, .alreadyUnlocked:
                print("Door Unlocked")
            case .keyDelayed:
                print(response)
            case .permissionError:
                print(response)
            case .signatureSyncError:
                print(response)
            case .commonError(let e):
                switch e {
                case .deviceBecomeOutOfReachable, .deviceDidDisconnectUnexpectedly:
                    print(response)
                case .messageSignError:
                    print(response)
                case .serverCommError:
                    print(response)
                case .unauthorized:
                    print(response)
                default:
                    print(response)
                }
            default:
                print(response)
            }
        }
        
        LKCommandRunner.shared.enqueue(command: unlockCommand)
    }
}
