//
//  Repository.swift
//  Repository
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import PersistenceService
import APIClient
import Foundation
import Combine

public protocol UserRepositoryProtocol {
    func searchUsers(query: String, page: Int) -> AnyPublisher<(users: [User], totalCount: Int), Error>
    func toggleFavoriteStatus(for user: User)
    func loadSortOrder() -> SortOrderType
    func saveSortOrder(_ order: SortOrderType)
}

public class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let persistenceService: PersistenceServiceProtocol
    private let perPage = 30
    
    public init(apiClient: APIClientProtocol, persistenceService: PersistenceServiceProtocol) {
        self.apiClient = apiClient
        self.persistenceService = persistenceService
    }
    
    public func searchUsers(query: String, page: Int) -> AnyPublisher<(users: [User], totalCount: Int), Error> {
        return apiClient.searchUsers(query: query, page: page, perPage: perPage)
            .map { response -> (users: [User], totalCount: Int) in
                let favoriteIDs = self.persistenceService.fetchFavoriteIDs()
                let syncedUsers = response.items.map { user -> User in
                    var updatedUser = user
                    if favoriteIDs.contains(user.id) {
                        updatedUser.isLiked = true
                    }
                    return updatedUser
                }
                
                return (syncedUsers, response.totalCount)
            }
            .eraseToAnyPublisher()
    }
    
    public func toggleFavoriteStatus(for user: User) {
        persistenceService.toggleFavoriteStatus(for: user)
    }
    
    public func loadSortOrder() -> SortOrderType {
        return persistenceService.loadSortOrder()
    }
    
    public func saveSortOrder(_ order: SortOrderType) {
        persistenceService.saveSortOrder(order)
    }
}

