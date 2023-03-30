//
//  Filemanager-DocumentsDirectory.swift
//  HotProspects
//
//  Created by artembolotov on 30.03.2023.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
