//
//  OfflineTableViewController.swift
//  LKBLECommSampleApp
//
//  Created by Daniel Sandoval on 28/10/17.
//  Copyright © 2017 Loop CE. All rights reserved.
//

import UIKit
import LKBLECommunication

/// Showcase example of how to use LoopKey libraries when authenticating locally, with the key present in the
/// iOS device.
///
/// A list of all visible LoopKey devices will be presented in a table view.
class OfflineTableViewController: UITableViewController, LKDiscoveryProtocol
{
    /// Singleton reference to our main interface for discovering LoopKey devices.
    let _lkManager: LKCommunicationManager = LKBLEInteractor.sharedInstance()

    /// Stores the list of currently available LoopKey devices.
    var _lkDevices = [LKCommDevice]()

    /// This would usually be replaced with a database access. We'll access this array when trying to communicate with
    /// a device.
    var _savedDevices = [LKCommDevice]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Here we instantiate our device with its serial number and keys.
        // Replace the string below with your bas64-encoded serial number.
        let device = LKCommDevice(withSerial: Data(base64Encoded: "<<insert your device serial here>>")!)
        // Replace the string below with your base64-encoded device key (or door key).
        device.key = Data(base64Encoded: "<<insert your device key here>>")
        // Replace the string below with your base64-encoded admin key (or admin key).
        device.adminKey = Data(base64Encoded: "<<insert your admin key here>>")
        _savedDevices.append(device)

        // This line subscribes the current instance of `TableViewController` to updates about visible devices.
        _lkManager.subscribeForNotifications(self)
        // This line ensures the `didUpdateVisible()` callback is called immediately with the current visible device
        // list.
        _lkManager.getVisibleDevices(self)
    }

    // MARK: - LKDiscoveryProtocol methods.

    /// Protocol method for when visible devices change.
    ///
    /// Visible devices are LoopKey devices that can be reached through bluetooth from this mobile device.
    /// Every time that list changes (i.e. when a LK device enters in range or leaves range), this method will be called
    /// with the current list of visible devices as the parameter.
    /// - Parameter devices: The list of currently visible LoopKey devices.
    func didUpdateVisible(_ devices: [LKCommDevice])
    {
        // First, we update our current list of visible devices.
        _lkDevices = devices
        // Next, we'll reload the table view. Check out the `tableView(_:didSelectRowAt:)` method.
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        /// Will return the current number of visible devices, which we are keeping track.
        return _lkDevices.count
    }

    /// This method is called when we touch a visible LoopKey device. Let's authenticate with it.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)

        // Gets the selected device.
        let device = _lkDevices[indexPath.row]

        // Checks if selected device is in the saved devices list.
        if let savedDevice = _savedDevices.first(where: { $0.serialData == device.serialData }) {
            // Now we instantiate a communicator so we can send messages to the LoopKey device. The first parameter is
            // the device we wish to communicate with. The second parameter is the user performing the operations, which
            // we may ignore since it won't be used by our communication method.
            // We use the savedDevice since it has the keys we need.
            let comm = LKDeviceCommunicator(device: savedDevice, user: nil)

            // We now communicate with the unlock message directly. Our communicator does everything that's needed since
            // it already has the key and can send the offline message.
            let ok = comm.communicateWithType(.Unlock, callback: self._deviceCommunicationCallback)
            if !ok {
                print("Faield to send message to device.")
            }
        } else {
            print("We don't have the selected device saved here.")
        }
    }

    /// Callback to treat the result of device operation.
    private func _deviceCommunicationCallback(responseOptional: LKDeviceResponse?, errorOptional: LKDeviceError?)
    {
        if let response = responseOptional {
            // This means your command was accepted and you have a response from the device.
            switch response.type {
            case .ok:
                print("Your command was accepted and LoopKey was unlocked!")
            case .ealu:
                print("Your command was accepted but LoopKey was already unlocked!")
            default:
                print("You received another kind of response")
            }
        } else if let error = errorOptional {
            // This means something went wrong. That could be anything from connection issues to authentication
            // problems. Checkout our enum documentation for details.
            switch error.type {
            case .ESIG:
                print("Your command signature was invalid.")
            case .ESYN:
                print("Your message was signed with the previous roll count. You need to sync.")
            case .timeout:
                print("Your operation has timed out. The message may or may not have been transmitted.")
            default:
                print("You received another kind of error.")
            }
        }
    }

    /// This function configures the table view cell with our device name and serial number.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let device = _lkDevices[indexPath.row]

        if let label = cell.textLabel, let name = device.name {
            label.text = name
        }
        if let label = cell.detailTextLabel {
            label.text = device.serialData.base32EncodedString
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0
    }
}
