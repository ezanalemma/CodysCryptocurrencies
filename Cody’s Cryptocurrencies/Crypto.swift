//
//  Crypto.swift
//  Cody’s Cryptocurrencies
//
//  Created by Ezana Lemma on 5/10/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit

class Crypto: NSObject {
    static let shared = Crypto()
    var coins = [CryptoModel]()
    var filePath : String!
    func load() {
        filePath = documents() + "/coins.plist"
        if FileManager.default.fileExists(atPath: filePath) {
            coins = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [CryptoModel]
        }
    }
    func addCoin(id:String, hold:Double) {
        var arr1:[String] = []
        var arr2:[Double] = []
        arr1.append(id)
        arr2.append(hold)
        let newCoin = CryptoModel(id: arr1, hold: arr2)
        coins = [newCoin]
        save()
    }
    func documents() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    func save() {
        NSKeyedArchiver.archiveRootObject(coins, toFile: filePath)
    }
}
