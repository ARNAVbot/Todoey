//
//  Item.swift
//  Todoey
//
//  Created by Arnav Agarwal on 13/04/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

class Item : Codable // or use Encodable, Decodable
{
    var title: String = ""
    var done: Bool = false
}
