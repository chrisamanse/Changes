//
//  StringChanges.swift
//  Changes
//
//  Created by Chris Amanse on 1/21/16.
//  Copyright © 2016 Joe Christopher Paul Amanse. All rights reserved.
//

import Foundation

public extension String {
    public func changesSince(oldValue: String, reduced: Bool = true) -> [Change<Character>] {
        return characters.changesSince(oldValue.characters, reduced: reduced)
    }
}
