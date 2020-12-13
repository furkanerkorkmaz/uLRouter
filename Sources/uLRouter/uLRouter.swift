//
//  uLRouter.swift
//  uLRouter
//
//  Created by Furkan Erkorkmaz on 13/12/2020.
//  Copyright © 2020 Furkan Erkorkmaz. All rights reserved.
//

import UIKit

public class uLRouter {
    public static let shared:IsRouter = DefaultRouter()
}

public protocol uLNavigation { }

public protocol uLAppNavigation {
    func viewControllerFor(navigation: uLNavigation) -> UIViewController
    func pushView(_ navigation: uLNavigation, from: UIViewController,to: UIViewController)
    func presentView(_ navigation: uLNavigation, from: UIViewController,to: UIViewController)
    func popView(from: UIViewController, isPresented: Bool)
    func popToView(from: UIViewController, to: UIViewController)
}

public protocol IsRouter {
    func setupAppNavigation(appNavigation: uLAppNavigation)
    func pushView(_ navigation: uLNavigation, from: UIViewController)
    func didNavigate(block: @escaping (uLNavigation) -> Void)
    func presentView(_ navigation: uLNavigation, from: UIViewController)
    func popView(from: UIViewController, isPresented: Bool)
    func popToView(_ navigation: uLNavigation,from: UIViewController)
    var appNavigation: uLAppNavigation? { get }
}

public extension UIViewController {
    func navigate(_ navigation: uLNavigation) {
        uLRouter.shared.pushView(navigation, from: self)
    }
}

public class DefaultRouter: IsRouter {

    public var appNavigation: uLAppNavigation?

    var didNavigateBlocks = [((uLNavigation) -> Void)] ()

    public func setupAppNavigation(appNavigation: uLAppNavigation) {
        self.appNavigation = appNavigation
    }

    public func didNavigate(block: @escaping (uLNavigation) -> Void) {
        didNavigateBlocks.append(block)
    }

    public func pushView(_ navigation: uLNavigation, from: UIViewController) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            appNavigation?.pushView(navigation, from: from, to: toVC)
            for b in didNavigateBlocks {
                b(navigation)
            }
        }
    }

    public func presentView(_ navigation: uLNavigation, from: UIViewController) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            appNavigation?.presentView(navigation, from: from, to: toVC)
        }
    }

    public func popView(from: UIViewController, isPresented: Bool) {
        if isPresented  {
            from.dismiss(animated: true, completion: nil)
        }else {
            from.navigationController?.popViewController(animated: true)
        }
    }

    public func popToView(_ navigation: uLNavigation,from: UIViewController) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            from.navigationController?.popToViewController(toVC, animated: true)
        }
    }

}

// Injection helper
public protocol Initializable { init() }
open class RuntimeInjectable: NSObject, Initializable {
    public required override init() {}
}

public func appNavigationFromString(_ appNavigationClassString: String) -> uLAppNavigation {
    let appNavClass = NSClassFromString(appNavigationClassString) as! RuntimeInjectable.Type
    let appNav = appNavClass.init()
    return appNav as! uLAppNavigation
}

