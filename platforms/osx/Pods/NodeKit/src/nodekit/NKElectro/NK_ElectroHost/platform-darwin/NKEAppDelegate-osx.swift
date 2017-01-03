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
    
import Cocoa

class NKEAppDelegate: NSObject, NSApplicationDelegate, NKScriptContextDelegate {
    
    internal static var options: Dictionary<String, AnyObject>?
    
    internal static var delegate: NKScriptContextDelegate?

    private var splashWindow: NKE_BrowserWindow?
    
    private let nodekit: NKElectroHost
    
    let app: NSApplication

    init(app: NSApplication) {
    
        self.app = app
        
        self.nodekit = NKElectroHost()
        
        let testMode = (NKEAppDelegate.options?["nk.Test"] as? Bool) ?? false
        
        let noSplash = (NKEAppDelegate.options?["nk.NoSplash"] as? Bool) ?? false
        
        if (!testMode && !noSplash)
            
        {
            
            
            NKStorage.includeBundle(NSBundle(forClass: NKElectro.self))
        
            
            let splash: [String: AnyObject] = (NKEAppDelegate.options?["nk.splashWindow"] as? [String: AnyObject]) ??  [
                "nk.browserType": "UIWebView",
                "title": "",
                "preloadURL": "internal://localhost/splash.nkar/splash/views/StartupSplash.html",
                "width": 800,
                "height": 600,
                "nk.InstallElectro": false
            ]
            
            splashWindow = NKE_BrowserWindow(options: splash)
        
        }
    
    }
    
    // OS X Delegate Methods

    func applicationDidFinishLaunching(aNotification: NSNotification) {
    
        var options = NKEAppDelegate.options ?? Dictionary<String, AnyObject>()
        
        nodekit.start(&options, delegate: self)
        
        NKEventEmitter.global.emit("nk.ApplicationDidFinishLaunching", ())
     
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    
        NKEventEmitter.global.emit("nk.ApplicationWillTerminate", ())
        
        NKLogging.log("+Application Exit")
    
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
    
        return false
    
    }
    
    // NodeKit Delegate Methods

     func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
    
        NKEventEmitter.global.once("nk.jsApplicationReady") { (data: AnyObject) -> Void in
            
            if (self.splashWindow != nil)
            {
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                    self.splashWindow?.close()
                    
                    self.splashWindow = nil
                
                }
            
            }
        
        }

        NKEAppDelegate.delegate?.NKScriptEngineDidLoad(context)
    
    }

     func NKScriptEngineReady(context: NKScriptContext) -> Void {
       
        NKEAppDelegate.delegate?.NKScriptEngineReady(context)
    
    }
    
}
#endif