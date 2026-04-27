//
//  AddOrEditScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct AddOrEditScreen: View {

    var isAdd: Bool
    @EnvironmentObject var mainEnv: MainViewModel
    @EnvironmentObject var vm: HomeViewModel
    @State var title: String = ""
    @State var content: String = ""
    @FocusState private var focusedField: Field?
    
    @Environment(\.presentationMode) var presentationMode
    
    enum Field {
        case title, content
    }

    init(isAdd: Bool) {
        self.isAdd = isAdd
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header với icon
                    VStack(spacing: 8) {
                        Image(systemName: isAdd ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(isAdd ? "Tạo ghi chú mới" : "Chỉnh sửa ghi chú")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(isAdd ? "Ghi lại những ý tưởng của bạn" : "Cập nhật nội dung ghi chú")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Title input với custom design
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Tiêu đề", systemImage: "text.alignleft")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            TextField("Nhập tiêu đề ghi chú...", text: $title)
                                .focused($focusedField, equals: .title)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .content
                                }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    focusedField == .title ? Color.blue : Color.gray.opacity(0.3),
                                    lineWidth: focusedField == .title ? 2 : 1
                                )
                        )
                        .shadow(
                            color: focusedField == .title ? Color.blue.opacity(0.2) : Color.clear,
                            radius: 8, x: 0, y: 4
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                    .padding(.horizontal)
                    
                    // Content input với custom design
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Nội dung", systemImage: "square.and.pencil")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ZStack(alignment: .topLeading) {
                            // Placeholder khi empty
                            if content.isEmpty {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 20)
                                        .padding(.top, 12)
                                        .padding(.leading, 12)
                                    
                                    Text("Nhập nội dung ghi chú của bạn...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 12)
                                }
                            }
                            
                            TextEditor(text: $content)
                                .focused($focusedField, equals: .content)
                                .frame(minHeight: 200)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    focusedField == .content ? Color.blue : Color.gray.opacity(0.3),
                                    lineWidth: focusedField == .content ? 2 : 1
                                )
                        )
                        .shadow(
                            color: focusedField == .content ? Color.blue.opacity(0.2) : Color.clear,
                            radius: 8, x: 0, y: 4
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                    .padding(.horizontal)
                    
                    // Character count
                    HStack {
                        Spacer()
                        Label("\(content.count) ký tự", systemImage: "textformat.size")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                    
                    // Action button
                    if vm.loadStatus == .loading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                            .padding()
                    } else {
                        Button(action: saveNote) {
                            HStack {
                                Image(systemName: isAdd ? "plus.circle.fill" : "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text(isAdd ? "Thêm ghi chú" : "Lưu thay đổi")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Group {
                                    if title.isEmpty || content.isEmpty {
                                        Color.gray
                                    } else {
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: (title.isEmpty || content.isEmpty) ? Color.clear : Color.blue.opacity(0.3),
                                radius: 8, x: 0, y: 4
                            )
                        }
                        .disabled(title.isEmpty || content.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle(isAdd ? "Thêm ghi chú" : "Sửa ghi chú")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    focusedField = nil
                } label: {
                    Text("Xong")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            // Load dữ liệu note hiện tại khi edit
            if !isAdd {
                loadCurrentNote()
            }
        }
    }
    
    // Load dữ liệu note hiện tại
    private func loadCurrentNote() {
        guard vm.notes.indices.contains(vm.selectedIdx) else { return }
        let note = vm.notes[vm.selectedIdx]
        title = note.title
        content = note.content
    }
    
    // Save note function
    private func saveNote() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        Task {
            if isAdd {
                await vm.addNote(title: title, content: content)
            } else {
                await vm.editSelectedNote(title: title, content: content)
            }
            
            // Check status và dismiss nếu thành công
            if vm.loadStatus == .done {
                // Success haptic
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                presentationMode.wrappedValue.dismiss()
            } else if case .error(let msg) = vm.loadStatus {
                // Error haptic
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                
                mainEnv.checkShowError(msg: msg)
            }
        }
    }
}
