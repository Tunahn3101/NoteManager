//
//  HomeViewModel.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {

    var api: Api?

    @Published var loadStatus = LoadStatus.initial
    @Published var notes = [NoteItem]()
    @Published var selectedIdx = 0
    @Published var isVerticalLayout = false
    
    // Flag để track đã load lần đầu chưa
    private var hasLoadedInitialData = false

    init() {
        print("init HomeVM")
    }

    deinit {
        print("deinit HomeVM")
    }
    
    // Load chỉ khi chưa load lần đầu
    func loadNotesIfNeeded() async {
        guard !hasLoadedInitialData else {
            print("Already loaded, skipping...")
            return
        }
        await loadNotes()
        hasLoadedInitialData = true
    }

    func loadNotes() async {
        do {
            loadStatus = .loading
            
            // Đánh dấu thời điểm bắt đầu
            let startTime = Date()
            
            if let api = api {
                notes = try await api.loadNotes()
            }
            
            // Đảm bảo loading ít nhất 0.5s để user thấy rõ
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 0.5 {
                try? await Task.sleep(nanoseconds: UInt64((0.5 - elapsed) * 1_000_000_000))
            }
            
            loadStatus = .done
        } catch let e as AppError {
            if case .apiError(let msg) = e {
                loadStatus = .error(msg: msg)
            }
        } catch {
            loadStatus = .error(msg: "Other error")
        }

    }

    func remove(dt: Int64) async {
        loadStatus = .loading
        do {
            try await api?.deleteNote(dt: dt)
            await loadNotes()
            loadStatus = .done
        } catch let e as AppError {
            if case .apiError(let msg) = e {
                loadStatus = .error(msg: msg)
            }
        } catch {
            loadStatus = .error(msg: "Other error")
        }

    }

    func addNote(title: String, content: String) async {
        loadStatus = .loading
        do {
            try await api?.addNote(title: title, content: content)
            await loadNotes()
        } catch let e as AppError {
            if case .apiError(let msg) = e {
                loadStatus = .error(msg: msg)
            }
        } catch {
            loadStatus = .error(msg: "Other error")
        }
    }

    func editNote(dt: Int64, title: String, content: String) async {
        loadStatus = .loading
        do {
            try await api?.editNote(dt: dt, title: title, content: content)
            await loadNotes()
        } catch let e as AppError {
            if case .apiError(let msg) = e {
                loadStatus = .error(msg: msg)
            }
        } catch {
            loadStatus = .error(msg: "Other error")
        }
    }
    
    // Convenience method: Edit note đang được chọn
    func editSelectedNote(title: String, content: String) async {
        guard notes.indices.contains(selectedIdx) else {
            loadStatus = .error(msg: "No note selected")
            return
        }
        await editNote(dt: notes[selectedIdx].dateTime, title: title, content: content)
    }
    
    // Convenience method: Edit bằng NoteItem
    func editNote(_ note: NoteItem, title: String, content: String) async {
        await editNote(dt: note.dateTime, title: title, content: content)
    }
}
