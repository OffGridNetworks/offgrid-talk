/*
 * OffGrid Talk
 *
 * Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import MultipeerConnectivity
import NodeKit


@objc public protocol ChatServiceManagerProtocol : NKScriptExport {
      func sendMessage(msg: String)
}

class ChatServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ChatServiceType = "offgrid-chat"
    
    private let myPeerId = MCPeerID(displayName: "macOS")
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    
    
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ChatServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ChatServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
   //     self.serviceBrowser.delegate = self
   //     self.serviceBrowser.startBrowsingForPeers()

        
    }
    
    deinit {
        NSLog("DEINIT");
        self.serviceAdvertiser.stopAdvertisingPeer()
   //     self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ChatServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    // Incoming invitation request.  Call the invitationHandler block with YES
    // and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession?) -> Void)
    {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
    // Advertising did not start due to an error.
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError)
    {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
}


extension ChatServiceManager : MCNearbyServiceBrowserDelegate {
    
    // Found a nearby advertising peer.
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    // A nearby peer has stopped advertising.
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        NSLog("%@", "lostPeer: \(peerID)")
        
    }
    
    // Browsing did not start due to an error.
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError)
    {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
}

extension ChatServiceManager : MCSessionDelegate {
    
    // Remote peer changed state.
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState)
    {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    }
    
    // Received data from remote peer.
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID)
    {
        NSLog("%@", "didReceiveData: \(data)")
        
        self.emitRecv(data, fromPeer: peerID)
    }
    
    // Received a byte stream from remote peer.
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        NSLog("%@", "didReceiveStream")
    }
    
    // Start receiving a resource from remote peer.
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
    {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)
    {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    // Made first contact with peer and have identity information about the
    // remote peer (certificate may be nil).
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void)
    {
        certificateHandler(true);
    }
    
}

extension ChatServiceManager: ChatServiceManagerProtocol {
    
    // PUBLIC METHODS, ACCESSIBLE FROM JAVASCRIPT
    func sendMessage(msg: String) {
        
        let msgData = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        do {
         try self.session.sendData(msgData!, toPeers: self.session.connectedPeers,
                                    withMode: MCSessionSendDataMode.Unreliable)
        } catch {
            print("error sending \(msg)")
        }
        
        
      /*  ECHO
         
         let onMainThread = { () -> Void in
       
            NSLog(msg);
            
            self.NKscriptObject?.invokeMethod("emit", withArguments:["recv", msg, "TEST" ], completionHandler: nil)
            
        }
        
        if (NSThread.isMainThread()) {
            
            onMainThread()
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), onMainThread)
            
        } */

    }
    
    // PRIVATE METHODS 
    
    private func emitRecv(data: NSData!, fromPeer PeerID: MCPeerID) {
        
        let onMainThread = { () -> Void in
            
            let peerName = PeerID.displayName
            
            guard let msg = String(data: data, encoding: NSUTF8StringEncoding) else {return }
            
            NSLog(msg);
            
            self.NKscriptObject?.invokeMethod("emit", withArguments:["recv", msg, peerName ], completionHandler: nil)
            
        }
        
        if (NSThread.isMainThread()) {
            
            onMainThread()
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), onMainThread)
            
        }

    
    }
    
    // CONFIG METHODS
    
    func attachTo(context: NKScriptContext) {
        context.loadPlugin(self, namespace: "com.offgridn.chat", options: [String:AnyObject]())
        
        
        
    }
    
}
