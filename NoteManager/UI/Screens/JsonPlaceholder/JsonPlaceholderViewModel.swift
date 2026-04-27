//
//  JsonPlaceholderViewModel.swift
//  NoteManager
//
//  ViewModel cho JSONPlaceholder Demo
//

import Foundation
import SwiftUI
import Combine  // ← THIẾU DÒNG NÀY!

/// @MainActor: Đảm bảo tất cả code trong class chạy trên Main Thread
/// Tại sao? Vì @Published properties update UI → phải ở main thread
/// ObservableObject: Protocol cho phép SwiftUI observe changes
@MainActor
class JsonPlaceholderViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// @Published: Khi giá trị thay đổi → tự động update UI
    /// SwiftUI sẽ re-render views đang observe property này
    
    @Published var posts: [Post] = []          // Danh sách posts
    @Published var selectedPost: Post?         // Post đang được chọn
    @Published var comments: [Comment] = []    // Comments của post
    @Published var user: User?                 // User info
    
    /// Loading states cho từng operation
    @Published var isLoadingPosts = false      // Đang load posts
    @Published var isLoadingComments = false   // Đang load comments
    @Published var isCreating = false          // Đang tạo post mới
    @Published var isUpdating = false          // Đang update post
    @Published var isDeleting = false          // Đang xóa post
    
    /// Error message để hiển thị cho user
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    /// API instance để call endpoints
    /// private: Chỉ dùng trong class này
    private var api: JsonPlaceholderApi = JsonPlaceholderApiImpl()
    
    // MARK: - Initialization
    init() {
        // Default init
    }
    func fetchPosts() async {
        // 1. Set loading state = true
        isLoadingPosts = true
        
        // 2. Clear error cũ
        errorMessage = nil
        
        // 3. Dùng defer để đảm bảo luôn set loading = false
        // defer: Code trong này chạy cuối cùng trước khi return
        // Dù success hay error, loading đều = false
        defer {
            isLoadingPosts = false
        }
        
        do {
            // 4. Call API
            // try: Function có thể throw error
            // await: Đợi async function complete
            let fetchedPosts = try await api.fetchPosts()
            
            // 5. Update state với data mới
            // Vì @MainActor, update này tự động ở main thread
            posts = fetchedPosts
            
            print("✅ Fetched \(fetchedPosts.count) posts successfully")
            
        } catch let error as APIError {
            // 6a. Handle API error
            errorMessage = error.errorDescription
            print("❌ API Error: \(error.errorDescription ?? "Unknown")")
            
        } catch {
            // 6b. Handle other errors
            errorMessage = "Lỗi không xác định: \(error.localizedDescription)"
            print("❌ Unknown Error: \(error)")
        }
    }
    
    // MARK: - Fetch Single Post
    /// Load chi tiết một post
    func fetchPost(id: Int) async {
        isLoadingPosts = true
        errorMessage = nil
        defer { isLoadingPosts = false }
        
        do {
            let post = try await api.fetchPost(id: id)
            selectedPost = post
            print("✅ Fetched post #\(id) successfully")
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Create Post
    /// Tạo post mới
    /// Returns: Post được tạo (có ID từ server)
    @discardableResult  // Cho phép không cần dùng return value
    func createPost(title: String, body: String, userId: Int = 1) async -> Post? {
        isCreating = true
        errorMessage = nil
        defer { isCreating = false }
        
        do {
            let newPost = try await api.createPost(
                title: title,
                body: body,
                userId: userId
            )
            
            // Thêm post mới vào đầu list
            posts.insert(newPost, at: 0)
            
            print("✅ Created post #\(newPost.id) successfully")
            return newPost
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Update Post
    /// Update toàn bộ post (PUT)
    func updatePost(id: Int, title: String, body: String, userId: Int) async -> Bool {
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }
        
        do {
            let updatedPost = try await api.updatePost(
                id: id,
                title: title,
                body: body,
                userId: userId
            )
            
            // Update post trong list
            if let index = posts.firstIndex(where: { $0.id == id }) {
                posts[index] = updatedPost
            }
            
            print("✅ Updated post #\(id) successfully")
            return true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Patch Post
    /// Update một phần post (PATCH)
    func patchPost(id: Int, title: String) async -> Bool {
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }
        
        do {
            let updatedPost = try await api.patchPost(id: id, title: title)
            
            if let index = posts.firstIndex(where: { $0.id == id }) {
                posts[index] = updatedPost
            }
            
            print("✅ Patched post #\(id) successfully")
            return true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Delete Post
    /// Xóa post
    func deletePost(id: Int) async -> Bool {
        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }
        
        do {
            try await api.deletePost(id: id)
            
            // Remove post khỏi list
            posts.removeAll { $0.id == id }
            
            print("✅ Deleted post #\(id) successfully")
            return true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Fetch Comments
    /// Load comments của một post
    func fetchComments(postId: Int) async {
        isLoadingComments = true
        errorMessage = nil
        defer { isLoadingComments = false }
        
        do {
            let fetchedComments = try await api.fetchComments(postId: postId)
            comments = fetchedComments
            print("✅ Fetched \(fetchedComments.count) comments for post #\(postId)")
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Fetch User
    /// Load thông tin user
    func fetchUser(id: Int) async {
        errorMessage = nil
        
        do {
            let fetchedUser = try await api.fetchUser(id: id)
            user = fetchedUser
            print("✅ Fetched user: \(fetchedUser.name)")
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helper Methods
    /// Clear tất cả data
    func clearAll() {
        posts = []
        selectedPost = nil
        comments = []
        user = nil
        errorMessage = nil
    }
}
