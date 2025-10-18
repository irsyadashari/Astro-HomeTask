//
//  SwiftUI+Extensions.swift.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

extension String: @retroactive Identifiable {
    public var id: String { self }
}
