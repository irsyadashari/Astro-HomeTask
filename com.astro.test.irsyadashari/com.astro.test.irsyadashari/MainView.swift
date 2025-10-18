//
//  MainView.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

// MARK: - User Model
struct User: Identifiable {
    let id = UUID()
    let name: String
    var isLiked: Bool = false
}

// MARK: - Main View
struct GitHubUserListView: View {
    @State private var searchText: String = ""
    @State private var sortOrder: SortOrder = .asc
    @State private var users: [User] = [
        User(name: "Olivia Martin"),
        User(name: "Liam Johnson", isLiked: true), // Example liked user
        User(name: "Sophia Chen"),
        User(name: "Noah Williams"),
        User(name: "Isabella Garcia"),
        User(name: "Ethan Rodriguez"),
        User(name: "Mia Kim"),
        User(name: "Lucas Brown"),
        User(name: "Ava Jones"),
        User(name: "Leo Davis"),
        User(name: "Charlotte Miller")
    ]
    
    enum SortOrder {
        case asc, desc
    }
    
    // Computed property for filtered and sorted users
    var filteredAndSortedUsers: [User] {
        var sortedUsers = users.sorted { u1, u2 in
            if sortOrder == .asc {
                return u1.name < u2.name
            } else {
                return u1.name > u2.name
            }
        }
        
        if searchText.isEmpty {
            return sortedUsers
        } else {
            return sortedUsers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView { // Use NavigationView for the title bar
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Header
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
                
                // MARK: - Search Bar
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder) // A common style for search fields
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                // MARK: - Sort Radio Buttons
                HStack {
                    // ASC Radio Button
                    Button(action: { sortOrder = .asc }) {
                        HStack {
                            Image(systemName: sortOrder == .asc ? "circle.fill" : "circle")
                                .foregroundColor(.accentColor) // Blue circle for selected
                            Text("ASC")
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain) // Remove default button styling
                    
                    Spacer()
                        .frame(width: 30) // Spacing between radio buttons
                    
                    // DESC Radio Button
                    Button(action: { sortOrder = .desc }) {
                        HStack {
                            Image(systemName: sortOrder == .desc ? "circle.fill" : "circle")
                                .foregroundColor(.accentColor)
                            Text("DESC")
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                
                // MARK: - User List
                List {
                    ForEach(filteredAndSortedUsers) { user in
                        HStack {
                            Image(systemName: "person.circle.fill") // Placeholder for avatar
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                            Text(user.name)
                                .font(.body)
                            Spacer()
                            Button(action: {
                                // Toggle like status for the user
                                if let index = users.firstIndex(where: { $0.id == user.id }) {
                                    users[index].isLiked.toggle()
                                }
                            }) {
                                Image(systemName: user.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(user.isLiked ? .red : .gray)
                            }
                            .buttonStyle(.plain) // Remove default button styling
                        }
                    }
                }
                .listStyle(.plain) // Use plain list style to remove default separators/background
            }
            .navigationBarHidden(true) // Hide the default NavigationView bar to use our custom header
        }
    }
}

// MARK: - Preview Provider
struct GitHubUserListView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubUserListView()
    }
}
