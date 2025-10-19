//
//  MainView.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct GitHubUserListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GitHubUserViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: GitHubUserViewModel(context: PersistenceController.shared.container.viewContext)
        )
    }
    
    // MARK: - Main Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                searchBar
                sortControls
                userList
                bottomIndicator
            }
            .alert(item: $viewModel.alertMessage) { message in
                Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Github User")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Astro Test")
                    .font(.title2)
                    .bold()
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
    
    // MARK: - Search Bar View
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search Users", text: $viewModel.searchText)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    // MARK: - Control View ASC - DESC
    private var sortControls: some View {
        HStack(spacing: 0) {
            SortOptionView(
                title: "ASC",
                isSelected: viewModel.sortOrder == .ascending
            ) {
                viewModel.toggleOrder(sort: .ascending)
            }
            SortOptionView(
                title: "DESC",
                isSelected: viewModel.sortOrder == .descending
            ) {
                viewModel.toggleOrder(sort: .descending)
            }
        }
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // MARK: - Users List View
    @ViewBuilder
    private var userList: some View {
        if viewModel.isLoading {
            ProgressView("Searching...")
                .frame(maxHeight: .infinity)
        } else if viewModel.users.isEmpty {
            emptyStateView(searchHasCompleted: viewModel.searchHasCompleted)
        } else {
            List {
                ForEach(viewModel.displayedUsers) { user in
                    UserRowView(user: user) {
                        viewModel.toggleLike(for: user)
                    }
                    .onAppear {
                        viewModel.loadMoreContentIfNeeded(currentUser: user)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var bottomIndicator: some View {
        if viewModel.isLoadingNextPage {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical)
        } else if !viewModel.canLoadMorePages && !viewModel.users.isEmpty {
            HStack {
                Spacer()
                Text("End of Results")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private func emptyStateView(searchHasCompleted: Bool) -> some View {
        VStack(spacing: 12) {
            if searchHasCompleted {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("No Users Found")
                    .font(.title2)
                    .bold()
                Text("There are no users that match your search. Please try another name.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("Search GitHub Users")
                    .font(.title2)
                    .bold()
                Text("Type in the search bar to find users.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct GitHubUserListView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubUserListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
