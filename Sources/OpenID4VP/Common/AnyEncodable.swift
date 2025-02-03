//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 02/02/25.
//

import Foundation

struct AnyEncodable: Encodable {
    private let base: Encodable

    init<T: Encodable>(_ base: T) {
        self.base = base
    }

    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
