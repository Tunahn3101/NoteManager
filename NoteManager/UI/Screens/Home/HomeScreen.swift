//
//  HomeScreen.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import SwiftUI

struct HomeScreen: View {

    @EnvironmentObject var apiEnv: ApiEnv
    @EnvironmentObject var storeEnv: StoreEnv
    @EnvironmentObject var mainEnv: MainViewModel
    @StateObject var vm = HomeViewModel()
    @State var deleting = false
    @State var isShowAdd = false
    @State var isLogout = false

    var body: some View {
        VStack {
            if vm.loadStatus == .loading {
                ProgressView()
            } else {
                GeometryReader {
                    geo in
                    if geo.size.width <= geo.size.height {
                        // Màn DỌC: List full màn
                        ListNoteView()
                            .onAppear {
                                vm.isVerticalLayout = true
                            }
                    } else {
                        // Màn NGANG: Split view
                        HStack(spacing: 0) {
                            ListNoteView()
                                .frame(width: geo.size.width * 0.4)

                            Divider()

                            DetailScreen(isSingleScreen: false)
                                .frame(width: geo.size.width * 0.6)
                        }
                        .onAppear {
                            vm.isVerticalLayout = false
                        }
                    }
                }
            }
        }
        .environmentObject(vm)
        .navigationTitle("Ghi chú")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowAdd = true

                } label: {
                    Label("Thêm", systemImage: "plus")
                }

            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Logout: Xóa trạng thái đăng nhập
                    storeEnv.store.setLoggedIn(false)
                    isLogout = true
                } label: {
                    Label(
                        "Đăng xuất",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    JsonPlaceholderScreen()
                } label: {
                    Label("API Demo", systemImage: "network")
                }
            }
        }
        .navigationDestination(isPresented: $isLogout) {
            LoginScreen(isSkip: false)
        }
        .navigationDestination(isPresented: $isShowAdd) {
            AddOrEditScreen(isAdd: true).environmentObject(vm)
        }
        .onAppear {
            vm.api = apiEnv.api
            // Chỉ load lần đầu, không load khi back về
            Task {
                await vm.loadNotesIfNeeded()
            }
        }

    }
}

struct ListNoteView: View {
    @EnvironmentObject var vm: HomeViewModel
    @State var isShowEdit = false
    var body: some View {
        List {
            ForEach(vm.notes, id: \.self) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.title)
                            .bold()
                        Text("_(\(item.dateTime))")
                        Spacer()
                    }
                    Text(item.content)
                }
                .padding(.vertical, 4)
                .background(
                    // Highlight item được chọn (chỉ khi ở màn ngang)
                    !vm.isVerticalLayout
                        && vm.notes.firstIndex(of: item) == vm.selectedIdx
                        ? Color.blue.opacity(0.15)
                        : Color.clear
                )
                .cornerRadius(8)
                .onTapGesture {
                    vm.selectedIdx = vm.notes.firstIndex(of: item) ?? 0
                    if vm.isVerticalLayout {
                        isShowEdit = true
                    }
                }
                // CÁCH 1: Dùng swipeActions (iOS 15+)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // Delete button (màu đỏ)
                    Button(role: .destructive) {
                        Task {
                            await vm.remove(dt: item.dateTime)
                        }
                    } label: {
                        Label("Xóa", systemImage: "trash")
                    }

                    // Edit button (màu xanh)
                    Button {
                        isShowEdit = true
                        print("Edit: \(item.title)")
                    } label: {
                        Label("Sửa", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                // Swipe từ bên trái (optional)
                .swipeActions(edge: .leading) {
                    Button {
                        print("Pin: \(item.title)")
                    } label: {
                        Label("Pin", systemImage: "pin.fill")
                    }
                    .tint(.orange)
                }
            }
            // CÁCH 2: Giữ lại onDelete nếu muốn dùng Edit button của List
            // .onDelete { idxs in
            //     Task {
            //         for idx in idxs {
            //             await vm.remove(dt: vm.notes[idx].dateTime)
            //         }
            //     }
            // }
        }
        .refreshable {
            // Haptic feedback khi bắt đầu refresh
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            // Pull to refresh
            await vm.loadNotes()

            // Haptic feedback khi hoàn thành
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
        .navigationDestination(isPresented: $isShowEdit) {
            DetailScreen(isSingleScreen: true)
                .environmentObject(vm)
        }

    }
}
