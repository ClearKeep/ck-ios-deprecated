//
//  FileGroups.swift
//  ClearKeep
//
//  Created by Seoul on 11/27/20.
//

import Foundation

class FileGroups: GroupChats {
    
    private static let groupsKey = "groups"

    @Published private(set) var all = [GroupModel]() {
        didSet {
            saveData()
        }
    }

    var allPublished: Published<[GroupModel]> { _all }
    var allPublisher: Published<[GroupModel]>.Publisher { $all }


    func add(group: GroupModel) {
        if let index = all.firstIndex(where: { $0.groupID > group.groupID }) {
            all.insert(group, at: index)
        }
        else {
            all.append(group)
        }
    }
    
    func isExistGroup(groupId: String) -> Bool {
        return !all.filter{$0.id == groupId}.isEmpty
    }

    func update(group: GroupModel) {
        if let index = all.firstIndex(where: { $0.id == group.id }) {
            all[index] = group
        }
        else {
            print("Group not found")
        }
    }

    func remove(groupRemove: GroupModel) {
        for (index, group) in all.enumerated() {
            if group.id == groupRemove.id {
                all.remove(at: index)
            }
        }
    }

    private func saveData() {
        do {
            let encoded = try JSONEncoder().encode(all)
            UserDefaults.standard.set(encoded, forKey: Self.groupsKey)
        }
        catch let error {
            print("Could not encode: \(error.localizedDescription)")
        }
    }
}
