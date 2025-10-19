//
//  PersistenceService.swift
//  PersistenceService
//
//  Created by Muh Irsyad Ashari on 10/19/25.
//

import Foundation
import CoreData
import APIClient

public protocol PersistenceServiceProtocol {
    func fetchFavoriteIDs() -> Set<Int>
    func toggleFavoriteStatus(for user: User)
    func loadSortOrder() -> SortOrderType
    func saveSortOrder(_ order: SortOrderType)
}

public final class PersistenceServiceImpl: PersistenceServiceProtocol {
    private let context: NSManagedObjectContext // For Core Data
    private let sortOrderKey = "sortOrderSetting" // For User Defaults
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func fetchFavoriteIDs() -> Set<Int> {
        let request = NSFetchRequest<FavoriteUser>(entityName: "FavoriteUser")
        do {
            let favorites = try context.fetch(request)
            return Set(favorites.map { Int($0.id) })
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
    
    public func toggleFavoriteStatus(for user: User) {
        let request = NSFetchRequest<FavoriteUser>(entityName: "FavoriteUser")
        request.predicate = NSPredicate(format: "id == %d", user.id)
        
        do {
            if let existingFavorite = try context.fetch(request).first {
                context.delete(existingFavorite)
            } else {
                let newFavorite = FavoriteUser(context: context)
                newFavorite.id = Int64(user.id)
                newFavorite.login = user.login
                newFavorite.avatarUrl = user.avatarUrl
            }
            
            try context.save()
            
        } catch {
            print("Failed to toggle favorite status: \(error)")
        }
    }
    
    public func loadSortOrder() -> SortOrderType {
        if let savedData = UserDefaults.standard.data(forKey: sortOrderKey),
           let decodedOrder = try? JSONDecoder().decode(SortOrderType.self, from: savedData) {
            return decodedOrder
        }
        return .ascending
    }
    
    public func saveSortOrder(_ order: SortOrderType) {
        if let encodedData = try? JSONEncoder().encode(order) {
            UserDefaults.standard.set(encodedData, forKey: sortOrderKey)
        }
    }
}

