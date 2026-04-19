//
//  LoadingScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject var storeEnv: StoreEnv
    @StateObject var vm = LoadingViewModel()
    
    @State var isShowNext = false
    
    var body: some View {
        VStack{
            ProgressView()
            Text("Loading \(Int((vm.percent * 100)))%")
        }
        .onAppear{
            vm.store = storeEnv.store
            vm.loadData()
        }
        .onChange(of: vm.loadStatus) { _ in
            if (vm.loadStatus == .done) {
                if (vm.isFirstStart) {
                    vm.setSecondStart()
                    
                }
                isShowNext = true
            }
            
        }
        .navigationDestination(isPresented: $isShowNext) {
            if(vm.isFirstStart){
                TutorialScreen()
            } else {
                LoginScreen(isSkip: true)
            }
        }
    }
}
