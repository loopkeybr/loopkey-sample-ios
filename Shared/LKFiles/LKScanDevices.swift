//
//  LKReachableDevicesInteractor.swift
//  indigo
//
//  Created by Kelvin Lima on 26/03/20.
//  Copyright © 2020 Loop EC. All rights reserved.
//

import Foundation
import LKLib_Light
import TTLock

class LKScanDevices: LKDiscoveryProtocol
{
    // MARK: - Private Variables
    private var _visibleDevices: [LKScanResult] = []
    private var _visibleTTLockTimer: Timer?
    
    // MARK: - Public Variables
    var listeners: [LKScannerProtocol] = [LKScannerProtocol]()
    
    public static var instance: LKScanDevices = LKScanDevices()
    
    private let _reachableDevicesQueue: DispatchQueue = DispatchQueue(label: "ReachableDevices.queue")
    
    private init()
    {
        startScan()
    }
    
    deinit
    {
        stopScan()
    }
    
    func startScan()
    {
        _starTimer()
        LKBLEScanner.shared.subscribeForNotifications(self)
        
        TTLock.isPrintLog = true
        TTLock.setupBluetooth { state in
            if state == TTBluetoothState.poweredOn {
                TTLock.startScan { lock in
                    guard let lockFound = lock else {
                        return
                    }
                    
                    self._insertDevice(device: LKScanResult.map(commDevice: lockFound))
                    
                    self._notify()
                }
            }
        }
    }
    
    func stopScan()
    {
        _visibleTTLockTimer?.invalidate()
        LKBLEScanner.shared.unsubscribeForNotifications(self)
        TTLock.stopScan()
    }
    
    func subscribe(_ newListener: LKScannerProtocol)
    {
        _reachableDevicesQueue.async {
            if self.listeners.first(where: { newListener === $0 }) == nil {
                self.listeners.append(newListener)
            }
        }
        
        self._notify()
    }
    
    func unsubscribe(_ oldListener: LKScannerProtocol)
    {
        _reachableDevicesQueue.async {
            self.listeners.removeAll(where: { oldListener === $0 })
        }
    }
    
    func get(serialCode: Data, lockMac: String?) -> LKScanResult?
    {
        _reachableDevicesQueue.sync {
            return _visibleDevices.first { $0.lkCommDevice?.serial.raw == serialCode || $0.ttLockCommDevice?.lockMac == lockMac }
        }
    }
    
    func get(serialBase32: String, lockMac: String?) -> LKScanResult?
    {
        _reachableDevicesQueue.sync {
            return _visibleDevices.first { $0.lkCommDevice?.serial.serialBase32 == serialBase32 || $0.ttLockCommDevice?.lockMac == lockMac }
        }
    }
    
    func get() -> [LKScanResult]?
    {
        _reachableDevicesQueue.sync {
            return _visibleDevices
        }
    }
    
    private func _notify()
    {
        _reachableDevicesQueue.sync {
            print("Notifyting \(listeners.count) about visible devices.")
            self.listeners.forEach {
                $0.didUpdateVisible(self._visibleDevices)
            }
        }
    }
    
    private func _insertDevice(device: LKScanResult)
    {
        _reachableDevicesQueue.async {
            if let device = self._visibleDevices.first(where: {
                ($0.lkCommDevice?.serial.raw == device.serial?.raw) || ($0.ttLockCommDevice?.lockMac == device.lockMac) }) {
                device.ttLockCommDevice = device.ttLockCommDevice
                device.lkCommDevice = device.lkCommDevice
            } else {
                self._visibleDevices.append(device)
            }
        }
    }
    
    private func _starTimer()
    {
        _visibleTTLockTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let oldSize = self._visibleDevices.count
            
            self._reachableDevicesQueue.async {
                print("Checking for TT Unreachable Devices")
                self._visibleDevices.removeAll {
                    $0.kind == .ttLock && (Date().timeIntervalSince1970 - ($0.ttLockCommDevice?.date.timeIntervalSince1970 ?? Double(0.00))) > 5
                }
            }
            
            if (oldSize > self._visibleDevices.count) {
                print("TT Devices Removed")
                self._notify()
            }
        }
    }
    
    func didUpdateVisible(_ devices: [LKCommDevice])
    {
        var knownLKDevices: [LKCommDevice] = [LKCommDevice]()
        
        _reachableDevicesQueue.sync {
            knownLKDevices.append(contentsOf: self._visibleDevices.compactMap({  $0.lkCommDevice }))
        }
        
        if knownLKDevices != devices {
            _reachableDevicesQueue.async {
                self._visibleDevices.removeAll { $0.kind == .loopKey }
            }
            
            devices.forEach { self._insertDevice(device: LKScanResult.map(commDevice: $0)) }
            
            self._notify()
        }
    }
}


