//
//  Api.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import Foundation
import Combine

class ApiEnv: ObservableObject{
    // Provide the required publisher for ObservableObject
    let objectWillChange = ObservableObjectPublisher()

    var api : Api {
        didSet {
            // notify observers when the api reference changes
            objectWillChange.send()
        }
    }
    init(api: Api) {
        self.api = api
    }
}

protocol Api {
    func login(username: String, password: String) async throws -> Bool
    func loadNotes() async throws -> [NoteItem]
    func addNote(title: String, content: String) async throws
    func editNote(dt: Int64, title: String, content: String) async throws
    func deleteNote(dt: Int64) async throws
}