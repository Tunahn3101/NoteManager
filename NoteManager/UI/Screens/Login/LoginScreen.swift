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
    @EnvironmentObject var mainEnv: MainViewModel
    @StateObject var vm = LoginViewModel()
    @State var isShowNext = false

    var isSkip: Bool

    init(isSkip: Bool) {
        self.isSkip = isSkip
    }

    var body: some View {
        VStack {
            if (vm.loginStatus == .loading || vm.loginStatus == .done) {
                ProgressView()
            } else {
                TextField("Username", text: $vm.user).padding()
                SecureField("Password", text: $vm.pass).padding()

                Button("Login") {
                    Task {
                        await vm.login()
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            logEnv.appLog.d("LoginScreen", _msg: "isSkip = \(isSkip)")
            vm.api = apiEnv.api
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
