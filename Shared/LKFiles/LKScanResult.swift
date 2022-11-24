//
//  LKScanResult.swift
//  indigo
//
//  Created by Bruno Ribeiro on 26/08/21.
//  Copyright © 2021 Loop EC. All rights reserved.
//

import Foundation
import LKLib_Light
import TTLock

enum LKScanDeviceKind
{
    case loopKey
    case ttLock
    case ttGateway
}

class LKScanResult: Identifiable, ObservableObject
{
    var rssi: Int?
    var kind: LKScanDeviceKind
    var name: String?
    var isInDFUMode: Bool?
    var serial: LKSerial?
    var firmwareVersion: String?
    var hasLogsToSync: Bool
    var lockMac: String?
    var lockData: String?
    var userKey: String?
    var lastSyncTimeStamp: Int64?
    var lkCommDevice: LKCommDevice?
    var ttLockCommDevice: TTScanModel?

    init(rssi: Int? = nil,
         kind: LKScanDeviceKind,
         name: String? = nil,
         isInDFUMode: Bool? = false,
         serial: LKSerial? = nil,
         firmwareVersion: String? = nil,
         hasLogsToSync: Bool = false,
         macAddress: String? = nil,
         userKey: String? = nil,
         lastSyncTimeStamp: Int64? = nil,
         lkCommDevice: LKCommDevice? = nil,
         ttLockCommDevice: TTScanModel? = nil)
    {
        self.rssi = rssi
        self.kind = kind
        self.name = name
        self.isInDFUMode = isInDFUMode
        self.serial = serial
        self.firmwareVersion = firmwareVersion
        self.hasLogsToSync = hasLogsToSync
        self.lockMac = macAddress
        self.lastSyncTimeStamp = lastSyncTimeStamp
        self.lkCommDevice = lkCommDevice
        self.ttLockCommDevice = ttLockCommDevice
        self.userKey = userKey
    }

    static func map(commDevice: LKCommDevice) -> LKScanResult
    {
        return LKScanResult(rssi: commDevice.rssi,
                            kind: .loopKey,
                            name: commDevice.name,
                            isInDFUMode: commDevice.isInUpdateMode,
                            serial: commDevice.serial,
                            hasLogsToSync: commDevice.hasLogsToSync,
                            lkCommDevice: commDevice)
    }

    static func map(commDevice: TTScanModel) -> LKScanResult
    {
        return LKScanResult(rssi: commDevice.rssi,
                            kind: .ttLock,
                            name: commDevice.lockName,
                            isInDFUMode: commDevice.isDfuMode,
                            macAddress: commDevice.lockMac,
                            ttLockCommDevice: commDevice)
    }
}
