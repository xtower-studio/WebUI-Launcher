// BookmarkManager.swift
// WebUI Launcher
//
// Handles saving and loading security-scoped bookmarks for folder access on macOS.

import Foundation

class BookmarkManager {
    static func saveBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "webuiPathBookmark")
        } catch {
            print("Failed to save bookmark: \(error)")
        }
    }
    
    static func resolveBookmark() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "webuiPathBookmark") else { return nil }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}
