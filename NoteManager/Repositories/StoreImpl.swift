//
//  StoreImpl.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import Foundation

class StoreImpl: Store {
    func loadInitData(onProgress: (Double) -> Void) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        onProgress(0.33)
        try await Task.sleep(nanoseconds: 500_000_000)
        onProgress(0.66)
        try await Task.sleep(nanoseconds: 500_000_000)
        onProgress(1)
    }
    
    func isFirstStart() -> Bool {
        return !UserDefaults.standard.bool(forKey: "is_second_start")
    }
    
    func setNoteFirstStart() {
        UserDefaults.standard.set("true", forKey: "is_second_start")
    }
    
    
}
