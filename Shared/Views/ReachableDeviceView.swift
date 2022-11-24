//
//  ReachableDeviceView.swift
//  SampleiOS (iOS)
//
//  Created by SUPRISUL on 23/11/22.
//

import SwiftUI
import LKLib_Light

struct ReachableDeviceView: View {
    @ObservedObject var device: LKScanResult
    var unlockAction: (LKScanResult) -> ()
    
    var body: some View {
        VStack {
            Spacer(minLength: 16)
            HStack {
                Spacer(minLength: 16)
                VStack(alignment: .leading) {
                    Text(device.name ?? "Bluetooth Device").bold().font(.system(size: 14))
                    if let serialBase32 = device.serial?.serialBase32 {
                        Text(serialBase32).font(.system(size: 12))
                    }
                    if let deviceMac = device.lockMac {
                        Text(deviceMac).font(.system(size: 12))
                    }
                }
                Spacer(minLength: 16)
                Button("Unlock", action: { unlockAction(device) })
            }
            Spacer(minLength: 16)
        }
    }
}

struct ReachableDeviceView_Previews: PreviewProvider
{
    static var previews: some View {
        let device = LKScanResult(kind: .loopKey, serial: LKSerial(serial:Data(base64Encoded: "LLKFAABAAADABO33")!), macAddress: "0F:B3:4C:5F")
        ReachableDeviceView(device: device, unlockAction: { device in })
    }
}
