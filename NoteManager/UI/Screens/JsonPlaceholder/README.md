# 📚 JSONPlaceholder API Demo - Modern SwiftUI & async/await

## 🎯 Mục đích
Tutorial hoàn chỉnh về cách call API trong SwiftUI theo chuẩn mới nhất (2024-2026) sử dụng:
- ✅ async/await (Swift Concurrency)
- ✅ @MainActor
- ✅ Protocol-oriented programming
- ✅ ObservableObject & @Published
- ✅ Modern SwiftUI views

## 📂 Cấu trúc Files

```
Models/JsonPlaceholder/
  └─ Post.swift                    // Data models (Post, User, Comment)

Repositories/
  └─ JsonPlaceholderApi.swift      // API Layer (Protocol + Implementation)

UI/Screens/JsonPlaceholder/
  ├─ JsonPlaceholderViewModel.swift  // Business Logic
  └─ JsonPlaceholderScreen.swift     // UI Layer
```

## 🔄 Luồng hoạt động

```
┌─────────────────┐
│ View            │  JsonPlaceholderScreen
│ (UI Layer)      │  - Hiển thị data
└────────┬────────┘  - Handle user actions
         │           - Task { await vm.method() }
         ↓
┌─────────────────┐
│ ViewModel       │  JsonPlaceholderViewModel
│ (Logic Layer)   │  - @MainActor
└────────┬────────┘  - @Published properties
         │           - async functions
         ↓
┌─────────────────┐
│ API Layer       │  JsonPlaceholderApiImpl
│ (Data Layer)    │  - URLSession + async/await
└────────┬────────┘  - JSON encode/decode
         │
         ↓
┌─────────────────┐
│ Server          │  https://jsonplaceholder.typicode.com
│ (Backend)       │  - REST API
└─────────────────┘  - Returns JSON
```

## 📝 Các API Endpoints được implement

### GET Requests
- `GET /posts` - Lấy tất cả posts (100 posts)
- `GET /posts/{id}` - Lấy 1 post theo ID
- `GET /posts/{postId}/comments` - Lấy comments của post
- `GET /users/{id}` - Lấy thông tin user

### POST Request
- `POST /posts` - Tạo post mới
  ```json
  Body: {
    "title": "...",
    "body": "...",
    "userId": 1
  }
  ```

### PUT Request
- `PUT /posts/{id}` - Update toàn bộ post
  ```json
  Body: {
    "id": 1,
    "title": "...",
    "body": "...",
    "userId": 1
  }
  ```

### PATCH Request
- `PATCH /posts/{id}` - Update một phần post
  ```json
  Body: {
    "title": "..."
  }
  ```

### DELETE Request
- `DELETE /posts/{id}` - Xóa post

## 🎓 Các Concepts Quan Trọng

### 1. async/await
```swift
// Async function
func fetchPosts() async throws -> [Post] {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Post].self, from: data)
}

// Call trong View
Task {
    await viewModel.fetchPosts()
}
```

**Lợi ích:**
- Code đọc như synchronous, dễ hiểu
- Không callback hell
- Tự động quản lý threading
- Built-in cancellation support

### 2. @MainActor
```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var data = ""  // Luôn update trên main thread
}
```

**Tại sao?**
- UI updates phải ở main thread
- @Published trigger UI update
- Compiler đảm bảo thread-safe

### 3. Task
```swift
Button("Load") {
    Task {  // Tạo async context
        await viewModel.loadData()
    }
}
```

**Khi nào dùng?**
- Call async function từ sync context
- Trong button action, onAppear, etc.

### 4. .task modifier
```swift
.task {
    // Tự động cancel khi view disappear
    await viewModel.loadData()
}
```

**vs .onAppear?**
- `.task` = async version của `.onAppear`
- Tự động cancel khi view biến mất
- Không cần Task { }

### 5. .refreshable
```swift
List { }
    .refreshable {
        await viewModel.refresh()
    }
```

**Lợi ích:**
- Pull-to-refresh built-in
- Tự động hiện loading indicator
- await cho đến khi complete

## 🔧 Cách sử dụng

### 1. Test trong app
Thêm vào Navigation hoặc Tab để test:

```swift
// Trong ContentView.swift hoặc Navigation.swift
NavigationLink("JSONPlaceholder Demo") {
    JsonPlaceholderScreen()
}
```

### 2. Hoặc test trực tiếp
```swift
// Trong App file
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            JsonPlaceholderScreen()  // Test trực tiếp
        }
    }
}
```

## 🎯 Các tính năng Demo

### ✅ Đã implement
- [x] Fetch all posts
- [x] Pull to refresh
- [x] Create new post
- [x] Delete post (swipe)
- [x] View post detail
- [x] Load comments
- [x] Error handling
- [x] Loading states
- [x] Haptic feedback

### 🔄 Có thể extend thêm
- [ ] Edit post (đã có button, chưa có sheet)
- [ ] Pagination (load more)
- [ ] Search posts
- [ ] Filter by user
- [ ] Cache với UserDefaults
- [ ] Offline mode

## 📊 API Response Examples

### GET /posts
```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere...",
    "body": "quia et suscipit..."
  },
  // ... 99 more posts
]
```

### POST /posts (Response)
```json
{
  "userId": 1,
  "id": 101,  // Server generated
  "title": "My new post",
  "body": "This is the content"
}
```

### GET /posts/1/comments
```json
[
  {
    "postId": 1,
    "id": 1,
    "name": "id labore ex...",
    "email": "Eliseo@gardner.biz",
    "body": "laudantium enim..."
  },
  // ... more comments
]
```

## 🐛 Debugging Tips

### 1. Print requests
```swift
print("🌐 Calling: \(url)")
print("📤 Body: \(String(data: body, encoding: .utf8) ?? "")")
```

### 2. Print responses
```swift
print("📥 Response: \(String(data: data, encoding: .utf8) ?? "")")
```

### 3. Check status code
```swift
print("Status Code: \(httpResponse.statusCode)")
```

### 4. Monitor trong Console
- ✅ Success messages: "✅ Fetched X posts"
- ❌ Error messages: "❌ API Error: ..."

## 🎨 UI Features

- Gradient background (blue → purple)
- Pull to refresh
- Swipe to delete/edit
- Modal sheets cho create/detail
- Loading indicators
- Error messages
- Haptic feedback (trong ViewModel)

## 📚 Học thêm

### Concepts cần hiểu
1. **Swift Concurrency**
   - async/await
   - Task
   - @MainActor
   - Structured concurrency

2. **SwiftUI State Management**
   - @State
   - @StateObject
   - @ObservedObject
   - @Published

3. **Networking**
   - URLSession
   - URLRequest
   - HTTP methods
   - JSON encode/decode

4. **Architecture**
   - MVVM pattern
   - Protocol-oriented programming
   - Dependency injection

## 🚀 Next Steps

1. Run app và test các functions
2. Đọc comments trong code
3. Thử modify để hiểu rõ hơn
4. Implement thêm features
5. Apply vào project thật

## ⚡ Performance Tips

1. **Cancellation**: Dùng `.task` thay vì `.onAppear` cho auto-cancel
2. **Caching**: Cache data để giảm API calls
3. **Debounce**: Dùng debounce cho search
4. **Pagination**: Load theo page thay vì load all
5. **Image loading**: Dùng AsyncImage cho images

## 🎯 Kết luận

Đây là **CHUẨN** call API trong SwiftUI hiện đại:
- ✅ async/await (không dùng completion handler)
- ✅ @MainActor (tự động main thread)
- ✅ Protocol + Implementation (testable)
- ✅ Error handling với custom Error types
- ✅ Loading states với @Published
- ✅ Modern SwiftUI modifiers (.task, .refreshable)

**Code này ready to use cho production!** 🚀
