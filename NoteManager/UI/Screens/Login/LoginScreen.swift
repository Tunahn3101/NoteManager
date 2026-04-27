//
//  LoginScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct LoginScreen: View {

    @EnvironmentObject var logEnv: AppLogEnv
    @EnvironmentObject var apiEnv: ApiEnv
    @EnvironmentObject var storeEnv: StoreEnv
    @EnvironmentObject var mainEnv: MainViewModel
    @StateObject var vm = LoginViewModel()
    @State var isShowNext = false

    var isSkip: Bool

    init(isSkip: Bool) {
        self.isSkip = isSkip
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                if vm.loginStatus == .loading || vm.loginStatus == .done {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                } else {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Note Manager")
                            .font(.system(size: 32, weight: .bold))

                        Text("Đăng nhập để tiếp tục")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)

                    VStack(spacing: 16) {
                        CustomTextField(
                            icon: "person.fill",
                            placeholder: "Username",
                            text: $vm.user
                        )

                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $vm.pass,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 32)

                    // Login Button
                    Button {
                        Task {
                            await vm.login()
                        }
                    } label: {
                        Text("Đăng nhập")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.blue, Color.blue.opacity(0.8),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(
                                color: Color.blue.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            logEnv.appLog.d("LoginScreen", _msg: "isSkip = \(isSkip)")
            vm.api = apiEnv.api
            vm.store = storeEnv.store
        }
        .onChange(of: vm.loginStatus) { _ in
            if vm.loginStatus == .done {
                isShowNext = true
            } else if case .error(let msg) = vm.loginStatus {
                mainEnv.checkShowError(msg: msg)
            }

        }
        .navigationDestination(isPresented: $isShowNext) {
            HomeScreen()
        }
    }
}
