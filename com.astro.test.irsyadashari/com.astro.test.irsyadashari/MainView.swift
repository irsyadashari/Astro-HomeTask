//
//  MainView.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct GitHubUserListView: View {
    @StateObject private var viewModel = GitHubUserViewModel()
    @State private var searchText = "Andy"
    @State private var sortOrder: SortOrder = .ascending
    
    enum SortOrder {
        case ascending, descending
    }
    
    var sortedUsers: [User] {
        viewModel.users.sorted { u1, u2 in
            if sortOrder == .ascending {
                return u1.login.lowercased() < u2.login.lowercased()
            } else {
                return u1.login.lowercased() > u2.login.lowercased()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Github User")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Astro Test")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
                
                // Search Bar
                TextField("Search Users", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                HStack(spacing: 16) {
                    Button(action: { sortOrder = .ascending }) {
                        HStack {
                            Image(systemName: sortOrder == .ascending ? "circle.fill" : "circle")
                            Text("ASC")
                        }
                    }
                    Button(action: { sortOrder = .descending }) {
                        HStack {
                            Image(systemName: sortOrder == .descending ? "circle.fill" : "circle")
                            Text("DESC")
                        }
                    }
                    Spacer()
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // User List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else {
                    List(sortedUsers) { user in
                        HStack {
                            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 44, height: 44)
                            
                            Text(user.login)
                                .font(.body)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleLike(for: user)
                            }) {
                                Image(systemName: user.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(user.isLiked ? .red : .gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .alert(item: $viewModel.alertMessage) { message in
                Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct GitHubUserListView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubUserListView()
    }
}
