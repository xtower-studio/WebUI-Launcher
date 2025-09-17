// BookmarkManager.swift
import Foundation

enum BookmarkManager {
    private static let userDefaultsKey = "webuiFolderBookmark"

    static func saveBookmark(for url: URL) {
        do {
            // Start accessing the resource before creating the bookmark
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to start accessing security-scoped resource.")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: userDefaultsKey)
            print("Bookmark saved successfully.")
        } catch {
            print("Error creating bookmark: \(error.localizedDescription)")
        }
    }

    static func resolveBookmark() -> String? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
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
                // The original file/folder may have moved. We should re-create the bookmark.
                print("Bookmark is stale, trying to refresh.")
                saveBookmark(for: url)
            }
            
            return url.path
        } catch {
            print("Error resolving bookmark: \(error.localizedDescription)")
            return nil
        }
    }
}
