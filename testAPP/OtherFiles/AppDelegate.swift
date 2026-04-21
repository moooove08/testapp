//
//  AppDelegate.swift
//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTestNavigation(rootViewController: MainTestViewController())
        window?.makeKeyAndVisible()
        return true
    }
    
}

class MainTestNavigation: UINavigationController {
    
    override var shouldAutorotate: Bool {return true}
    override var prefersHomeIndicatorAutoHidden: Bool {return true}
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {return .portrait}
    override var prefersStatusBarHidden: Bool {return true}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }
}
