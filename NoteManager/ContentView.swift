//
//  ContentView.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var api = ApiEnv(api: ApiImpl())
    @StateObject var store = StoreEnv(store: StoreImpl())
    @StateObject var log = AppLogEnv(appLog: AppLogImpl())
    @StateObject var mainVM = MainViewModel()
    
    
    var body: some View {
        NavigationStack {
            LoadingScreen()
                .alert("Alert", isPresented: $mainVM.isShowError) {
                    Button("Cancel", role: .cancel){
                        //logic
                    }
                } message: {
                    Text("\(mainVM.msg)")
                }
            
        }
        .environmentObject(api)
        .environmentObject(store)
        .environmentObject(log)
        .environmentObject(mainVM)
    }
}

#Preview {
    ContentView()
}
