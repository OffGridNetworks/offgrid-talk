/*
 * nodekit.io
 *
 * Copyright (c) 2016-7 OffGrid Networks. All Rights Reserved.
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
import WebKit

extension NKScriptContextFactory {
    func createContextWKWebView(options: [String: AnyObject] = Dictionary<String, AnyObject>(), delegate cb: NKScriptContextDelegate) {
        
        
        NKScriptContextFactory.defaultQueue = dispatch_get_main_queue()
        
        dispatch_async(NKScriptContextFactory.defaultQueue) {
            
            let config = WKWebViewConfiguration()
            
            let webPrefs = WKPreferences()
            
            webPrefs.javaScriptEnabled = true
            
            webPrefs.javaScriptCanOpenWindowsAutomatically = true
            
            config.preferences = webPrefs
            
            let webView = WKWebView(frame: CGRect.zero, configuration: config)
            
            let id = NKScriptContextFactory.sequenceNumber
            
            webView.NKcreateScriptContext(id, options: options, delegate: cb)
            
            var item = Dictionary<String, AnyObject>()
            
            item["WKWebView"] = webView
            
            NKScriptContextFactory._contexts[id] = item
            
            webView.loadHTMLString("<HTML><BODY>NodeKit WKWebView: VM \(id)</BODY></HTML>", baseURL: NSURL(string: "about: blank"))
            
        }
        
    }
}

extension WKWebView: NKScriptContextHost {
    
    public func NKcreateScriptContext(id: Int, options: [String: AnyObject] = Dictionary<String, AnyObject>(),
                                      delegate cb: NKScriptContextDelegate) -> Void {
        
        NKLogging.log("+NodeKit Nitro JavaScript Engine E\(id)")
        
        self.navigationDelegate = NKWKWebViewDelegate(id: id, webView: self, delegate: cb)
        
        self.UIDelegate = NKWKWebViewUIDelegate(webView: self)
        
        let context = NKWKContext(self, id: id)
        
        context.prepareEnvironment()
        
        cb.NKScriptEngineDidLoad(context)
    }
}
