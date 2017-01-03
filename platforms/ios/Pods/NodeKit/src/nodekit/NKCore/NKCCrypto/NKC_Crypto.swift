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

import Darwin

import Foundation

class NKC_Crypto: NSObject, NKScriptExport {
    
    class func attachTo(context: NKScriptContext) {
        
        context.loadPlugin(NKC_Crypto(), namespace: "io.nodekit.platform.crypto", options: [String:AnyObject]())
        
    }

    func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
        
        case ".global":
        
            return NKStorage.getPluginWithStub(stub, "lib-core.nkar/lib-core/platform/crypto.js", NKC_Crypto.self)
       
        default:
        
            return stub
        
        }
    
    }

    func getRandomBytesSync(blockSize: Int) -> [UInt] {
    
        var randomIV: [UInt] = [UInt]()
        
        for _ in 0..<blockSize {
        
            randomIV.append(UInt(UInt8(truncatingBitPattern: arc4random_uniform(256))))
        
        }
       
        return randomIV
    
    }
 
}
