//
//  String+HN.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 1/14/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import Foundation

extension URL {
    var hostWithoutWWW: String? {
        guard let host = self.host else {
            return nil
        }
        if host.prefix(4) == "www." {
            guard let indexOfDot = host.firstIndex(of: ".") else {
                return host
            }
            var host = host
            host.removeSubrange(host.startIndex...indexOfDot)
            return host
        }
        return host
    }
}
