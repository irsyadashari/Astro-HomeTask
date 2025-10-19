//
//  GitHubUserViewModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import Foundation
import Combine

@MainActor
class GitHubUserViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isLoadingNextPage = false
    @Published var alertMessage: String?
    @Published var sortOrder: SortOrder = .ascending
    
    
    private var currentPage = 1
    var canLoadMorePages = true
    
    // Add a key for UserDefaults
    private let sortOrderKey = "sortOrderSetting"
    
    // Current search query
    private var currentQuery = ""
    
    var displayedUsers: [User] {
        users.sorted { u1, u2 in
            if sortOrder == .ascending {
                return u1.login.lowercased() < u2.login.lowercased()
            } else {
                return u1.login.lowercased() > u2.login.lowercased()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] debouncedQuery in
                self?.searchUsers(with: debouncedQuery)
            }
            .store(in: &cancellables)
        
        // Load User Settings
        if let savedData = UserDefaults.standard.data(forKey: sortOrderKey),
           let decodedOrder = try? JSONDecoder().decode(SortOrder.self, from: savedData) {
            self.sortOrder = decodedOrder
        }
    }
    
    func searchUsers(with query: String) {
        // Reset everything for a new search
        users = []
        currentPage = 1
        canLoadMorePages = true
        currentQuery = query
        
        fetchUsers()
    }
    
    func loadMoreContentIfNeeded(currentUser user: User?) {
        guard let user = user, let lastUser = displayedUsers.last else {
            return
        }
        
        if user.id == lastUser.id {
            fetchUsers()
        }
    }
    
    func fetchUsers() {
        guard !isLoading, !isLoadingNextPage, canLoadMorePages else {
            return
        }
        
        guard !currentQuery.isEmpty else {
            self.users = []
            return
        }
        
        let perPage = 10
        guard let url = URL(string: "https://api.github.com/search/users?q=\(currentQuery)&page=\(currentPage)&per_page=\(perPage)") else {
            self.alertMessage = "Invalid URL"
            return
        }
        
        if currentPage == 1 {
            isLoading = true
            print("linecu: isLoadingNextPage")
        } else {
            print("linecu: isLoadingNextPage")
            isLoadingNextPage = true
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                //Check for the rate limit error
                if httpResponse.statusCode == 403 {
                    throw APIError.rateLimitExceeded
                }
                
                //  general check for other bad statuses
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.badServerResponse
                }
                return data
            }
            .decode(type: GitHubSearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isLoadingNextPage = false
                print("linecu: receiveCompletion")
                if case .failure(let error) = completion {
                    print("--- FETCH FAILED with error: \(error) ---")
                    
                    switch error {
                    case let apiError as APIError:
                        self?.alertMessage = apiError.errorDescription
                        
                    case is URLError:
                        self?.alertMessage = "Network error. Please check your connection and try again."
                        
                    case is DecodingError:
                        self?.alertMessage = "Could not process the server's response. Please try again later."
                        
                    default:
                        self?.alertMessage = "An unknown error occurred."
                    }
                }
            }, receiveValue: { [weak self] response in
                print("linecu: receiveValue")
                // 5. Append new users and update pagination state
                self?.users.append(contentsOf: response.items)
                self?.currentPage += 1
                self?.canLoadMorePages = (self?.users.count ?? 0) < response.totalCount
            })
            .store(in: &cancellables)
    }
    
    func toggleLike(for user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isLiked.toggle()
        }
    }
    
    func toggleOrder(sort: SortOrder) {
        sortOrder = sort
        if let encodedData = try? JSONEncoder().encode(sortOrder) {
            UserDefaults.standard.set(encodedData, forKey: sortOrderKey)
        }
    }
}
