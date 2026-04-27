//
//  CustomTextField.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct CustomTextField: View {
    
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon bên trái
            Image(systemName: icon)
                .foregroundColor(isFocused ? .blue : .gray)
                .frame(width: 20)
                .font(.system(size: 18))
            
            // Text field / Secure field
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            // Toggle button cho password (chỉ hiện khi isSecure = true)
            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Color.blue.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// Preview
#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            icon: "person.fill",
            placeholder: "Username",
            text: .constant("john_doe")
        )
        
        CustomTextField(
            icon: "lock.fill",
            placeholder: "Password",
            text: .constant("mypassword123"),
            isSecure: true
        )
        
        CustomTextField(
            icon: "envelope.fill",
            placeholder: "Email",
            text: .constant("")
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
