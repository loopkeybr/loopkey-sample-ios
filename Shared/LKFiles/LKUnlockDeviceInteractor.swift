//
//  UnlockLK.swift
//  SampleiOS (iOS)
//
//  Created by SUPRISUL on 18/07/22.
//

import Foundation
import LKLib_Light
import TTLock

enum LKUnlockErrorTypes: Error
{
    case signalError
    case syncError
    case timeout
    case permissionError
    case doorUnavailable
    case messageSignError
    case serverCommError
    case lockDataMissing
    case unknown
}

class LKUnlockDeviceInteractor: LKScannerProtocol
{
    private let _scanner: LKScanDevices = LKScanDevices.instance
    
    init()
    {
        _scanner.subscribe(self)
    }
    
    deinit
    {
        _scanner.unsubscribe(self)
    }
    
    /// Unlocks a given device.
    ///
    /// - Parameter
    /// - Parameters:
    ///     - device: The device that will be unlocked.
    ///     - handler: Will be called whenever the operation completes.
    func unlock(device: LKScanResult,
                handler: @escaping (Result<LKCommDevice?, LKUnlockErrorTypes>) -> Void)
    {
        switch device.kind {
        case .loopKey:
                _unlockLoopKey(device: device, handler: handler)
        case .ttLock:
                _unlockTTLock(device: device, handler: handler)
        default:
            break
        }
    }
    
    /// Unlocks a given device.
    ///
    /// - Parameter
    /// - Parameters:
    ///     - device: The device that will be unlocked.
    ///     - handler: Will be called whenever the operation completes.
    func unlock(serialBase32: String,
                lockMac: String?,
                userKey: String?,
                lockData: String?,
                handler: @escaping (Result<LKCommDevice?, LKUnlockErrorTypes>) -> Void)
    {
        guard let device = _scanner.get(serialBase32: serialBase32, lockMac: lockMac) else {
            handler(.failure(.doorUnavailable))
            return
        }
        
        device.lockData = lockData
        device.lockMac = lockMac
        device.userKey = userKey
        
        switch device.kind {
        case .loopKey:
                _unlockLoopKey(device: device, handler: handler)
        case .ttLock:
                _unlockTTLock(device: device, handler: handler)
        default:
            break
        }
    }

    private func _unlockLoopKey(device: LKScanResult,
                                handler: @escaping (Result<LKCommDevice?, LKUnlockErrorTypes>) -> Void)
    {
        guard var commDevice = device.lkCommDevice else {
            print("Invalid door object provided to the function.")
            handler(.failure(.doorUnavailable))
            return
        }
        
        if let userKey = device.userKey, let keyAsData = Data(base64Encoded: userKey) {
            commDevice.userKey = keyAsData
        }
        
        let unlockCommand = LKCommandRepository.createUnlockCommand(device: commDevice, user: LKCommUser(id: 0))
        { _, response in
            switch response {
            case .ok, .okTimer, .alreadyOpen, .alreadyUnlocked:
                handler(.success(commDevice))
            case .keyDelayed:
                handler(.failure(.syncError))
            case .permissionError:
                handler(.failure(.permissionError))
            case .signatureSyncError:
                handler(.failure(.signalError))
            case .commonError(let e):
                switch e {
                case .deviceBecomeOutOfReachable, .deviceDidDisconnectUnexpectedly:
                    handler(.failure(.doorUnavailable))
                case .messageSignError:
                    handler(.failure(.messageSignError))
                case .synchronizationIssue:
                    handler(.failure(.syncError))
                case .serverCommError:
                    handler(.failure(.serverCommError))
                case .unauthorized:
                    handler(.failure(.permissionError))
                default:
                    handler(.failure(.unknown))
                }
            default:
                handler(.failure(.unknown))
            }
        }
        LKCommandRunner.shared.enqueue(command: unlockCommand)
    }

    private func _unlockTTLock(device: LKScanResult,
                               handler: @escaping (Result<LKCommDevice?, LKUnlockErrorTypes>) -> Void)
    {
        if device.lockData != nil {
            TTLock.controlLock(with: .actionUnlock,
                               lockData: device.lockData,
                            success: { _, _, _ in
                                handler(.success(nil))
                            },
                            failure: { code, _ in
                                switch code {
                                case TTError.noPermisstion:
                                    print("You have no permission to exceute the desired command on this door.")
                                    handler(.failure(.permissionError))
                                case TTError.wrongAdminCode:
                                    print("You have no permission to exceute the desired command on this door.")
                                    handler(.failure(.permissionError))
                                case TTError.wrongLockData:
                                    print("Wrong LockData provided")
                                    handler(.failure(.messageSignError))
                                case TTError.crcError:
                                    print("Wrong LockData provided")
                                    handler(.failure(.messageSignError))
                                case TTError.hadReseted:
                                    print("This door is at unconfigured state")
                                    handler(.failure(.doorUnavailable))
                                case TTError.noAdmin:
                                    handler(.failure(.doorUnavailable))
                                case TTError.isNoPower:
                                    handler(.failure(.doorUnavailable))
                                case TTError.lockIsBusy:
                                    print("The Lock is Busy, try again")
                                    handler(.failure(.doorUnavailable))
                                case TTError.lockIsLocked:
                                    handler(.failure(.doorUnavailable))
                                default:
                                    print("Unexpected error during the operation")
                                    handler(.failure(.unknown))
                                }
                            })
        } else {
            print("Lock Data must be provided on this kind of door.")
            handler(.failure(.lockDataMissing))
        }
    }
    
    func didUpdateVisible(_ devices: [LKScanResult])
    {
    }
}
