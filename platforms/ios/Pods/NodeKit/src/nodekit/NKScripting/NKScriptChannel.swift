/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
* Portions Copyright 2015 XWebView
* Portions Copyright (c) 2014 Intel Corporation.  All rights reserved.
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

public class NKScriptChannel: NSObject, NKScriptMessageHandler {
 
    private(set) public var identifier: String?
    
    public let thread: NSThread?
    
    public let queue: dispatch_queue_t?
    
    private(set) public weak var context: NKScriptContext?
    
    internal weak var userContentController: NKScriptContentController?
    
    private var isFactory = false

    var typeInfo: NKScriptTypeInfo!

    internal var instances = [Int: NKScriptValueNative]()
    
    private var userScript: AnyObject?
    
    private(set) var principal: NKScriptValueNative {
    
        get { return instances[0]! }
        
        set { instances[0] = newValue }
    
    }

    private class var sequenceNumber: Int {
    
        struct sequence {
        
            static var number: Int = 0
        
        }
       
        let temp = sequence.number
        
        sequence.number += 1
        
        return temp
    }

    internal var nativeFirstSequence: Int {
        struct sequence {
        
            static var number: Int = Int(Int32.max)

        }
        
        let temp = sequence.number
        
        sequence.number -= 1
        
        return temp
    }

     public convenience init(context: NKScriptContext) {
    
        self.init(context: context, queue: NKScriptContextFactory.defaultQueue)
    
    }

    public init(context: NKScriptContext, queue: dispatch_queue_t) {
    
        self.context = context
        
        self.queue = queue
        
        thread = nil
        
        super.init()
        
        self.prepareForPlugin()
    
    }

    public init(context: NKScriptContext, thread: NSThread) {
     
        self.context = context
        
        self.thread = thread
        
        queue = nil
       
        super.init()
       
        self.prepareForPlugin()
    
    }

    deinit {
    
        guard let id = identifier else {return}
        
        NKLogging.log("+channel deinit" + id)
    
    }

    public static func currentContext() -> NKScriptContext! {
        return NSThread.currentThread().threadDictionary.objectForKey("nk.CurrentContext") as? NKScriptContext
    }

    private func prepareForPlugin() {
       
        let key = unsafeAddressOf(NKScriptChannel)
        
        if objc_getAssociatedObject(context, key) != nil { return }
        
        objc_setAssociatedObject(context, key, self, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let source = NKStorage.getResource("lib-scripting.nkar/lib-scripting/nkscripting.js", NKScriptChannel.self) else {
     
             NKLogging.die("Failed to read provision script: nkscripting")
        
        }

        context!.injectJavaScript(NKScriptSource(source: source, asFilename: "io.nodekit.scripting/NKScripting/nkscripting.js", namespace: "NKScripting"))
        
        guard let source2 = NKStorage.getResource("lib-scripting.nkar/lib-scripting/promise.js", NKScriptChannel.self) else {
            NKLogging.die("Failed to read provision script: promise")
        }

        context!.injectJavaScript(NKScriptSource(source: source2, asFilename: "io.nodekit.scripting/NKScripting/promise.js", namespace: "Promise"))
     
        NKLogging.log("+E\(context!.id) JavaScript Engine is ready for loading plugins")
    
    }

    public func bindPlugin(object: AnyObject, toNamespace namespace: String) -> NKScriptValue? {
    
        guard identifier == nil, let context = context else { return nil }

        let id = String(NKScriptChannel.sequenceNumber)
        
        identifier = id
        
        userContentController?.addScriptMessageHandler(self, name: id)

        if (object is AnyClass) {
            
            isFactory = true
            
            typeInfo = NKScriptTypeInfo(plugin: object as! AnyClass)
            
            objc_setAssociatedObject(typeInfo.plugin, unsafeAddressOf(NKScriptChannel), self, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
       
        } else {
        
            isFactory = false
            
            typeInfo = NKScriptTypeInfo(plugin: object.dynamicType)
        
        }

        principal = NKScriptValueNative(namespace: namespace, channel: self, object: object)

        context.injectJavaScript(NKScriptSource(source: generateStubs(String(object.dynamicType)), asFilename: namespace + "/plugin/" + String(object.dynamicType) + ".js" ))

        return principal as NKScriptValue
    
    }

    public func unbind() {
        
        guard let id = identifier else { return }
 
        instances.removeAll(keepCapacity: false)
        
        userContentController?.removeScriptMessageHandlerForName(id)
        
        userScript = nil
        
        identifier = nil
        
     }

    public func userContentController(didReceiveScriptMessage message: NKScriptMessage) {
        // A workaround for crash when postMessage(undefined)
    
        guard unsafeBitCast(message.body, COpaquePointer.self) != nil else { return }
        
        NSThread.currentThread().threadDictionary.setObject(self.context!, forKey: "nk.CurrentContext")
        
        if let body = message.body as? [String: AnyObject], let opcode = body["$opcode"] as? String {
        
            let target = (body["$target"] as? NSNumber)?.integerValue ?? 0
            
            if let object = instances[target] {
            
                if opcode == "-" {
                
                    if target == 0 {
                    
                        // Dispose plugin
                        
                        unbind()
                        
                    } else if let instance = instances.removeValueForKey(target) {
               
                        // Dispose instance
                        
                        objc_setAssociatedObject(instance.nativeObject, unsafeAddressOf(NKScriptValue), nil, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                    
                    } else {
                    
                        NKLogging.log("!Invalid instance id: \(target)")
                    
                    }
                    
                } else if let member = typeInfo[opcode] where member.isProperty {
                    
                    // Update property
                    
                    object.updateNativeProperty(opcode, withValue: body["$operand"] ?? NSNull())
               
                } else if let member = typeInfo[opcode] where member.isMethod {
                
                    // Invoke method
                    
                    if let args = (body["$operand"] ?? []) as? [AnyObject] {
                    
                        object.invokeNativeMethod(opcode, withArguments: args)
                   
                    } // else malformatted operand
               
                } else {
                
                    NKLogging.log("!Invalid member name: \(opcode)")
                
                }
           
            } else if opcode == "+" {
            
                // Create instance
                
                let args = body["$operand"] as? [AnyObject]
                
                let namespace = "\(principal.namespace)[\(target)]"
                
                instances[target] = NKScriptValueNative(namespace: namespace, channel: self, arguments: args)
           
            } // else Unknown opcode
        
        } else if let obj = principal.plugin as? NKScriptMessageHandler {
        
            // Plugin claims for raw messages
            
            obj.userContentController(didReceiveScriptMessage: message)
       
        } else {
        
            // discard unknown message
            
            NKLogging.log("!Unknown message: \(message.body)")
       
        }
      
        NSThread.currentThread().threadDictionary.removeObjectForKey( "nk.CurrentContext")

    }

    public func userContentControllerSync(didReceiveScriptMessage message: NKScriptMessage) -> AnyObject! {
      
        NSThread.currentThread().threadDictionary.setObject(self.context!, forKey: "nk.CurrentContext")
        
        var result: AnyObject!
        
        if let body = message.body as? [String: AnyObject], let opcode = body["$opcode"] as? String {
        
            let target = (body["$target"] as? NSNumber)?.integerValue ?? 0
            
            if let object = instances[target] {
            
                if opcode == "-" {
                
                    if target == 0 {
                    
                        // Dispose plugin
                        
                        unbind()
                        
                        result = true
                   
                    } else if let _ = instances.removeValueForKey(target) {
                    
                        // Dispose instance
                        
                        result = true
                    
                    } else {
                    
                        NKLogging.log("!Invalid instance id: \(target)")
                        
                        result = true
                   
                    }
                    
                } else if let member = typeInfo[opcode] where member.isProperty {
                    
                    // Update property
                    
                    object.updateNativeProperty(opcode, withValue: body["$operand"] ?? NSNull())
                    
                    result = true
               
                } else if let member = typeInfo[opcode] where member.isMethod {
                
                    // Invoke method
                    
                    if let args = (body["$operand"] ?? []) as? [AnyObject] {
                    
                        result = object.invokeNativeMethodSync(opcode, withArguments: args)
                   
                    } // else malformatted operand
               
                } else {
                
                    NKLogging.log("!Invalid member name: \(opcode)")
                    
                    result = false
                
                }
            
            } else if opcode == "+" {
            
                // Create instance
                
                let args = body["$operand"] as? [AnyObject]
                
                let namespace = "\(principal.namespace)[\(target)]"
                
                instances[target] = NKScriptValueNative(namespace: namespace, channel: self, arguments: args)
                
                result = true
            
            } // else Unknown opcode
       
        } else if let obj = principal.plugin as? NKScriptMessageHandler {
        
            // Plugin claims for raw messages
            
            result = obj.userContentControllerSync(didReceiveScriptMessage: message)
     
        } else {
        
            // discard unknown message
            
            NKLogging.log("!Unknown message: \(message.body)")
           
            result = false
       
        }
        
        NSThread.currentThread().threadDictionary.removeObjectForKey( "nk.CurrentContext")
        
        return result
    }

    private func generateStubs(name: String) -> String {
       
        func generateMethod(key: String, this: String, prebind: Bool) -> String {
        
            let stub = "NKScripting.invokeNative.bind(\(this), '\(key)')"
            
            return prebind ? "\(stub);" : "function(){return \(stub).apply(null, arguments);}"
        
        }
        
        func rewriteStub(stub: String, forKey key: String) -> String {
        
            return (principal.plugin as? NKScriptExport)?.rewriteGeneratedStub?(stub, forKey: key) ?? stub
        
        }

        
        let prebind = !(typeInfo[""]?.isInitializer ?? false)
        
        let stubs = typeInfo.reduce("") {
        
            let key = $1.0
            
            let member = $1.1
            
            let stub: String
            
            if member.isMethod && !key.isEmpty {
            
                let method = generateMethod("\(key)\(member.type)", this: prebind ? "exports" : "this", prebind: prebind)
                
                stub = "exports.\(key) = \(method)"
                
            } else if member.isProperty {
               
                if (isFactory) {  stub = "NKScripting.defineProperty(exports, '\(key)', null, \(member.setter != nil));" } else {
                    
                    let value = self.context?.serialize(principal.valueForPropertyNative(key))
                    
                    stub = "NKScripting.defineProperty(exports, '\(key)', \(value), \(member.setter != nil));"
               
                }
           
            } else {
            
                return $0
            
            }
            
            return $0 + rewriteStub(stub, forKey: key) + "\n"
        }

        let base: String
        
        if let member = typeInfo[""] {
        
            if member.isInitializer {
            
                base = "'\(member.type)'"
           
            } else {
            
                base = generateMethod("\(member.type)", this: "arguments.callee", prebind: false)
            
            }
        
        } else {
        
            base = rewriteStub("null", forKey: ".base")
       
        }

        return rewriteStub(
        
            "(function(exports) {\n" +
                rewriteStub(stubs, forKey: ".local") +
                "})(NKScripting.createPlugin('\(identifier!)', '\(principal.namespace)', \(base)));\n",
            forKey: ".global"
            
        )
        
    }
    
}
