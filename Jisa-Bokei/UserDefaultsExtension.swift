//
//  UserDefaultsExtension.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2018/03/14.
//  Copyright © 2018年 Private. All rights reserved.
//

import Foundation
import UIKit

//-----------------------------------------------------------------------------------
// 通常インタフェース用に追加
//-----------------------------------------------------------------------------------
protocol KeyNamespaceable {
    func namespaced<T: RawRepresentable>(_ key: T) -> String
    func namespaced<T: RawRepresentable>(_ type: T, _ index: Int, _ item: String) -> String
}

extension KeyNamespaceable {
    func namespaced<T: RawRepresentable>(_ key: T) -> String {
        return "\(Self.self).\(key.rawValue)"
    }
    func namespaced<T: RawRepresentable>(_ type: T, _ index: Int, _ item: String) -> String {
        return "\(type)\(index)_\(item)"
    }
}

protocol BoolDefaultSettable: KeyNamespaceable {
    associatedtype BoolKey : RawRepresentable
}

extension BoolDefaultSettable where BoolKey.RawValue == String {
    
    func set(_ value: Bool, forKey key: BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func bool(forKey key: BoolKey) -> Bool {
        let key = namespaced(key)
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func bool(forKey key: BoolKey, defaultValue defVal: Bool) -> Bool {
        let key = namespaced(key)
        return (UserDefaults.standard.object(forKey: key) != nil) ? UserDefaults.standard.bool(forKey: key) : defVal
    }
}

protocol IntegerDefaultSettable: KeyNamespaceable {
    associatedtype IntKey : RawRepresentable
}

extension IntegerDefaultSettable where IntKey.RawValue == String {
    
    func set(_ value: Int, forKey key: IntKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func integer(forKey key: IntKey) -> Int {
        let key = namespaced(key)
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func integer(forKey key: IntKey, defaultValue defVal: Int) -> Int {
        let key = namespaced(key)
        return (UserDefaults.standard.object(forKey: key) != nil) ?  UserDefaults.standard.integer(forKey: key) : defVal
    }
}

protocol ObjectDefaultSettable: KeyNamespaceable {
    associatedtype ObjKey : RawRepresentable
}

extension ObjectDefaultSettable where ObjKey.RawValue == String {
    
    func set(_ value: Any, forKey key: ObjKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func object(forKey key: ObjKey) -> Any? {
        let key = namespaced(key)
        return UserDefaults.standard.object(forKey: key)
    }
}

extension UserDefaults : ObjectDefaultSettable {
    enum ObjKey : String {
        // Bool
        case DISPLAY_SPLASH
        // Integer
        case START_MODE
        case START_LAST
        case DISPLAY_TIMEDIFF
        case TIME_STYLE
    }
}

extension UserDefaults : BoolDefaultSettable {
    enum BoolKey : String {
        case DISPLAY_SPLASH
    }
}

extension UserDefaults : IntegerDefaultSettable {
    enum IntKey : String {
        case START_MODE
        case START_LAST
        case DISPLAY_TIMEDIFF
        case TIME_STYLE
    }
}
