//
//  com_astro_test_irsyadashariApp.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

@main
struct com_astro_test_irsyadashariApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            GitHubUserListView()
        }
    }
}
