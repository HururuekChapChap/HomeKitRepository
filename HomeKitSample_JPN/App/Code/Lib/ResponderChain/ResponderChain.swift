//
//  ResponderChain.swift
//
//  Created by ToKoRo on 2017-08-19.
//

import UIKit

struct ResponderChain {
    let from: UIResponder

    func send<V, P>(_ value: V, protocol: P.Type, adopter: (V, P) -> Void) {
        from.next?.relayValue(value, protocol: `protocol`, adopter: adopter, from: from)
    }
}

// MARK: - UIResponder

extension UIResponder {
    fileprivate func relayValue<V, P>(_ value: V, protocol: P.Type, adopter: (V, P) -> Void, from: UIResponder) {
        if let impl = findProtocolImplementation(`protocol`, from: from) {
            adopter(value, impl)
            return
        }
        
        next?.relayValue(value, protocol: `protocol`, adopter: adopter, from: from)
    }

    private func findProtocolImplementation<P>(_ protocol: P.Type, from: UIResponder) -> P? {
        switch self {
        case let navi as UINavigationController:
            for viewController in navi.viewControllers where viewController != from {
                
                print("네비게이션 - 뷰 컨트롤러 : \(viewController)")
                
                guard let impl = viewController as? P else {
                    continue
                }
                return impl
            }
            return self as? P
        case let tab as UITabBarController:
            for viewController in tab.viewControllers ?? [] where viewController != from {
                
                print("TabBar - 뷰 컨트롤러 : \(viewController)")
                
                guard let impl = viewController as? P else {
                    continue
                }
                return impl
            }
            return self as? P
        default:
            let item = self as? P
            
            return item
        }
    }
}
