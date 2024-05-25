//
//  SceneDelegate.swift
//  hye:eum
//
//  Created by mobicom on 5/9/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene:  scene)
        
        // Splash 페이지로 이동
        let sb = UIStoryboard(name: "SplashPage", bundle: nil)
        guard let splashVC = sb.instantiateViewController(withIdentifier: "SplashPageController") as? SplashPageController else { return }
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let main_sb = UIStoryboard(name: "MainPage", bundle: nil)
            let welcome_sb = UIStoryboard(name: "WelcomePage", bundle: nil) // !!!!  MainPage -> WelcomePage !!!!
            
            // 내비게이션 컨트롤러 생성
            let navController = UINavigationController()
            
            // 초기설정 완료 여부 확인
            let isRegistered = UserDefaults.standard.bool(forKey: "isRegistered")
            
            if isRegistered {
                guard let mainVC = main_sb.instantiateViewController(withIdentifier: "MainPageController") as? MainPageController else { return }
                navController.viewControllers = [mainVC]
            } else { // !!!! MainPage -> WelcomePage !!!!
                guard let welcomeVC = welcome_sb.instantiateViewController(withIdentifier: "WelcomePageController") as? WelcomePageController else { return }
                navController.viewControllers = [welcomeVC]
            }
            
            self.window?.rootViewController = navController
            self.window?.makeKeyAndVisible()
        }

        
        // << 단순 최초 실행만 판별하는 코드 >>
        //        if userDefaults.bool(forKey: "NotFirst") == false {
        //            userDefaults.set(true, forKey: "NotFirst")
        //
        //            // sb - storyboard, vc - viewcontroller
        //            // 최초 실행 -> WelcomePage 이동
        //            let sb = UIStoryboard(name: "WelcomePage", bundle: nil)
        //            guard let vc = sb.instantiateViewController(withIdentifier: "WelcomePageController") as? WelcomePageController else { return }
        //
        //            window?.rootViewController = vc
        //            window?.makeKeyAndVisible()
        //        } else {
        //
        //            // 기실행 존재 -> MainPage
        //            let sb = UIStoryboard(name: "MainPage", bundle: nil)
        //            guard let vc = sb.instantiateViewController(withIdentifier: "MainPageController") as? MainPageController else { return }
        //
        //            window?.rootViewController = vc
        //            window?.makeKeyAndVisible()
        //        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

