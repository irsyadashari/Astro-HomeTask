//
//  GitHubUserViewModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import Foundation

import Foundation
import Combine // 1. Import the Combine framework

@MainActor
class GitHubUserViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var sortOrder: SortOrder = .ascending
    
    var sortedUsers: [User] {
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
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] debouncedQuery in
                self?.searchUsers(with: debouncedQuery)
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(with query: String) {
        guard !query.isEmpty else {
            self.users = []
            return
        }
        
        guard let url = URL(string: "https://api.github.com/search/users?q=\(query)") else {
            self.alertMessage = "Invalid URL"
            return
        }
        
        self.isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: GitHubSearchResponse.self, decoder: JSONDecoder())
            .map(\.items)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedUsers in
                self?.isLoading = false
                self?.users = receivedUsers
            }
            .store(in: &cancellables)
    }
    
    func toggleLike(for user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isLiked.toggle()
        }
    }
}

enum SortOrder {
    case ascending, descending
}
