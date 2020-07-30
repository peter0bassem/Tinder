//
//  Bindable.swift
//  Tinder
//
//  Created by Peter Bassem on 7/30/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
}
