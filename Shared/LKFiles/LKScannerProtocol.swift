//
//  LKScannerProtocol.swift
//  SampleiOS (iOS)
//
//  Created by SUPRISUL on 23/11/22.
//

import Foundation

protocol LKScannerProtocol: AnyObject
{
    func didUpdateVisible(_ devices: [LKScanResult])
}
