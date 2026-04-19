//
//  LoadStatus.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

enum LoadStatus : Equatable {
    case initial, loading, error(msg: String), done
}
