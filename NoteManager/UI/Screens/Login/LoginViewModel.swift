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
    @Published var loginStatus = LoadStatus.initial
    
    func login() async {
        do {
            
        } catch let e as AppError {
            
        }
    }
}
