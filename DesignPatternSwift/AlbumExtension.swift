//
//  AlbumExtension.swift
//  BlueLibrarySwift
//
//  Created by Omar Faruqe on 2016-03-27.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}