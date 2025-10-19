//
//  GitHubSearchResponse.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

public struct GitHubSearchResponse: Codable {
    public let totalCount: Int
    public let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
