//
//  CollectionManager.swift
//  jChat
//
//  Created by Jeevan on 06/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import Foundation
import Firebase

class CollectionManager {
    private init() {
        
    }
    static let shared = CollectionManager()
    let db = Firestore.firestore()
}
