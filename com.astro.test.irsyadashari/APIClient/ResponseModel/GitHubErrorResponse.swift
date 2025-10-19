//
//  GitHubErrorResponse.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

struct GitHubErrorResponse: Codable {
    let message: String
    let documentationUrl: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case documentationUrl = "documentation_url"
    }
}
