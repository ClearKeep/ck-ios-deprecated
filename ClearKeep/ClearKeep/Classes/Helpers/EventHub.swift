//
//  EventHub.swift
//  ClearKeep
//
//  Created by Seoul on 11/25/20.
//

import Foundation
public protocol EventType {}

public enum EHThread {
    case main
    case background(queue: DispatchQueue?)

    fileprivate var queue: DispatchQueue {
        switch self {
        case .main:
            return .main
        case .background(let queue):
            return queue ?? .global()
        }
    }
}

private struct Observation {
    weak var observer: AnyObject?
    let thread: EHThread?
    let block: Any
}

public struct EventHub {
    private static var observations = [Observation]()
    private static let lock: AnyObject = UUID().uuidString as AnyObject

    public static func addObserver<T: EventType>(_ observer: AnyObject, thread: EHThread? = nil, block: @escaping (T) -> Void) {
        sync {
            observations.append(Observation(observer: observer, thread: thread, block: block))
        }
    }

    public static func removeObserver(_ observer: AnyObject) {
        sync {
            observations = observations.filter { $0.observer != nil && $0.observer! !== observer }
        }
    }

    public static func post<T: EventType>(_ event: T) {
        sync {
            observations = observations.filter { $0.observer != nil } // Remove nil observers
            observations.forEach {
                if let block = $0.block as? (T) -> Void {
                    if let queue = $0.thread?.queue {
                        queue.async {
                            block(event)
                        }
                    } else {
                        block(event)
                    }
                }
            }
        }
    }

    private static func sync(block: () -> Void) {
        objc_sync_enter(lock)
        block()
        objc_sync_exit(lock)
    }
}
