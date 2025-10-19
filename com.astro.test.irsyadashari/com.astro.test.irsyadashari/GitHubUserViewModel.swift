//
//  GitHubUserViewModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import Foundation
import Combine
import CoreData

@MainActor
class GitHubUserViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isLoadingNextPage = false
    @Published var alertMessage: String?
    @Published var sortOrder: SortOrder = .ascending
    @Published var searchHasCompleted = false
    
    // Current Pagination index to call API
    private var currentPage = 1
    
    // To check if more items able to come
    var canLoadMorePages = true
    
    // Add a key for UserDefaults
    private let sortOrderKey = "sortOrderSetting"
    
    // Current search query
    private var currentQuery = ""
    
    // This will hold the IDs of all favorited users for quick checks
    private var favoriteUserIDs = Set<Int>()
    
    // CoreData's Context
    private var context: NSManagedObjectContext
    
    // Sorted Users based on SortOrder Settings
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
    
    // A dedicated property to hold our single network request
    private var fetchUsersCancellable: AnyCancellable?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
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
        
        // Load the initial set of favorites from Core Data
        fetchFavorites()
    }
    
    private func fetchFavorites() {
        let request = NSFetchRequest<FavoriteUser>(entityName: "FavoriteUser")
        do {
            let favorites = try context.fetch(request)
            // Store just the IDs in our set for fast lookups
            self.favoriteUserIDs = Set(favorites.map { Int($0.id) })
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }
    
    func searchUsers(with query: String) {
        // Reset everything for a new search
        users = []
        currentPage = 1
        canLoadMorePages = true
        currentQuery = query
        searchHasCompleted = false
        
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
        
        let perPage = 30
        guard let url = URL(string: "https://api.github.com/search/users?q=\(currentQuery)&page=\(currentPage)&per_page=\(perPage)") else {
            self.alertMessage = "Invalid URL"
            return
        }
        
        // Cancel any previous, in-flight request before starting a new one
        fetchUsersCancellable?.cancel()
        
        if currentPage == 1 {
            isLoading = true
            print("linecu: isLoadingNextPage")
        } else {
            print("linecu: isLoadingNextPage")
            isLoadingNextPage = true
        }
        
        fetchUsersCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.badServerResponse
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    if let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
                        throw APIError.rateLimitExceeded(message: gitHubError.message)
                    } else {
                        throw APIError.badServerResponse
                    }
                }
                
                return data
            }
            .decode(type: GitHubSearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                self?.isLoading = false
                self?.isLoadingNextPage = false
                self?.searchHasCompleted = true
                
                if case .failure(let error) = completion {
                    switch error {
                    case is URLError:
                        self?.alertMessage = error.localizedDescription
                        
                    case is DecodingError:
                        self?.alertMessage = "Could not process the server's response. Please try again later."
                        
                    default:
                        self?.alertMessage = "An unknown error occurred."
                    }
                }
            }, receiveValue: { [weak self] response in
                print("linecu: receiveValue")
                guard let self = self else { return }
                
                // Sync the liked status before updating the main list
                let syncedUsers = self.syncFavorites(with: response.items)
                
                self.users.append(contentsOf: syncedUsers)
                self.currentPage += 1
                self.canLoadMorePages = self.users.count < response.totalCount
            })
    }
    
    func toggleLike(for user: User) {
        // Find the user in our main list to update their UI state
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        
        let isNowLiked = !users[index].isLiked
        users[index].isLiked = isNowLiked
        
        if isNowLiked {
            // Add to Core Data
            let newFavorite = FavoriteUser(context: context)
            newFavorite.id = Int64(user.id)
            newFavorite.login = user.login
            newFavorite.avatarUrl = user.avatarUrl
            favoriteUserIDs.insert(user.id)
        } else {
            // Remove from Core Data
            let request = NSFetchRequest<FavoriteUser>(entityName: "FavoriteUser")
            request.predicate = NSPredicate(format: "id == %d", user.id)
            
            if let result = try? context.fetch(request).first {
                context.delete(result)
            }
            favoriteUserIDs.remove(user.id)
        }
        
        // Save the changes
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func syncFavorites(with networkUsers: [User]) -> [User] {
        return networkUsers.map { user in
            var updatedUser = user
            if favoriteUserIDs.contains(user.id) {
                updatedUser.isLiked = true
            }
            return updatedUser
        }
    }
    
    func toggleOrder(sort: SortOrder) {
        sortOrder = sort
        if let encodedData = try? JSONEncoder().encode(sortOrder) {
            UserDefaults.standard.set(encodedData, forKey: sortOrderKey)
        }
    }
}
