//
//  com_astro_test_irsyadashariApp.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI
import CoreData
import APIClient
import PersistenceService
import Repository

@main
struct com_astro_test_irsyadashariApp: App {
    // Shared Core Data controller
    let persistenceController = PersistenceController.shared
    
    // 1. Build the Dependency Graph and ViewModel (Composition Root)
    private var viewModel: GitHubUserViewModel
    
    init() {
        // Core Data Context
        let context = persistenceController.container.viewContext
        
        // Services
        let persistenceService = PersistenceServiceImpl(context: context)
        let apiClient = APIClientImpl()
        
        // Repository
        let repository = UserRepository(
            apiClient: apiClient,
            persistenceService: persistenceService
        )
        
        // Final ViewModel
        self.viewModel = GitHubUserViewModel(repository: repository)
    }
    
    var body: some Scene {
        WindowGroup {
            GitHubUserListView(viewModel: self.viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
