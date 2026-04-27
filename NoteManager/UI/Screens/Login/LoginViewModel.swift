//
//  LoginViewModel.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var user = ""
    @Published var pass = ""
    var api : Api?
    var store: Store?
    @Published var loginStatus = LoadStatus.initial
    
    func login() async {
        do {
            loginStatus = .loading
            try await api?.login(username: user, password: pass)
            
            // Lưu trạng thái đã login vào UserDefaults
            store?.setLoggedIn(true)
            
            loginStatus = .done
        } catch let e as AppError {
            if case .apiError(let msg) = e {
                loginStatus = .error(msg: msg)
            }
        } catch {
            loginStatus = .error(msg: "Other error")
        }
    }
}
