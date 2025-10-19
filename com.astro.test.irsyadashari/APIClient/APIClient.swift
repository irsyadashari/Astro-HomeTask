//
//  APIClient.swift
//  APIClient
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import Foundation
import Combine

public protocol APIClientProtocol {
    func searchUsers(query: String, page: Int, perPage: Int) -> AnyPublisher<GitHubSearchResponse, Error>
}

public final class APIClientImpl: APIClientProtocol {
    public init() {}
    
    public func searchUsers(query: String, page: Int, perPage: Int) -> AnyPublisher<GitHubSearchResponse, Error> {
        guard !query.isEmpty else {
            return Just(GitHubSearchResponse(totalCount: 0, items: []))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://api.github.com/search/users?q=\(query)&page=\(page)&per_page=\(perPage)") else {
            return Fail(error: APIError.badServerResponse).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                // 1. Check for valid HTTPResponse object
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.badServerResponse
                }
                
                // 2. Check for non-success status codes (e.g., 403, 404, 500)
                if !(200...299).contains(httpResponse.statusCode) {
                    // Try to decode the specific GitHub error message
                    if let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
                        // Throw custom error with the message
                        throw APIError.rateLimitExceeded(message: gitHubError.message)
                    } else {
                        // Throw a generic error if the response is bad or undecodable
                        throw APIError.badServerResponse
                    }
                }
                
                return data
            }
            .decode(type: GitHubSearchResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
