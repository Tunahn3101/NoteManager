//
//  LoadingViewModel.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI
import Combine

@MainActor
class LoadingViewModel: ObservableObject {
    @Published var percent: Double = 0.0
    @Published var loadStatus = LoadStatus.initial
    @Published var isFirstStart = false
    @Published var isLoggedIn = false
    var store : Store?


    func loadData(){
        loadStatus = .loading
        Task {
            if let store = store {
                // Call real store loader which should invoke the onProgress closure
                try await store.loadInitData(onProgress: { d in
                    // Ensure UI update happens on main actor
                    Task { @MainActor in
                        self.percent = d
                    }
                })
            } else {
                // Fallback simulated progress for debugging when store is not set
                for i in 1...10 {
                    try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
                    await MainActor.run {
                        self.percent = Double(i) / 10.0
                    }
                }
            }

            await MainActor.run {
                loadStatus = .done
            }
        }
        isFirstStart = store?.isFirstStart() ?? true
        isLoggedIn = store?.isLoggedIn() ?? false
    }


    func setSecondStart() {
        store?.setNoteFirstStart()
    }

}
