//
//  DetailScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct DetailScreen: View {
    @EnvironmentObject var vm: HomeViewModel
    @State var isShowEdit = false
    var isSingleScreen: Bool
    @Environment(\.presentationMode) var presentationMode

    init(isSingleScreen: Bool) {
        self.isSingleScreen = isSingleScreen
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                if vm.notes.count > vm.selectedIdx {
                    List {
                        Text("Date Time: \(vm.notes[vm.selectedIdx].dateTime)")
                        Text("Title: \(vm.notes[vm.selectedIdx].title)")
                        Text("Content: \(vm.notes[vm.selectedIdx].content)")
                        Button("Edit") {
                            isShowEdit = true
                            
                        }
                    }
                } else {
                    // Không có note nào được chọn (màn ngang)
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Chọn một ghi chú để xem chi tiết")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onChange(of: geo.size) { _ in
                if geo.size.width > geo.size.height && isSingleScreen {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            // Chỉ hiện title và toolbar khi là single screen (màn dọc)
            .navigationTitle(isSingleScreen ? "Chi tiết" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isSingleScreen {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sửa") {
                            isShowEdit = true
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isShowEdit) {
                AddOrEditScreen(isAdd: false).environmentObject(vm)
            }
        }
    }
}
