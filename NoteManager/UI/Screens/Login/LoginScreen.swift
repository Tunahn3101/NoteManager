//
//  LoginScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct LoginScreen: View {
    
    var isSkip: Bool
    
    
    init(isSkip: Bool) {
        self.isSkip = isSkip
    }
    
    var body: some View {
        VStack{
            Text("Loagin Screen")
            Text("isSkip: \(isSkip.description)")
        }
        .navigationBarBackButtonHidden()
    }
}
