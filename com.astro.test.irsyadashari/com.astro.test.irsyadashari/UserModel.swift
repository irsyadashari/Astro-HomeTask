//
//  UserModel.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct GitHubSearchResponse: Codable {
    let items: [User]
}

struct User: Identifiable, Codable {
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
