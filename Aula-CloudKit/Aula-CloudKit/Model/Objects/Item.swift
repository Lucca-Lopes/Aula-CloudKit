//
//  Item.swift
//  Aula-CloudKit
//
//  Created by Lucca Lopes on 06/10/23.
//

import Foundation
import CloudKit

struct Item: CKRecordValueProtocol {
    var text: String
    let id: UUID
    
    init(text: String) {
        self.text = text
        self.id = UUID()
    }
    
    init() {
        self.text = ""
        self.id = UUID()
    }
}
