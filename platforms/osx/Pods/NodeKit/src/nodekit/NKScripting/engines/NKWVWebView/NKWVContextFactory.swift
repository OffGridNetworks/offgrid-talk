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

extension NKScriptContextFactory {
    
    public func createContextUIWebView(options: [String: AnyObject] = Dictionary<String, AnyObject>(), delegate cb: NKScriptContextDelegate) {
        
        let createWebView = { () -> Void in
            
            let webView: WebView = WebView(frame: CGRect.zero)
            
            let webPrefs: WebPreferences = WebPreferences.standardPreferences()
            
            webPrefs.javaEnabled = false
            
            webPrefs.plugInsEnabled = false
            
            webPrefs.javaScriptEnabled = true
            
            webPrefs.javaScriptCanOpenWindowsAutomatically = false
            
            webPrefs.loadsImagesAutomatically = true
            
            webPrefs.allowsAnimatedImages = true
            
            webPrefs.allowsAnimatedImageLooping = true
            
            webPrefs.shouldPrintBackgrounds = true
            
            webPrefs.userStyleSheetEnabled = false
            
            webView.applicationNameForUserAgent = "nodeKit"
            
            webView.drawsBackground = false
            
            webView.preferences = webPrefs
            
            let id = NKScriptContextFactory.sequenceNumber
            
            webView.NKcreateScriptContext(id, options: options, delegate: cb)
            
            webView.mainFrame.loadHTMLString("<HTML><HEAD><script>// nodekit</script></HEAD><BODY>NodeKit UIWebView: JavaScriptCore VM \(id)</BODY></HTML>",baseURL: NSURL(string: "nodekit: core"))
            
        }
        
        
        if (NSThread.isMainThread()) {
            
            createWebView()
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), createWebView)
            
        }
        
    }
    
}

#endif