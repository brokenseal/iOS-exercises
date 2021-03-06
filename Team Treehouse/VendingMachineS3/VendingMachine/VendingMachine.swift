//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Pasan Premaratne on 1/23/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import UIKit

// Protocols

protocol VendingMachineType {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: ItemType] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: ItemType])
    func vend(_ selection: VendingSelection, quantity: Double) throws
    func deposit(_ amount: Double)
    func itemForCurrentSelection(_ selection: VendingSelection) -> ItemType?
}

protocol ItemType {
    var price: Double { get }
    var quantity: Double { get set }
}

// Error Types

enum InventoryError: Error {
    case invalidResource
    case conversionError
    case invalidKey
}

enum VendingMachineError: Error {
    case invalidSelection
    case outOfStock
    case stockInsufficient
    case insufficientFunds(required: Double)
}

// Helper Classes

class PlistConverter {
    class func dictionaryFromFile(_ resource: String, ofType type: String) throws -> [String : AnyObject] {
        
        guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path),
        let castDictionary = dictionary as? [String: AnyObject] else {
            throw InventoryError.conversionError
        }
        
        return castDictionary
    }
}

class InventoryUnarchiver {
    class func vendingInventoryFromDictionary(_ dictionary: [String : AnyObject]) throws -> [VendingSelection : ItemType] {
        
        var inventory: [VendingSelection : ItemType] = [:]
        
        for (key, value) in dictionary {
            if let itemDict = value as? [String : Double],
            let price = itemDict["price"], let quantity = itemDict["quantity"] {
                
                let item = VendingItem(price: price, quantity: quantity)
                
                guard let key = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidKey
                }
                
                inventory.updateValue(item, forKey: key)
                
            }
        }
        
        return inventory
        
    }
}


// Concrete Types

enum VendingSelection: String {
    case Soda
    case DietSoda
    case Chips
    case Cookie
    case Sandwich
    case Wrap
    case CandyBar
    case PopTart
    case Water
    case FruitJuice
    case SportsDrink
    case Gum
    
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return UIImage(named: "Default")!
        }
    }
}

struct VendingItem: ItemType {
    let price: Double
    var quantity: Double
}

class VendingMachine: VendingMachineType {
    
    let selection: [VendingSelection] = [.Soda, .DietSoda, .Chips, .Cookie, .Sandwich, .Wrap, .CandyBar, .PopTart, .Water, .FruitJuice, .SportsDrink, .Gum]
    var inventory: [VendingSelection: ItemType]
    var amountDeposited: Double = 1000.0
    
    required init(inventory: [VendingSelection : ItemType]) {
        self.inventory = inventory
    }
    
    func vend(_ selection: VendingSelection, quantity: Double) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity > 0 else {
            throw VendingMachineError.outOfStock
        }
        
        guard item.quantity - quantity >= 0 else {
            throw VendingMachineError.stockInsufficient
        }
        
        item.quantity -= quantity
        inventory.updateValue(item, forKey: selection)
        
        let totalPrice = item.price * quantity
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
        } else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFunds(required: amountRequired)
        }
    }
    
    func itemForCurrentSelection(_ selection: VendingSelection) -> ItemType? {
        return inventory[selection]
    }
    
    func deposit(_ amount: Double) {
        // add code
    }
}


















