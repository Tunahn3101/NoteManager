//
//  TutorialScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct TutorialScreen: View {
    @State var isSkip = false
    @State var isShowNext = false
    var body: some View {

        VStack {
            Image(systemName: "book").padding()
            HStack {
                Button("Skip") {
                    isSkip = true
                    isShowNext = true
                }.padding()
                Button("Read All") {
                    isSkip = false
                    isShowNext = true
                }.padding()
                
            }
        }
        .navigationDestination(isPresented: $isShowNext) {
            LoginScreen(isSkip: isSkip)
        }
        .navigationBarBackButtonHidden(true)
    }

}

