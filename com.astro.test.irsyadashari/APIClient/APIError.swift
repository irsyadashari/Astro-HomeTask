//
//  APIError.swift
//  
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case rateLimitExceeded(message: String)
    case badServerResponse
    
    public var errorDescription: String? {
        switch self {
        case .rateLimitExceeded(let message):
            return message
        case .badServerResponse:
            return "The server returned an invalid response."
        }
    }
}
