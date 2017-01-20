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

import UIKit

class NKEAppDelegate: UIResponder, UIApplicationDelegate, NKScriptContextDelegate {

    var window: UIWindow?
   
    var _nodekit: NKElectroHost?
    
    internal static var options: Dictionary<String, AnyObject>?
    
    internal static var delegate: NKScriptContextDelegate?

    private var splashWindow: NKE_BrowserWindow?
    
    private var _viewController: UIViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        _viewController =  UIViewController()
    
        window?.rootViewController = _viewController

        window?.makeKeyAndVisible()
        
       _nodekit = NKElectroHost()
        
        var options = NKEAppDelegate.options ?? Dictionary<String, AnyObject>()
        
        _nodekit!.start(&options, delegate: self)
       
        NKEventEmitter.global.emit("nk.ApplicationDidFinishLaunching", ())
    
        return true
    
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      
        NKEventEmitter.global.emit("nk.ApplicationWillTerminate", ())
        
        NKLogging.log("+Application Exit")
    
    }

   // NodeKit Delegate Methods
    
    func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
    
        NKEAppDelegate.delegate?.NKScriptEngineDidLoad(context)
    
    }
    
    func NKScriptEngineReady(context: NKScriptContext) -> Void {
    
        NKEAppDelegate.delegate?.NKScriptEngineReady(context)
    
    }
   

}

#endif
/*
class NKEViewController: UIViewController {
    
    deinit {
      //   NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
 
    func keyboardWillShow(notification:NSNotification) -> Void {
        let delayInSeconds:Double = 0.1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * (Double)(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            self.hideKeyBoard()
        }
    }
    
    



    func hideKeyBoard() -> Void {
        
        for window in UIApplication.sharedApplication().windows {
            if !window.isMemberOfClass(UIWindow.self) {
                let keyboardWindow = window
                if #available(iOS 9.0, *) {
                    self.removeAccessoryBarForiOS8910(keyboardWindow as UIView)
                } else if #available(iOS 8.0, *) {
                    self.removeAccessoryBarForiOS8910(keyboardWindow as UIView)
                } else {
                    self.removeAccessoryBarForiOS7(keyboardWindow as UIView)
                }
            }
        }
    }
    
    func removeAccessoryBarForiOS8910(keyboardWindow:UIView) -> Void {
        for possibleFormView:UIView in keyboardWindow.subviews {
            if possibleFormView.isMemberOfClass(NSClassFromString("UIInputSetContainerView")!) {
                for subviewOfInputSetContainerView in possibleFormView.subviews {
                    if subviewOfInputSetContainerView.isMemberOfClass(NSClassFromString("UIInputSetHostView")!) {
                        for subviewOfInputSetHostView in subviewOfInputSetContainerView.subviews {
                            if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIWebFormAccessory")!) {
                                subviewOfInputSetHostView.layer.opacity = 0
                                subviewOfInputSetHostView.frame = CGRectZero
                            }
                            else if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIKBInputBackdropView")!) && subviewOfInputSetHostView.frame.size.height < 100 {
                                subviewOfInputSetHostView.layer.opacity = 0
                                subviewOfInputSetHostView.userInteractionEnabled = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeAccessoryBarForiOS7(keyboardWindow:UIView) -> Void {
        for possibleFormView:UIView in keyboardWindow.subviews {
            if possibleFormView.isMemberOfClass(NSClassFromString("UIPeripheralHostView")!) {
                for subviewOfPeripheralHostView in possibleFormView.subviews {
                    if subviewOfPeripheralHostView.isMemberOfClass(NSClassFromString("UIWebFormAccessory")!) {
                        subviewOfPeripheralHostView.layer.opacity = 0
                        subviewOfPeripheralHostView.frame = CGRectZero
                    }
                     else if subviewOfPeripheralHostView.isMemberOfClass(NSClassFromString("UIKBInputBackdropView")!) && subviewOfPeripheralHostView.frame.size.height < 100 {
                        subviewOfPeripheralHostView.layer.opacity = 0
                        subviewOfPeripheralHostView.userInteractionEnabled = false
                    }
                }
            }
        }
    }
 
 
    
}
 */
