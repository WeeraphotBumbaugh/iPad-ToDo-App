//
//  ExternalDisplaySceneDelegate.swift
//  TodoAppTask
//
//
import UIKit
import SwiftUI

final class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let win = UIWindow(windowScene: windowScene)
        win.rootViewController = UIHostingController(rootView: ExternalDisplayView())
        win.isHidden = false
        window = win
    }
}
