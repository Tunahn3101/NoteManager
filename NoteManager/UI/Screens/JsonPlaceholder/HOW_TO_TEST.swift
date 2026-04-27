//
//  CÁCH TEST JSONPLACEHOLDER DEMO
//
//  Thêm một trong các cách sau vào project để test
//

import SwiftUI

// ========================================
// CÁCH 1: Thêm vào ContentView (Recommended)
// ========================================

/*
// File: ContentView.swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // ... existing content ...
                
                NavigationLink("🧪 Test JSONPlaceholder API") {
                    JsonPlaceholderScreen()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
*/

// ========================================
// CÁCH 2: Thay thế LoadingScreen tạm thời
// ========================================

/*
// File: ContentView.swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            // Thay LoadingScreen() bằng JsonPlaceholderScreen() tạm thời
            JsonPlaceholderScreen()
        }
    }
}
*/

// ========================================
// CÁCH 3: Thêm vào HomeScreen toolbar
// ========================================

/*
// File: HomeScreen.swift
.toolbar {
    // ... existing toolbar items ...
    
    ToolbarItem(placement: .navigationBarLeading) {
        NavigationLink {
            JsonPlaceholderScreen()
        } label: {
            Label("API Demo", systemImage: "network")
        }
    }
}
*/

// ========================================
// CÁCH 4: Tạo Tab Bar với demo tab
// ========================================

/*
struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: App chính
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            // Tab 2: API Demo
            JsonPlaceholderScreen()
                .tabItem {
                    Label("API Demo", systemImage: "network")
                }
        }
    }
}

// Trong App file:
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()  // Dùng TabView
        }
    }
}
*/

// ========================================
// QUICK TEST - Command Line trong Playground
// ========================================

/*
// Tạo Playground file để test API logic
import Foundation

// Copy API code vào playground
let api = JsonPlaceholderApiImpl()

Task {
    do {
        // Test fetch posts
        let posts = try await api.fetchPosts()
        print("✅ Fetched \(posts.count) posts")
        print("First post: \(posts[0].title)")
        
        // Test create post
        let newPost = try await api.createPost(
            title: "Test Post",
            body: "This is a test",
            userId: 1
        )
        print("✅ Created post #\(newPost.id)")
        
        // Test delete
        try await api.deletePost(id: newPost.id)
        print("✅ Deleted post")
        
    } catch {
        print("❌ Error: \(error)")
    }
}
*/

// ========================================
// TEST CHECKLIST
// ========================================

/*
Sau khi add vào project, test các tính năng:

✅ 1. Launch app → See JsonPlaceholderScreen
✅ 2. Wait load → Should see 100 posts
✅ 3. Pull to refresh → Should reload
✅ 4. Tap + button → Show create sheet
✅ 5. Create new post → Should add to top of list
✅ 6. Swipe left → Should show delete/edit buttons
✅ 7. Delete post → Should remove from list
✅ 8. Tap on post → Show detail sheet
✅ 9. See comments → Should load comments
✅ 10. Check console → Should see print logs

Expected Console Output:
    🌐 Calling: https://jsonplaceholder.typicode.com/posts
    ✅ Fetched 100 posts successfully
    ✅ Created post #101 successfully
    ✅ Fetched 5 comments for post #1
    ✅ Deleted post #101 successfully
*/
