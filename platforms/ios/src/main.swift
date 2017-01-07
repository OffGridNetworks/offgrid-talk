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
import NodeKit

class myNKDelegate: NSObject, NKScriptContextDelegate {
    
    var chatService : ChatServiceManager
    
    override init () {
        chatService = ChatServiceManager();
        super.init()
    }
    
    func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
        
        chatService.attachTo(context)
        
        // NodeKit.attachTo(context)
        // context.injectJavaScript(NKScriptSource(source: "process.bootstrap('app/index.js');", asFilename: "boot"))
    }
    
    func NKScriptEngineReady(context: NKScriptContext) -> Void {
        
        NKEventEmitter.global.emit("nk.jsApplicationReady", "" as AnyObject)
    }
}

NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")
NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitStoreWebDataForBackup")
NSUserDefaults.standardUserDefaults().synchronize()


NKElectroHost.start([
    "nk.allowCustomProtocol": false,
    "nk.NoSplash": true,
    "nk.NoTaskBar": true,
    "preloadURL": "renderer://localhost/index.html",
    "Engine" : NKEngineType.JavaScriptCore.rawValue
    ], delegate: myNKDelegate() )
