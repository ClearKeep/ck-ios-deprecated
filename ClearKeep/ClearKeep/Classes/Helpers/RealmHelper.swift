//
//  RealmHelper.swift
//  ClearKeep
//
//  Created by Seoul on 11/27/20.
//

import RealmSwift

final class RealmHelper <T : RealmSwift.Object> {
    let realm: Realm
    
    init() {
        try! realm = Realm()
        defer {
            realm.invalidate()
        }
    }

    func newId() -> Int? {
        guard let key = T.primaryKey() else {
            //primaryKey
            return nil
        }
        
        let realm = try! Realm()
        return (realm.objects(T.self).max(ofProperty: key) as Int? ?? 0) + 1
    }
    
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func findFirst() -> T? {
        return findAll().first
    }
    
    func findFirst(key: AnyObject) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }

    func findLast() -> T? {
        return findAll().last
    }
    
    func add(object :T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func add(objects: [T]) {
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func update(d: T, block:(() -> Void)? = nil) -> Bool {
        do {
            try realm.write {
                block?()
                realm.add(d, update: .modified)
            }
            return true
        } catch let error {
            print(error.localizedDescription)
        }
        return false
    }
    
    func delete(d: T) {
        do {
            try realm.write {
                realm.delete(d)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func deleteAll() {
        let objs = realm.objects(T.self)
        do {
            try realm.write {
                realm.delete(objs)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
