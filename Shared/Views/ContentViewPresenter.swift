//
//  ContentViewPresenter.swift
//  SampleiOS (iOS)
//
//  Created by SUPRISUL on 23/11/22.
//

import Foundation

@MainActor
class ContentViewPresenter: ObservableObject, LKScannerProtocol
{
    @Published var visibleDevices: [LKScanResult] = [LKScanResult]()
    @Published var isUnlocking: Bool = false
    
    private let _unlockDeviceInteractor = LKUnlockDeviceInteractor()
    private let _scanDevices = LKScanDevices.instance
    
    //MARK: - Private Door Properties
    var serialBase32: String = "LLKFAABAAADABO33"
    var userKey: String = "Ey0tqqG2L3piAiwDCPGDOopEewIk+olABgU1xBAsJv8="
    var lockData: String = "DUYzOJDhNGPt1NFVVUgE7yROijIeXg/Hh1HeZs0fJLvCZToZF7VLhWPMxn2ZhgnQPYyq71bzdOenQLnkFKIefP4VgaMavAp+D7TJQ6JcT7FUR5p2XUfcIh3gJ+P3BdEeg4R1qGx3km8Fw9moudswGbpjm88Z7YMHhaoJdVWjBZQK4QMDW8LP9Fq2QkvMwIBbui/LNsc1+b5b8GV2eQ7q3BJqesPuPI2CfIXnBBSZD9txIAINSBfTkqui/kj7XzL8NwP4cQ+sqQLCAyajstSezNkUCpC0+likoikBoFmcyQIC5hOwnOlSFZEy/J2IiSApqo7rZtLETKdZDuBiblmdn5WEplEH/mCO3z4C+s7yryar4hUWkfJUh55t4+63ddUWd6ZA/ArP3zawGtfjGf+iqunVScZAI9MaJ9CK14e5CZnVrSurAEky6HCMAGj6CWbqd43F+y74dKDx5e0YGYANzKn6aJTVs4k840awb9OaVzVGcnZmVRAIJExpRNF53BBun4n6ACm3APyJCpY3dY8k/Ck9RVqSyLZ3S0zTR0J/9tdk+jJYaO38Eo1hRseBxjli4cPXdKexrfL5ev/fdgmUZc/dRYEao36XZWY6vuf/eT7Ft7xYylHCmquDL5JLwM/pq/TkWus0br6MiKLcgLRVcX31SFpzy7S5edsmNSaFBKaByqoBGDZHPzjvJvCnh6Y65pX6MnCoar/4c6jMGW++v2vTX7Vcqg=="
    var lockMac: String = " "
    
    nonisolated func onAppear()
    {
        _scanDevices.subscribe(self)
    }
    
    nonisolated func onDisappear()
    {
        _scanDevices.unsubscribe(self)
    }
    
    func setDevices(_ devices: [LKScanResult])
    {
        self.visibleDevices.removeAll()
        self.visibleDevices.append(contentsOf: devices)
    }
    
    func unlockTapped(device: LKScanResult)
    {
        guard device.lockMac == lockMac || device.serial?.serialBase32 == serialBase32 else {
            return
        }
        
        self.isUnlocking = true
        
        //        device.lockData = lockData
        //        device.userKey = userKey
        //        _unlockDeviceInteractor.unlock(device: device,
        //                                       lockData: lockData) { result in
        //            Task {
        //                    self.isUnlocking = false
        //                    switch result {
        //                    case .failure(let error): break
        //                    case .success(let device): print("Door Opened")
        //                    }
        //            }
        //        }
        
        _unlockDeviceInteractor.unlock(serialBase32: serialBase32,
                                       lockMac: lockMac,
                                       userKey: userKey,
                                       lockData: lockData) { result in
            Task {
                self.isUnlocking = false
                switch result {
                case .failure(let error): break
                case .success(let device): print("Door Opened")
                }
            }
        }
    }
    
    nonisolated func didUpdateVisible(_ devices: [LKScanResult])
    {
        Task {
            await self.setDevices(devices)
        }
    }
}
