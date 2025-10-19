//
//  GitHubUserViewModelTests.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import XCTest
import Combine
@testable import com_astro_test_irsyadashari

final class GitHubUserViewModelTests: XCTestCase {
    
    var mockRepository: MockUserRepository!
    var viewModel: GitHubUserViewModel!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()

        mockRepository = MockUserRepository()
        viewModel = GitHubUserViewModel(repository: mockRepository)
        cancellables = []
    }
    
    @MainActor
    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization and Sorting Tests
    
    @MainActor
    func testInitialStateAndSortOrderLoad() {
        XCTAssertEqual(viewModel.sortOrder, .ascending, "Default sort order should be ascending.")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially.")
    }
    
    @MainActor
    func testSortOrderTogglesAndSaves() {
        // Arrange
        let initialOrder = viewModel.sortOrder
        
        // Act
        viewModel.toggleOrder(sort: .descending)
        
        // Assert
        XCTAssertEqual(viewModel.sortOrder, .descending, "Sort order should be descending after toggle.")
        XCTAssertEqual(mockRepository.savedSortOrder, .descending, "New sort order should be saved to repository.")
    }
    
    // MARK: - Search and Fetching Tests
    
    @MainActor
    func testSearchTriggersInitialFetchAndResetsState() {
        // Act
        viewModel.searchUsers(with: "testQuery")
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 0, "Users should be empty after state reset.")
        XCTAssertTrue(viewModel.isLoading, "VM should be in loading state for page 1.")
        XCTAssertFalse(viewModel.searchHasCompleted, "Search should not be marked as complete yet.")
    }
    
    @MainActor
    func testSuccessfulFetchUpdatesState() async throws {
        // 1. Arrange: Create the expectation
        let expectation = XCTestExpectation(description: "Fetch completed and loading state is false")
        
        // Act
        viewModel.searchUsers(with: "A")
        
        // 2. Observe the isLoading state
        viewModel.$isLoading
        // Drop the initial false state, then wait for the first 'true' (start loading)
        // and the second 'false' (finish loading)
            .dropFirst(2)
            .sink { isLoading in
                // Assert the FINAL states when isLoading flips back to false (completion)
                if !isLoading {
                    XCTAssertEqual(self.viewModel.users.count, 2, "Users count must be correct.")
                    XCTAssertTrue(self.viewModel.searchHasCompleted, "Search should be marked as complete after final state update.")
                    XCTAssertTrue(self.viewModel.canLoadMorePages, "Should be able to load more pages.")
                    
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testFetchFailureSetsAlertMessage() {
        // Arrange
        let expectation = XCTestExpectation(description: "Fetch failed and alert message set")
        mockRepository.shouldReturnError = true
        viewModel.searchText = "A"
        
        // Act
        viewModel.searchUsers(with: "A")
        
        // Assert
        viewModel.$alertMessage
            .dropFirst()
            .sink { message in
                XCTAssertNotNil(message, "Alert message should be set on failure.")
                XCTAssertFalse(self.viewModel.isLoading, "Loading should be false after failure.")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Pagination Tests
    
    @MainActor
    func testLoadMoreTriggersNextPage() async throws {
        // 1. Phase 1: Initial Fetch (Page 1)
        let initialExp = XCTestExpectation(description: "Initial Fetch Completed")
        viewModel.searchText = "A"
        viewModel.searchUsers(with: "A")
        
        var usersCancellable: AnyCancellable?
        
        usersCancellable = viewModel.$users
            .dropFirst()
            .sink { users in
                if users.count == 2 {
                    initialExp.fulfill()
                    usersCancellable?.cancel()
                }
            }
        
        await fulfillment(of: [initialExp], timeout: 1.0)
        
        // 2. Phase 2: Load Next Page (Page 2)
        let nextLoadExp = XCTestExpectation(description: "Next Page Load Completed")
        let lastUser = viewModel.displayedUsers.last!
        
        // Set up a NEW sink to observe the next change (users.count from 2 to 4)
        viewModel.$users
        // Filter guarantees the sink only fires when the data is ready
            .filter { $0.count == 4 }
            .sink { users in
                nextLoadExp.fulfill()
            }
            .store(in: &cancellables)
        
        // Act: Trigger the load more
        viewModel.loadMoreContentIfNeeded(currentUser: lastUser)
        
        // Wait for the second expectation
        await fulfillment(of: [nextLoadExp], timeout: 1.0)
        
        XCTAssertEqual(viewModel.users.count, 4, "Total users loaded should be 4.")
        XCTAssertFalse(viewModel.isLoadingNextPage, "Next page loading should be false on completion.")
        XCTAssertFalse(viewModel.canLoadMorePages, "Should be false after loading all 4 users.")
    }
}
