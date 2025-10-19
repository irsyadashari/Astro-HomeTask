//
//  UserModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct GitHubSearchResponse: Codable {
    let totalCount: Int
    let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct User: Identifiable, Codable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    
    var isLiked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
    }
}
