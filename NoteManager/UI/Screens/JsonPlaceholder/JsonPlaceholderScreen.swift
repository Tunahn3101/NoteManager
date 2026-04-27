//
//  JsonPlaceholderScreen.swift
//  NoteManager
//
//  Demo Screen cho JSONPlaceholder API
//

import SwiftUI

struct JsonPlaceholderScreen: View {
    
    // MARK: - Properties
    /// @StateObject: Tạo và sở hữu ViewModel instance
    /// ViewModel sẽ tồn tại trong suốt lifecycle của View
    @StateObject private var viewModel = JsonPlaceholderViewModel()
    
    /// @State: Local state của View
    @State private var showCreateSheet = false
    @State private var newTitle = ""
    @State private var newBody = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Error message nếu có
                    if let error = viewModel.errorMessage {
                        Text("❌ \(error)")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding()
                    }
                    
                    // List posts
                    if viewModel.isLoadingPosts && viewModel.posts.isEmpty {
                        // Loading state (lần đầu)
                        ProgressView("Đang tải posts...")
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.posts) { post in
                                PostRow(post: post, viewModel: viewModel)
                            }
                        }
                        .listStyle(.plain)
                        /// .refreshable: Pull-to-refresh gesture
                        /// Kéo xuống → trigger closure
                        /// await: Đợi async function complete
                        .refreshable {
                            await viewModel.fetchPosts()
                        }
                    }
                }
            }
            .navigationTitle("JSONPlaceholder Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            /// .sheet: Present modal sheet
            /// isPresented: Binding để show/hide sheet
            .sheet(isPresented: $showCreateSheet) {
                CreatePostSheet(
                    title: $newTitle,
                    postBody: $newBody,
                    onCreate: {
                        /// Task: Tạo context để chạy async code
                        /// Trong closure của Button/sheet, không thể await trực tiếp
                        /// → Cần wrap trong Task { }
                        Task {
                            await viewModel.createPost(title: newTitle, body: newBody)
                            showCreateSheet = false
                            newTitle = ""
                            newBody = ""
                        }
                    }
                )
            }
        }
        /// .task: Async version của .onAppear
        /// Tự động cancel khi view disappear
        .task {
            // Load posts khi view xuất hiện
            await viewModel.fetchPosts()
        }
    }
}

// MARK: - Post Row
/// Component hiển thị 1 post trong list
struct PostRow: View {
    let post: Post
    @ObservedObject var viewModel: JsonPlaceholderViewModel
    
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User ID badge
            HStack {
                Text("User #\(post.userId)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text("ID: \(post.id)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Title
            Text(post.title)
                .font(.headline)
                .lineLimit(2)
            
            // Body preview
            Text(post.body)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
        /// .swipeActions: Swipe gesture với custom actions
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Delete button
            Button(role: .destructive) {
                Task {
                    await viewModel.deletePost(id: post.id)
                }
            } label: {
                Label("Xóa", systemImage: "trash")
            }
            
            // Edit button
            Button {
                // TODO: Show edit sheet
                print("Edit post #\(post.id)")
            } label: {
                Label("Sửa", systemImage: "pencil")
            }
            .tint(.blue)
        }
        /// .onTapGesture: Handle tap
        .onTapGesture {
            viewModel.selectedPost = post
            showDetail = true
        }
        /// .sheet: Show detail modal
        .sheet(isPresented: $showDetail) {
            PostDetailSheet(post: post, viewModel: viewModel)
        }
    }
}

// MARK: - Create Post Sheet
/// Sheet để tạo post mới
struct CreatePostSheet: View {
    @Binding var title: String
    @Binding var postBody: String
    let onCreate: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tiêu đề") {
                    TextField("Nhập tiêu đề post...", text: $title)
                }
                
                Section("Nội dung") {
                    TextEditor(text: $postBody)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Button("Tạo Post") {
                        onCreate()
                    }
                    .disabled(title.isEmpty || postBody.isEmpty)
                }
            }
            .navigationTitle("Tạo Post Mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Post Detail Sheet
/// Sheet hiển thị chi tiết post + comments
struct PostDetailSheet: View {
    let post: Post
    @ObservedObject var viewModel: JsonPlaceholderViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Post info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("User #\(post.userId)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text(post.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(post.body)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Divider()
                    
                    // Comments section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Comments")
                                .font(.headline)
                            
                            if viewModel.isLoadingComments {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.comments.isEmpty {
                            Text("Chưa có comments")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.comments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(comment.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(comment.email)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text(comment.body)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chi tiết Post #\(post.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
            }
            /// .task: Load comments khi sheet xuất hiện
            .task {
                await viewModel.fetchComments(postId: post.id)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    JsonPlaceholderScreen()
}
