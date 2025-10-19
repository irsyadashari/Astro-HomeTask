//
//  MockUserRepository.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import Combine
import Foundation
import XCTest
@testable import Repository
@testable import APIClient
@testable import PersistenceService

final class MockUserRepository: UserRepositoryProtocol {
    
    // Properties to control test behavior
    var shouldReturnError = false
    var returnedUsers: [User] = []
    var totalUserCount: Int = 0
    var savedSortOrder: SortOrderType = .ascending
    
    // Test data structure (assuming User/SortOrderType are accessible)
    let testUsers = [
        User(id: 1, login: "Alice", avatarUrl: "", isLiked: false),
        User(id: 2, login: "Bob", avatarUrl: "", isLiked: false),
        User(id: 3, login: "Charlie", avatarUrl: "", isLiked: false),
        User(id: 4, login: "David", avatarUrl: "", isLiked: false)
    ]
    
    // MARK: - UserRepositoryProtocol Implementation
    
    func searchUsers(query: String, page: Int) -> AnyPublisher<(users: [User], totalCount: Int), Error> {
        if shouldReturnError {
            let testError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Mock Repository Error"])
            return Fail(error: testError).eraseToAnyPublisher()
        }
        
        let pageSize = 2 // Define page size for mock
        let startIndex = (page - 1) * pageSize
        
        // Check if startIndex is out of bounds
        if startIndex >= testUsers.count {
            return Just((users: [], totalCount: testUsers.count))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Define the chunk of users for the current page
        let endIndex = min(startIndex + pageSize, testUsers.count)
        let usersForPage = Array(testUsers[startIndex..<endIndex])
        
        // Use Future and a small delay to simulate asynchronous network latency
        return Future<(users: [User], totalCount: Int), Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                promise(.success((users: usersForPage, totalCount: self.testUsers.count)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func toggleFavoriteStatus(for user: User) {
        //only for assert that this function was called in the test case
    }
    
    func loadSortOrder() -> SortOrderType {
        return savedSortOrder
    }
    
    func saveSortOrder(_ order: SortOrderType) {
        savedSortOrder = order
    }
}
