//
//  Chain.swift
//  sleeping
//
//  Created by 이경은 on 4/7/25.
//


import Foundation

public class Chain<Origin> {
    public var origin:Origin
    
    public init(origin: Origin) {
        self.origin = origin
    }
    
    public func done() {}
}

protocol Chainable {}

extension Chainable {
    var chain: Chain<Self> {
        return Chain(origin: self)
    }
}
