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

#if os(iOS)
    
import Foundation

import WebKit

import UIKit

extension NKE_BrowserWindow {

    internal func UIScriptEnvironmentReady() -> Void {

        (self._webView as! UIWebView).delegate = self
        self._events.emit("did-finish-load", self._id)
    
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
            self.shrinkViewKeyboardWillChangeFrame(notification)
    }
    
    func deviceOrientationDidChange(notification: NSNotification) {
        
        if self._keyboardIsVisible {
            return;
        }
        
        let webView = self._webView as! UIWebView
        
        let viewController = (self._window as! UIWindow).rootViewController!
        
        var screen = webView.frame.origin.y > 0 ? viewController.view.convertRect(UIScreen.mainScreen().applicationFrame, fromView: nil) : viewController.view.convertRect(UIScreen.mainScreen().bounds, fromView: nil)
        
        webView.frame = screen
        
    }

    
    func shrinkViewKeyboardWillChangeFrame(notification: NSNotification) {
        // No-op on iOS7.0.  It already resizes webview by default, and this plugin is causing layout issues
        // with fixed position elements.
        // iOS 7.1+ behave the same way as iOS 6
        if NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_7_0 {
            return
        }
        
        let webView = self._webView as! UIWebView
        
        let viewController = (self._window as! UIWindow).rootViewController!
        
        var screen = webView.frame.origin.y > 0 ? viewController.view.convertRect(UIScreen.mainScreen().applicationFrame, fromView: nil) : viewController.view.convertRect(UIScreen.mainScreen().bounds, fromView: nil)
        
        var keyboard = viewController.view.convertRect((notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).CGRectValue(), fromView: nil)
        
        var keyboardIntersection = CGRectIntersection(screen, keyboard)
        
        let keyboardisVisible = CGRectContainsRect(screen, keyboardIntersection) && !CGRectIsEmpty(keyboardIntersection)
        
        if keyboardisVisible {
            
            screen.size.height -= min(keyboardIntersection.size.height, keyboardIntersection.size.width)
            
            screen.size.height +=  self._accessoryBarHeight
            
            webView.scrollView.scrollEnabled = false
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * (Double)(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                var newFrame : CGRect = webView.scrollView.frame;
                newFrame.size.height += self._accessoryBarHeight
                webView.scrollView.frame = newFrame;

            }
            
        }
        
        webView.frame = screen
        
        webView.scrollView.scrollEnabled = true
        
        self._keyboardIsVisible = keyboardisVisible
        
        
    }
    
    func keyboardWillShow(notification:NSNotification) -> Void {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * (Double)(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                 self.removeAccessoryBar(notification)
        }
    
    }
    
    func keyboardWillHide(notification:NSNotification) -> Void {
        self._keyboardIsVisible = false
      }
    
    
    func removeAccessoryBar(notification:NSNotification) -> Void {
        
        let webView = self._webView as! UIWebView
        
        var FIRSTLEVELIDENTIFIER : String
        
        if #available(iOS 8.0, *) {
            FIRSTLEVELIDENTIFIER = "UIInputSetContainerView"
        } else{
            FIRSTLEVELIDENTIFIER = "UIPeripheralHostView"
        }
        
        for window in UIApplication.sharedApplication().windows {
            if !window.isMemberOfClass(UIWindow.self) {
                let keyboardWindow = window
                
                for possibleFormView:UIView in keyboardWindow.subviews {
                    
                    if possibleFormView.isMemberOfClass(NSClassFromString(FIRSTLEVELIDENTIFIER)!) {
                        
                        for subviewOfInputSetContainerView in possibleFormView.subviews {
                            
                            if subviewOfInputSetContainerView.isMemberOfClass(NSClassFromString("UIInputSetHostView")!) {
                                
                                for subviewOfInputSetHostView in subviewOfInputSetContainerView.subviews {
                                    
                                    // hides the accessory bar
                                    if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIWebFormAccessory")!) {
                                        
                                        _accessoryBarHeight = subviewOfInputSetHostView.frame.size.height;
                                        
                                        if #available(iOS 8.0, *) {
                                            subviewOfInputSetHostView.layer.opacity = 0
                                            subviewOfInputSetHostView.frame = CGRectZero
                                            
                                        } else
                                        {
                                            subviewOfInputSetHostView.removeFromSuperview()
                                        }
                                        
                                    }
                                    
                                    // hides the backdrop (iOS 7)
                                    if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIKBInputBackdropView")!) && subviewOfInputSetHostView.frame.size.height < 100 {
                                        
                                        // check that this backdrop is for the accessory bar (at the top),
                                        // sparing the backdrop behind the main keyboard
                                        
                                        let rect : CGRect = subviewOfInputSetHostView.frame;
                                        if (rect.origin.y == 0) {
                                            subviewOfInputSetHostView.layer.opacity = 0
                                            subviewOfInputSetHostView.userInteractionEnabled = false
                                        }
                                    }
                                    
                                    
                                    // hides the thin grey line used to adorn the bar (iOS 6)
                                    if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIImageView")!)
                                    {
                                        subviewOfInputSetHostView.layer.opacity = 0
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                }
            }
        }
   }
    
    internal func deinitUIWebView() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }


    internal func createUIWebView(options: Dictionary<String, AnyObject>) -> Int {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        
        let id = NKScriptContextFactory.sequenceNumber

        let createBlock = {() -> Void in

            let window = self.createWindow(options) as! UIWindow
    
            self._window = window

            let urlAddress: String = (options[NKEBrowserOptions.kPreloadURL] as? String) ?? "https://google.com"

            // create WebView
            
            let webView: UIWebView = UIWebView(frame: CGRect.zero)
            
            webView.contentMode = UIViewContentMode.Redraw
            
            webView.scalesPageToFit = false
            
            webView.scrollView.scrollEnabled = true
            
            self._webView = webView

            window.rootViewController?.view = webView
            
            NSURLProtocol.registerClass(NKE_ProtocolLocalFile)
     
            NSURLProtocol.registerClass(NKE_ProtocolCustom)

            webView.NKcreateScriptContext(id, options: [String: AnyObject](), delegate: self)

            let url = NSURL(string: urlAddress as String)

            let requestObj: NSURLRequest = NSURLRequest(URL: url!)

            
            webView.loadRequest(requestObj)
            
            window.rootViewController?.view.backgroundColor = UIColor(netHex: 0x2690F6)
            
            self._recognizer = UITapGestureRecognizer(target: self, action:#selector(self.dismissTheView))
            
            window.addGestureRecognizer((self._recognizer as! UITapGestureRecognizer))

        
        }
        
   

        if (NSThread.isMainThread()) {
        
            createBlock()
       
        } else {
        
            dispatch_async(dispatch_get_main_queue(), createBlock)
        
        }

        return id
    
    }
    
    func dismissTheView(sender:UITapGestureRecognizer) {
        
        (self._webView as! UIWebView).endEditing( true);
    }

}

extension NKE_BrowserWindow: UIWebViewDelegate {

    func webViewDidFinishLoad(webView: UIWebView) {

        self._events.emit("did-finish-load", self._id)
    
    }

    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError) {
    
        self._events.emit("did-fail-loading", (self._id,  error.description ?? ""))
    
    }

}

#endif
