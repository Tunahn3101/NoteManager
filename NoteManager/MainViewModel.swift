//
//  MainViewModel.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var msg : String = ""
    @Published var isShowError  = false


    
    func checkShowError(msg: String){
        if isShowError == false && msg.isEmpty == false {
            self.msg = msg
            isShowError = true
        }
    }
}
