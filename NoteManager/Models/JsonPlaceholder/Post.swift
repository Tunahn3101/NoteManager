//
//  Post.swift
//  NoteManager
//
//  JSONPlaceholder API Model
//

import Foundation

/// Model cho Post từ JSONPlaceholder API
/// Struct này represent một bài post từ API
/// Codable: Tự động encode/decode JSON ↔ Swift object
/// Identifiable: Có property 'id' unique để dùng trong List
struct Post: Codable, Identifiable {
    let userId: Int      // ID của user tạo post
    let id: Int          // ID unique của post
    let title: String    // Tiêu đề post
    let body: String     // Nội dung post
    
    // MARK: - Coding Keys
    /// CodingKeys: Map tên property Swift ↔ JSON keys
    /// Không cần thiết trong case này vì tên đã khớp
    /// Nhưng nếu JSON key khác (vd: "user_id"), thì cần:
    enum CodingKeys: String, CodingKey {
        case userId = "userId"  // userId trong Swift = userId trong JSON
        case id = "id"
        case title = "title"
        case body = "body"
    }
}

/// Model cho User từ JSONPlaceholder API
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    
    // Nested objects
    let address: Address
    let company: Company
    
    struct Address: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo
        
        struct Geo: Codable {
            let lat: String
            let lng: String
        }
    }
    
    struct Company: Codable {
        let name: String
        let catchPhrase: String
        let bs: String
    }
}

/// Model cho Comment từ JSONPlaceholder API
struct Comment: Codable, Identifiable {
    let postId: Int      // ID của post chứa comment này
    let id: Int          // ID unique của comment
    let name: String     // Tên/title comment
    let email: String    // Email người comment
    let body: String     // Nội dung comment
}

/// Request body khi tạo/update post
/// Struct này dùng để SEND data lên server
struct PostRequest: Codable {
    let title: String
    let body: String
    let userId: Int
}
