//
//  MessageModel.swift
//  CocoaPodsDemo
//
//  Created by Leo Ho on 2021/8/22.
//

import Foundation

struct MessageModel: Comparable {
    static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.time < rhs.time
    }
    
    var id: String
    var name: String
    var content: String
    var time: String
}
