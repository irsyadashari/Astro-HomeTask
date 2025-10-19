# Astro-HomeTask

# GitHub User Search App

This document serves as the project brief and technical overview for the GitHub User Search application.

---

## Project Overview

This is a modern iOS application built using **SwiftUI** and **Combine** to search for GitHub users via the GitHub Search API. The project is designed using a clean, scalable architecture (**MVVM-R** with a **Repository Pattern**) and modularization (**Custom Frameworks**) to ensure separation of concerns, excellent testability, and maintainability.

---

## Architecture and Modularity

The project adheres to the **MVVM-R (Model-View-ViewModel-Repository)** pattern. All functional dependencies are segregated into dedicated, reusable framework targets.

### Key Architectural Decisions

* **Repository Pattern:** The `UserRepository` acts as a single source of truth, abstracting data logic away from the `ViewModel`. It orchestrates calls between the `APIClient` (remote data) and the `PersistenceService` (local data).

* **Dependency Injection:** All dependencies (Services, Repositories) are initialized and injected at the `App` struct (Composition Root), ensuring the `ViewModel` is highly testable and decoupled from concrete implementations.

* **Swift Concurrency in Testing:** Unit tests use the modern `async/await` and `XCTestExpectation` patterns for reliable asynchronous testing.

### Modules (Framework Targets)

| **Module** | **Responsibility** | **Dependencies** | 
| :--- | :--- | :--- | 
| **Main App Target** (com.astro.test.irsyadashari)| Handles UI composition, view logic, and dependency injection. | All custom Frameworks | 
| **APIClient** | Handles all network requests, URL construction, status code validation, and JSON decoding/encoding. | Foundation, Combine | 
| **PersistenceService** | Handles all local data storage operations (Core Data and UserDefaults). | CoreData, Foundation | 
| **UserRepository** | Coordinates data: Fetches users from API and syncs their favorite status with the local database before delivering data to the ViewModel. | APIClient, PersistenceService | 

---

## Features

### Core Functionality

* **GitHub User Search:** Real-time search for users with debouncing to prevent excessive API calls while typing. The search is not triggered when the input is empty or on initial load.

* **Infinite Scrolling (Pagination):** Loads the next page of results automatically when the user scrolls to the end of the current list.

* **Sort Control:** Users can toggle between **Ascending (ASC)** and **Descending (DESC)** alphabetical order based on username.

### Data Persistence

* **Core Data Favorites:** User "likes" (favorites) are persisted locally using **Core Data** across app launches. The repository syncs the favorite status when new search results are fetched.

* **UserDefaults Settings:** The user's last selected sort order (`ASC` or `DESC`) is saved using **UserDefaults** and loaded upon app launch.

### Error Handling

* **Graceful API Errors:** The app correctly identifies and displays informative alerts for network issues (`URLError`), data decoding errors, and specific GitHub API errors (e.g., **Rate Limiting**), using the actual message returned in the API's JSON response.

* **Race Condition Mitigation:** Uses Combine's `cancellable` pattern to manage and cancel in-flight network requests, preventing app freezes and data corruption on rapid user input.

---

## Technical Stack

* **Language:** Swift 5.8+

* **Frameworks:** SwiftUI, Combine, Core Data

* **Testing:** XCTest

* **Architecture:** MVVM-R, Repository Pattern, Dependency Injection (DI)

---
