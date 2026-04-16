//
//  AppLogImpl.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//
import Foundation

class AppLogImpl: AppLog {
    func i(_ tag: String, _msg: String) {
        NSLog("[INFO]/\(tag): \(_msg)")
    }
    
    func d(_ tag: String, _msg: String) {
        NSLog("[DEBUG]/\(tag): \(_msg)")
    }
    
    func e(_ tag: String, _msg: String) {
        NSLog("[ERROR]/\(tag): \(_msg)")
    }
    
}
