//
//  NoteItem.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

struct NoteItem: Codable, Hashable {
    var dateTime: Int64
    var title: String
    var content: String
    
}
