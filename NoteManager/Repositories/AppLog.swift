//
//  AppLog.swift
//  NoteManager
//
//  Created by Tunahn on 15/4/26.
//

import Combine

class AppLogEnv : ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    var appLog : AppLog
    
    
    init(appLog: AppLog) {
        self.appLog = appLog
    }
    

    
}

protocol AppLog {
    func i(_ tag: String, _msg: String)
    func d(_ tag: String, _msg: String)
    func e(_ tag: String, _msg: String)
}
