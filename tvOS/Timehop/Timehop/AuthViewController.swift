//
//  AuthViewController.swift
//  Timehop
//
//  Created by Benny Wong on 11/4/15.
//  Copyright © 2015 Benny Wong. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class AuthViewController: UIViewController, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    var browser = NSNetServiceBrowser()
    var service: NSNetService?
    var socket: GCDAsyncSocket?
    var sockets = [GCDAsyncSocket]()

    override func viewDidLoad() {
        // Start searching for services
        self.browser.delegate = self
        self.browser.searchForServicesOfType("_timehop_auth._tcp", inDomain: "local.")
    }

    // mark: NSNetServiceBrowserDelegate
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        // Hold a strong reference to service to it isn't dealloc-ed
        self.service = service
        
        self.service!.delegate = self
        self.service!.resolveWithTimeout(30)
    }
    
    // mark: NSNetServiceDelegate
    func netServiceDidResolveAddress(sender: NSNetService) {
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())

        do {
            // Connect to
            try self.socket!.connectToAddress(sender.addresses![0])
        } catch {
            self.presentError("Could not connect to service: \(sender.name)")
        }
    }

    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        self.presentError("Could not resolve service: \(sender.name)")
    }
    
    // GCDAsyncSockerDelegate
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        // Once connected, let's start reading data!

        //        let size = UInt(32)
        //        sock.readDataToLength(size  , withTimeout: -1, tag: 0)
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        // Read data from iOS service - in this case, an authentication token.
        let message = String(data: data!, encoding: NSUTF8StringEncoding)

        // Show the token
        let controller = UIAlertController(title: "Got token!", message: message!, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default) {
            _ in
            controller.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("LoggedIn", sender: self)
        })

        self.presentViewController(controller, animated: true, completion: nil)

        // Disconnect
        sock.disconnect()
        self.browser.stop()
    }
    
    // Utility
    func presentError(message: String) {
        let controller = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default) {
            _ in
            controller.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(controller, animated: true, completion: nil)
    }
}
