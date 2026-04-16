//
//  ApiImpl.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import Foundation

class ApiImpl : Api {
    
    var notes = [NoteItem]()
    
    init(){
        notes.append(NoteItem(dateTime: 1, title: "Note 1", content: "Content of Note 1"))
        notes.append(NoteItem(dateTime: 2, title: "Note 2", content: "Content of Note 2"))
        notes.append(NoteItem(dateTime: 3, title: "Note 3", content: "Content of Note 3"))
    }
    
    func login(username: String, password: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if username != "1" || password != "1" {
            throw AppError.apiError(msg: "Login failed")
        }
        return true
    }
    
    func loadNotes() async throws -> [NoteItem] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return notes
    }
    
    func addNote(title: String, content: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        notes.append(NoteItem(dateTime: Int64(Date().timeIntervalSince1970), title: title, content: content))
    }
    
    func editNote(dt: Int64, title: String, content: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw AppError.apiError(msg: "Edit note failed")
    }
    
    func deleteNote(dt: Int64) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        notes.removeAll{
            ($0.dateTime == dt)
        }
    }
    
    
}
