//
//  APIError.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case rateLimitExceeded
    case badServerResponse
    
    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded:
            return "API rate limit reached. Please wait a moment before trying again."
        case .badServerResponse:
            return "The server returned an invalid response."
        }
    }
}
