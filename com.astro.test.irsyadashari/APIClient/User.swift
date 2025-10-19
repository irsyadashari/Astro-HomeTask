//
//  User.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

public struct User: Identifiable, Codable, Equatable {
    public let id: Int
    public let login: String
    public let avatarUrl: String
    
    public var isLiked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
    }
}
