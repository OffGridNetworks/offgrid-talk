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

import Foundation

@objc public class NKElectroHost: NSObject, NKScriptContextDelegate {
    
    // Common Public Methods
    
    public class func start() {
            NKEHostMain.start(Dictionary<String, AnyObject>(), delegate: nil)
    }
    
    public class func start(options: Dictionary<String, AnyObject>, delegate: NKScriptContextDelegate? = nil) {
        
        if let val = options["nk.MainBundle"] {

            NKStorage.mainBundle = val as! NSBundle;
        
        }
        
        if let _ = options["nk.Test"] {
        
            NKMainNoUI.start(options, delegate: delegate)
        
        } else {
        
           NKEHostMain.start(options, delegate: delegate)
     
        }
    
    }
    
    // Instance Methods (Not normally Called from Public, but Exposed to Allow Multiple {NK} NodeKit's per process)
    
    override public init() {
    
        self.context = nil
    
    }
    
    var context: NKScriptContext?
    
    private var scriptContextDelegate: NKScriptContextDelegate?
    
    public func start(inout options: Dictionary<String, AnyObject>, delegate: NKScriptContextDelegate? = nil) {
    
        self.scriptContextDelegate = delegate
        
        options["Engine"] = options["Engine"] ?? NKEngineType.JavaScriptCore.rawValue
        
        NKScriptContextFactory().createScriptContext(options, delegate: self)
    
    }
    
    public func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
    
        self.context = context
        
        // INSTALL JAVASCRIPT ENVIRONMENT ON MAIN CONTEXT
        
        NKElectro.addElectro(context)
        
        // NOTIFIY DELEGATE THAT SCRIPT ENGINE IS LOADED
        
        self.scriptContextDelegate?.NKScriptEngineDidLoad(context)
        
    }
    
    public func NKScriptEngineReady(context: NKScriptContext) -> Void {
    
        // NOTIFIY DELEGATE ON MAIN QUEUE THAT SCRIPT ENGINE IS LOADED
        dispatch_async(dispatch_get_main_queue(),{
        
            self.scriptContextDelegate?.NKScriptEngineReady(context)
            
            NKEventEmitter.global.emit("nk.Ready", ())
        
        })
    
    }
}

class NKMainNoUI {
    
    private static let nodekit: NKElectroHost = NKElectroHost()
    
    class func start(options: Dictionary<String, AnyObject>, delegate nkScriptDelegate: NKScriptContextDelegate?) {
    
        var options = options ?? Dictionary<String, AnyObject>()
        
        nodekit.start(&options, delegate: nkScriptDelegate)
        
        NKEventEmitter.global.emit("nk.ApplicationDidFinishLaunching", ())
    
    }

}
