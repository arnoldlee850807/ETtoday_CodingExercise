//
//  Declarative.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import Foundation

protocol Declarative: AnyObject {
    init()
}

extension Declarative {
    init(configureHandler: (Self) -> Void) {
        self.init()
        configureHandler(self)
    }
}

extension NSObject: Declarative {}
