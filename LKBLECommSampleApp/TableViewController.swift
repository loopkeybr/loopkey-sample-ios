//
//  TableViewController.swift
//  LKBLECommSampleApp
//
//  Created by Daniel Sandoval on 25/10/16.
//  Copyright © 2016 Loop CE. All rights reserved.
//

import UIKit
import LKBLECommunication

/// Showcase example of how to use LoopKey libraries when authenticating using a remote third-party server.
///
/// This exemple shows the use case of authenticating with a LoopKey device when the validation is done through a
/// third-party server (maybe your backend) and not directly connecting with LoopKey servers from the mobile device.
///
/// A list of all visible LoopKey devices will be presented in a table view.
class TableViewController: UITableViewController, LKDiscoveryProtocol
{
    /// Singleton reference to our main interface for discovering LoopKey devices.
    let _lkManager: LKCommunicationManager = LKBLEInteractor.sharedInstance()

    /// Stores the list of currently available LoopKey devices.
    var _lkDevices = [LKCommDevice]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        // If we'd like to make offline operations, we could set the device keys, for example.
        // device.key = ...
        // device.adminKey = ...
        // Now we instantiate a communicator so we can send messages to the LoopKey device. The first parameter is
        // the device we wish to communicate with. The second parameter is the user performing the operations, which
        // we may ignore since it won't be used by our communication method.
        let comm = LKDeviceCommunicator(device: device, user: nil)

        // Before communicating with the device we must first retrieve it's roll count parameter so we can send it to
        // the LoopKey server for authentication. There are two ways of retrieving the roll count. We can either use
        // the value transmitted during bluetooth broadcast, which is faster but may be unreliable in scenarios when
        // multiple operations are being performed in a short period of time. This is accomplished by calling the
        // `getRollCount()` method without a callback method.
        //
        // This alternative may be used to speed up server authentication. While with the immediate return value you
        // might make an authentication request, you should wait for the confirmed roll count value, compare both
        // values and, if they are the same, use the authentication you've already received from the server. Otherwise,
        // if the values differ, you should request another authentication from the server with the correct roll count
        // value.
        var rollCount = comm.getRollCount(nil)
        print("Roll count on first try (advertisement): ", rollCount ?? "(nil)")

        // Other alternative is calling the same method but with a callback function. This will make the mobile device
        // connect to the LoopKey device and get it's roll count. Even when a callback is provided, the method
        // immediately returns the roll count value it has from the bluetooth broadcast.
        _ = comm.getRollCount { (retrievedRCOptional) in
            if let rc = retrievedRCOptional {
                print("Roll count on second try (read operation): \(rc)")
                if rollCount != rc {
                    rollCount = rc // Recalculate any authorizations obtained from LoopKey servers.
                }
            }

            // With the roll count value, which is a buffer of arbitrary data, you should ping your backend and make any
            // validations that are necessary. If the user should authenticate, your backend should connect to LoopKey
            // servers with the roll count data and ask for an authorization (Check out the /door/sign endpoint).
            // Our servers will return an authenticated message in the Base64 format, which you should pass along to the
            // LoopKey device.
            // For this example, we'll pretend we received `base64msg` from the server:
            let base64msg = "AWE9ccFIpavL70OqbcB362zMzehwvHqKhfeDXj1hS4XRFyIZZ8Mf/1Neu93yg31fpQ=="
            let msgData = Data(base64Encoded: base64msg)!

            let ok = comm.communicateWithData(msgData, callback: self._deviceCommunicationCallback)

            if (ok) {
                print("Message will be transmitted, let's wait for the callback.")
            } else {
                print("Device is probably busy, the callback won't be called.")
            }
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
