//
//  CryptoModel.swift
//  Cody’s Cryptocurrencies
//
//  Created by Ezana Lemma on 5/10/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit

class CryptoModel: NSObject, NSCoding {
    var id:[String] = []
    var hold:[Double] = []
    
    init(id:[String], hold:[Double]) {
        self.id = id
        self.hold = hold
    }
    
    internal required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! [String]
        self.hold = aDecoder.decodeObject(forKey: "hold") as! [Double]
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(self.id, forKey: "id")
        encoder.encode(self.hold, forKey: "hold")
    }
}
