//
//  Queue.swift
//  Summon
//
//  Created by Owen Vnek on 3/20/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

struct Queue<T> {
    
    var list = [T]()
    
    mutating func enqueue(_ element: T) {
        list.append(element)
    }
    
    mutating func dequeue() -> T? {
         if !list.isEmpty {
           return list.removeFirst()
         } else {
           return nil
         }
    }
    
    func peek() -> T? {
         if !list.isEmpty {
              return list[0]
         } else {
           return nil
         }
    }
    
    var isEmpty: Bool {
         return list.isEmpty
    }
    
}
