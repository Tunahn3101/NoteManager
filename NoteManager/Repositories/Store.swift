//
//  Store.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI
import Combine

class StoreEnv: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    var store: Store
    
    init(store: Store) {
        self.store = store
    }
}


protocol Store {
    func loadInitData(onProgress:((Double)->Void)) async throws
    func isFirstStart() -> Bool
    func setNoteFirstStart()
    
    // Authentication state
    func isLoggedIn() -> Bool
    func setLoggedIn(_ value: Bool)
}
