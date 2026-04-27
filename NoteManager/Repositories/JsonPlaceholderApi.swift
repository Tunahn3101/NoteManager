//
//  JsonPlaceholderApi.swift
//  NoteManager
//
//  API Layer cho JSONPlaceholder - DEMO Modern API Call
//

import Foundation

// MARK: - Protocol Definition
/// Protocol định nghĩa các methods call API
/// Tại sao dùng Protocol?
/// - Dễ test (mock)
/// - Dễ swap implementation (production vs mock)
/// - Follow Dependency Injection pattern
protocol JsonPlaceholderApi {
    /// GET: Lấy tất cả posts
    /// async: Function chạy bất đồng bộ, không block UI
    /// throws: Function có thể throw error
    /// -> [Post]: Return array of Post
    func fetchPosts() async throws -> [Post]
    
    /// GET: Lấy 1 post theo ID
    func fetchPost(id: Int) async throws -> Post
    
    /// POST: Tạo post mới
    func createPost(title: String, body: String, userId: Int) async throws -> Post
    
    /// PUT: Update toàn bộ post
    func updatePost(id: Int, title: String, body: String, userId: Int) async throws -> Post
    
    /// PATCH: Update một phần post
    func patchPost(id: Int, title: String) async throws -> Post
    
    /// DELETE: Xóa post
    func deletePost(id: Int) async throws
    
    /// GET: Lấy comments của một post
    func fetchComments(postId: Int) async throws -> [Comment]
    
    /// GET: Lấy thông tin user
    func fetchUser(id: Int) async throws -> User
}

// MARK: - Implementation
/// Implementation thực tế của protocol
/// Class này chứa logic call API thật
class JsonPlaceholderApiImpl: JsonPlaceholderApi {
    
    // MARK: - Properties
    /// Base URL của API
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    /// URLSession để call API
    /// shared: Instance singleton của URLSession
    /// Có thể custom configuration nếu cần (timeout, cache policy, etc)
    private let session: URLSession
    
    /// JSONDecoder để parse JSON → Swift objects
    private let decoder: JSONDecoder
    
    /// JSONEncoder để parse Swift objects → JSON
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - GET: Fetch All Posts
    /// Lấy tất cả posts (100 posts)
    /// Endpoint: GET /posts
    func fetchPosts() async throws -> [Post] {
        // 1. Tạo URL từ string
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }
        
        // 2. Call API với async/await
        // URLSession.shared.data(from:) tự động:
        // - Tạo request GET
        // - Gửi request
        // - Đợi response
        // - Return (data, response)
        let (data, response) = try await session.data(from: url)
        
        // 3. Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // 4. Check status code (200-299 = success)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 5. Decode JSON → Swift objects
        // JSONDecoder tự động parse JSON array → [Post]
        let posts = try decoder.decode([Post].self, from: data)
        
        // 6. Return data
        return posts
    }
    
    // MARK: - GET: Fetch Single Post
    /// Lấy 1 post theo ID
    /// Endpoint: GET /posts/{id}
    func fetchPost(id: Int) async throws -> Post {
        guard let url = URL(string: "\(baseURL)/posts/\(id)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let post = try decoder.decode(Post.self, from: data)
        return post
    }
    
    // MARK: - POST: Create New Post
    /// Tạo post mới
    /// Endpoint: POST /posts
    /// Body: JSON { title, body, userId }
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }
        
        // 1. Tạo request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Method: POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  // Header
        
        // 2. Tạo request body
        let requestBody = PostRequest(title: title, body: body, userId: userId)
        
        // 3. Encode Swift object → JSON
        request.httpBody = try encoder.encode(requestBody)
        
        // 4. Call API với custom request
        let (data, response) = try await session.data(for: request)
        
        // 5. Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        // 6. Decode response
        let post = try decoder.decode(Post.self, from: data)
        return post
    }
    
    // MARK: - PUT: Update Entire Post
    /// Update toàn bộ post (replace)
    /// Endpoint: PUT /posts/{id}
    /// PUT = Replace toàn bộ resource
    func updatePost(id: Int, title: String, body: String, userId: Int) async throws -> Post {
        guard let url = URL(string: "\(baseURL)/posts/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"  // Method: PUT
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = PostRequest(title: title, body: body, userId: userId)
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let post = try decoder.decode(Post.self, from: data)
        return post
    }
    
    // MARK: - PATCH: Partial Update
    /// Update một phần post
    /// Endpoint: PATCH /posts/{id}
    /// PATCH = Update chỉ những field được gửi lên
    func patchPost(id: Int, title: String) async throws -> Post {
        guard let url = URL(string: "\(baseURL)/posts/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // Method: PATCH
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Chỉ gửi field cần update
        let requestBody = ["title": title]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let post = try decoder.decode(Post.self, from: data)
        return post
    }
    
    // MARK: - DELETE: Remove Post
    /// Xóa post
    /// Endpoint: DELETE /posts/{id}
    func deletePost(id: Int) async throws {
        guard let url = URL(string: "\(baseURL)/posts/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // Method: DELETE
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        // DELETE không return data, chỉ cần check status code
    }
    
    // MARK: - GET: Fetch Comments
    /// Lấy comments của một post
    /// Endpoint: GET /posts/{postId}/comments
    func fetchComments(postId: Int) async throws -> [Comment] {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/comments") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let comments = try decoder.decode([Comment].self, from: data)
        return comments
    }
    
    // MARK: - GET: Fetch User
    /// Lấy thông tin user
    /// Endpoint: GET /users/{id}
    func fetchUser(id: Int) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let user = try decoder.decode(User.self, from: data)
        return user
    }
}

// MARK: - Error Definition
/// Custom error types cho API
/// enum: Định nghĩa các loại error có thể xảy ra
enum APIError: Error, LocalizedError {
    case invalidURL              // URL không hợp lệ
    case invalidResponse         // Response không hợp lệ
    case httpError(statusCode: Int)  // HTTP error với status code
    case decodingError          // Lỗi parse JSON
    case networkError(Error)    // Lỗi network (no internet, timeout, etc)
    
    /// Mô tả error cho user
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL không hợp lệ"
        case .invalidResponse:
            return "Response từ server không hợp lệ"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Không thể parse dữ liệu từ server"
        case .networkError(let error):
            return "Lỗi kết nối: \(error.localizedDescription)"
        }
    }
}
