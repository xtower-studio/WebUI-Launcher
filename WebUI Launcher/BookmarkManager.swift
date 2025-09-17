//
//  BookmarkManager.swift
//  WebUI Launcher
//
//  Created by Juhyung Park on 9/2/25.
//

import Foundation
import AppKit

/// Manages security-scoped bookmarks for sandboxed file access
class BookmarkManager {
    private static let bookmarkKey = "webuiFolderBookmark"
    
    /// Saves a security-scoped bookmark for the given URL
    static func saveBookmark(for url: URL) {
        do {
            // Create a security-scoped bookmark that persists across app launches
            let bookmarkData = try url.bookmarkData(
                options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            print("Bookmark saved for: \(url.path)")
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }
    
    /// Resolves a saved bookmark and returns the path if successful
    static func resolveBookmark() -> String? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("Bookmark is stale, removing...")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            
            // Important: Don't start accessing here - that should be done when actually needed
            return url.path
        } catch {
            print("Failed to resolve bookmark: \(error)")
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
            return nil
        }
    }
    
    /// Resolves bookmark and returns the URL with security scope access started
    static func resolveBookmarkWithAccess() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("Bookmark is stale, removing...")
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                return nil
            }
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to start accessing security-scoped resource")
                return nil
            }
            
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
            return nil
        }
    }
    
    /// Removes the saved bookmark
    static func removeBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }
}