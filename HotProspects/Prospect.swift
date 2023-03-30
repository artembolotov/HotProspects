//
//  Prospect.swift
//  HotProspects
//
//  Created by artembolotov on 26.03.2023.
//

import SwiftUI

final class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var added = Date()
    fileprivate(set) var isContacted = false
}

enum SortType {
    case name, date
}

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    @Published private(set) var sortType = SortType.name {
        didSet {
            people = people.sorted(by: sortType)
        }
    }
    
    private static let savePath = FileManager.documentsDirectory.appendingPathComponent("prospects", conformingTo: .json)
    
    init() {
        people = Prospects.loadStored().sorted(by: .name)
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func setSortType(_ newSortType: SortType) {
        sortType = newSortType
    }
    
    private func save() {
        do {
            let encoded = try JSONEncoder().encode(people)
            try encoded.write(to: Prospects.savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data. \(error.localizedDescription)")
        }
    }
    
    func toogle(prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    private static func loadStored() -> [Prospect] {
        do {
            let data = try Data(contentsOf: Prospects.savePath)
            return try JSONDecoder().decode([Prospect].self, from: data)
        } catch {
            return []
        }
    }
    
    private static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension Array where Element: Prospect {
    func sorted(by sortType: SortType) -> [Prospect] {
        switch sortType {
        case .name:
            return self.sorted { $0.name < $1.name }
        case .date:
            return self.sorted { $0.added > $1.added }
        }
    }
}
