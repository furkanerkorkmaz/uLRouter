//
//  uLRouter.swift
//  uLRouter
//
//  Created by Furkan Erkorkmaz on 13/12/2020.
//  Copyright © 2020 Furkan Erkorkmaz. All rights reserved.
//

import UIKit

public class uLRouter {
    public static let shared: IsRouter = DefaultRouter()
}

public protocol uLNavigation { }

public protocol uLAppNavigation {
    func viewControllerFor(navigation: uLNavigation) -> UIViewController

    func pushViewController(_ navigation: uLNavigation, from: UIViewController, to: UIViewController)

    func presentViewController(_ navigation: uLNavigation, from: UIViewController, to: UIViewController, presentedStyle: UIModalPresentationStyle)

    func popViewController(from: UIViewController, isPresented: Bool)

    func popToViewController(from: UIViewController, to: UIViewController)
}

public protocol IsRouter {
    func setupAppNavigation(appNavigation: uLAppNavigation)

    func pushView(_ navigation: uLNavigation, from: UIViewController)

    func didNavigate(block: @escaping (uLNavigation) -> Void)

    func presentView(_ navigation: uLNavigation, from: UIViewController, presentedStyle: UIModalPresentationStyle)

    func popView(from: UIViewController, isPresented: Bool)

    func popToView(_ navigation: uLNavigation, from: UIViewController)

    var appNavigation: uLAppNavigation? { get }
}

public extension UIViewController {
    func pushView(_ navigation: uLNavigation) {
        uLRouter.shared.pushView(navigation, from: self)
    }

    func presentView(_ navigation: uLNavigation, _ style: UIModalPresentationStyle) {
        uLRouter.shared.presentView(navigation, from: self, presentedStyle: style)
    }

    func popView(isPresented: Bool) {
        uLRouter.shared.popView(from: self, isPresented: isPresented)
    }

    func popToView(_ navigation: uLNavigation) {
        uLRouter.shared.popToView(navigation, from: self)
    }

    func didNavigate(completion: @escaping (uLNavigation) -> Void) {
        uLRouter.shared.didNavigate { navigator in
            completion(navigator)
        }
    }
}

public class DefaultRouter: IsRouter {
    public var appNavigation: uLAppNavigation?

    var didNavigateBlocks = [(uLNavigation) -> Void]()

    public func setupAppNavigation(appNavigation: uLAppNavigation) {
        self.appNavigation = appNavigation
    }

    public func didNavigate(block: @escaping (uLNavigation) -> Void) {
        didNavigateBlocks.append(block)
    }

    public func pushView(_ navigation: uLNavigation, from: UIViewController) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            appNavigation?.pushViewController(navigation, from: from, to: toVC)
            for b in didNavigateBlocks {
                b(navigation)
            }
        }
    }

    public func presentView(_ navigation: uLNavigation, from: UIViewController, presentedStyle: UIModalPresentationStyle) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            toVC.modalPresentationStyle = presentedStyle
            appNavigation?.presentViewController(navigation, from: from, to: toVC, presentedStyle: presentedStyle)
        }
    }

    public func popView(from: UIViewController, isPresented: Bool) {
        if isPresented {
            from.dismiss(animated: true, completion: nil)
        } else {
            from.navigationController?.popViewController(animated: true)
        }
    }

    public func popToView(_ navigation: uLNavigation, from: UIViewController) {
        if let toVC = appNavigation?.viewControllerFor(navigation: navigation) {
            from.navigationController?.popToViewController(toVC, animated: true)
        }
    }
}

// Injection helper
public protocol Initializable { init() }
open class RuntimeInjectable: NSObject, Initializable {
    override public required init() {}
}

public func appNavigationFromString(_ appNavigationClassString: String) -> uLAppNavigation {
    let appNavClass = NSClassFromString(appNavigationClassString) as! RuntimeInjectable.Type
    let appNav = appNavClass.init()
    return appNav as! uLAppNavigation
}
