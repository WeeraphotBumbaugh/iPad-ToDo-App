//
//  AppDelegate.swift
//  TodoAppTask
//
//
import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if connectingSceneSession.role == .windowExternalDisplayNonInteractive {
            let config = UISceneConfiguration(
                name: "External Display Configuration",
                sessionRole: .windowExternalDisplayNonInteractive
            )
            config.delegateClass = ExternalDisplaySceneDelegate.self
            return config
        }

        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
