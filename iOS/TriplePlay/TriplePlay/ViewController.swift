//
//  ViewController.swift
//  TriplePlay
//
//  Created by Benny Wong on 11/8/15.
//  Copyright © 2015 Benny Wong. All rights reserved.
//

import CocoaAsyncSocket

class ViewController: UIViewController, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    @IBOutlet var authenticationButton: UIButton?
    @IBOutlet var spinner: UIActivityIndicatorView?

    var netService: NSNetService?
    var socket: GCDAsyncSocket?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner?.hidden = true

        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }

    @IBAction func startAuthentication() {
        do {
            try self.socket?.acceptOnPort(0)
        } catch {
            // TODO
        }

        let port = Int32(self.socket!.localPort)

        self.netService = NSNetService(domain: "local.", type: "_timehop_auth._tcp.", name: "Timehop Auth", port: port)
        self.netService?.delegate = self
        self.netService?.publish()

        self.authenticationButton?.hidden = true
        self.spinner?.hidden = false
    }

    // mark: NSNetServiceDelegate
    func netServiceDidPublish(sender: NSNetService) {
        NSLog("Published net service!")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        NSLog("Failed to publish service: \(errorDict)")
        self.netService = nil
    }

    // GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        NSLog("Got new connection")

        let data = "SOME_AUTH_TOKEN".dataUsingEncoding(NSUTF8StringEncoding)
        newSocket.writeData(data, withTimeout: -1.0, tag: 0)
    }

    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        self.netService = nil

        self.authenticationButton?.hidden = false
        self.spinner?.hidden = true

        let controller = UIAlertController(title: "Authentication Succeeded!", message: "", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) {
            _ in
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
        controller.addAction(action)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
