/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
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

#if os(OSX)
    
import Foundation

import WebKit

extension NKE_BrowserWindow: WebUIDelegate {

    internal func UIScriptEnvironmentReady() -> Void {
   
        (self._webView as! WebView).frameLoadDelegate = self
        
        self._events.emit("did-finish-load", self._id)
    
    }

    internal func createUIWebView(options: Dictionary<String, AnyObject>) -> Int {

        let id = NKScriptContextFactory.sequenceNumber

        let createBlock = {() -> Void in

            let window = self.createWindow(options)

            self._window = window

            let urlAddress: String = (options[NKEBrowserOptions.kPreloadURL] as? String) ?? "https://google.com"

            let width: CGFloat = CGFloat((options[NKEBrowserOptions.kWidth] as? Int) ?? 1024)
            
            let height: CGFloat = CGFloat((options[NKEBrowserOptions.kHeight] as? Int) ?? 800)
            
            let viewRect: NSRect = NSMakeRect(0,0, width, height)

            // create WebView
            
            let webView: WebView = WebView(frame: viewRect)
            
            self._webView = webView

            let webPrefs: WebPreferences = WebPreferences.standardPreferences()

            webPrefs.javaEnabled = false
            
            webPrefs.plugInsEnabled = false
            
            webPrefs.javaScriptEnabled = true
            
            webPrefs.javaScriptCanOpenWindowsAutomatically = true
            
            webPrefs.loadsImagesAutomatically = true
            
            webPrefs.allowsAnimatedImages = true
            
            webPrefs.allowsAnimatedImageLooping = true
            
            webPrefs.shouldPrintBackgrounds = true
            
            webPrefs.userStyleSheetEnabled = false

            webView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]

            webView.applicationNameForUserAgent = "nodeKit"

            webView.drawsBackground = false
            
            webView.preferences = webPrefs

            webView.UIDelegate = self
            
            
            let isTaskBarPopup = (options[NKEBrowserOptions.kTaskBarPopup] as? Bool) ?? false ;
            
            if isTaskBarPopup {
                
                (window as! NSPopover).contentViewController!.view = webView
                
                (window as! NSPopover).contentViewController!.preferredContentSize = CGSize(width: width, height: height)
                
            } else
            {
                
                (window as! NSWindow).contentView = webView
                
            }
            
            webView.NKcreateScriptContext(id, options: [String: AnyObject](), delegate: self)

            NSURLProtocol.registerClass(NKE_ProtocolLocalFile)
            
            NSURLProtocol.registerClass(NKE_ProtocolCustom)

            let url = NSURL(string: urlAddress as String)
            
            let requestObj: NSURLRequest = NSURLRequest(URL: url!)
            
            webView.mainFrame.loadRequest(requestObj)

        }

        if (NSThread.isMainThread()) {
        
            createBlock()
       
        } else {
        
            dispatch_async(dispatch_get_main_queue(), createBlock)
        
        }

        return id
    
    }

    func webView(sender: WebView!, runOpenPanelForFileButtonWithResultListener resultListener: WebOpenPanelResultListener!) {

        let openPanel = NSOpenPanel()
    
        openPanel.allowsMultipleSelection = false
        
        openPanel.canChooseDirectories = false
        
        openPanel.canCreateDirectories = false
        
        openPanel.canChooseFiles = true

        openPanel.beginWithCompletionHandler({(result: Int) in
        
            if(result == NSFileHandlingPanelOKButton) {
            
                let fileURL = openPanel.URL!
                
                resultListener.chooseFilename(fileURL.relativePath)
            
            }
        
        })
    
    }

}

extension NKE_BrowserWindow: WebFrameLoadDelegate {

    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {

        if (frame !== sender.mainFrame) {return;}
        
        self._events.emit("did-finish-load", self._id)
    
    }

    func webView(sender: WebView!, didFailProvisionalLoadWithError error: NSError!, forFrame frame: WebFrame!) {
    
        if (frame !== sender.mainFrame) {return;}
        
        self._events.emit("did-fail-loading", (self._id,  error.description))
    
    }

    func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
    
        if (frame !== sender.mainFrame) {return;}
        
        self._events.emit("did-fail-loading", (self._id,  error.description))
    
    }

}

#endif