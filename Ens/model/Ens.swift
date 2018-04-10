//
//  ens.swift
//  Ens
//
//  Created by liu-george-p on 3/26/18.
//  Copyright © 2018 tehillim. All rights reserved.
//

import Foundation

class Ens {
    let id: Int
    let title: String
    let description: String
    let url: String
    let active: String
    let createdAt: String
    let updatedAt: String
    
    init(id: Int, title: String, description: String, url: String, active: String, createdAt: String, updatedAt: String) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.active = active
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
