//
//  GitHubUserViewModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI
import Combine
import APIClient
import PersistenceService
import Repository

@MainActor
class GitHubUserViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isLoadingNextPage = false
    @Published var alertMessage: String?
    @Published var sortOrder: SortOrderType = .ascending
    @Published var searchHasCompleted = false
    
    var canLoadMorePages = true
    
    private var currentPage = 1
    private var currentQuery = ""
    private var cancellables = Set<AnyCancellable>()
    private var fetchUsersCancellable: AnyCancellable?
    
    private let repository: UserRepositoryProtocol
    
    var displayedUsers: [User] {
        users.sorted { u1, u2 in
            if sortOrder == .ascending {
                return u1.login.lowercased() < u2.login.lowercased()
            } else {
                return u1.login.lowercased() > u2.login.lowercased()
            }
        }
    }
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
        self.sortOrder = repository.loadSortOrder()
        
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] debouncedQuery in
                self?.searchUsers(with: debouncedQuery)
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(with query: String) {
        users = []
        currentPage = 1
        canLoadMorePages = true
        currentQuery = query
        searchHasCompleted = false
        
        fetchUsers()
    }
    
    func loadMoreContentIfNeeded(currentUser user: User?) {
        guard let user = user, let lastUser = displayedUsers.last else { return }
        
        if user.id == lastUser.id {
            fetchUsers()
        }
    }
    
    func toggleOrder(sort: SortOrderType) {
        sortOrder = sort
        repository.saveSortOrder(sort)
    }
    
    func toggleLike(for user: User) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        
        users[index].isLiked.toggle()
        repository.toggleFavoriteStatus(for: user)
    }
    
    private func fetchUsers() {
        guard !isLoading, !isLoadingNextPage, canLoadMorePages else { return }
        
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingNextPage = true
        }
        
        fetchUsersCancellable?.cancel()
        fetchUsersCancellable = repository.searchUsers(query: currentQuery, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isLoadingNextPage = false
                self?.searchHasCompleted = true
                
                if case .failure(let error) = completion {
                    self?.alertMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.users.append(contentsOf: result.users)
                self.currentPage += 1
                self.canLoadMorePages = self.users.count < result.totalCount
            })
    }
}
