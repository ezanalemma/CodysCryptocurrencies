//
//  CoinsViewController.swift
//  Cody’s Cryptocurrencies
//
//  Created by Ezana Lemma on 5/10/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit

class CoinsViewController: UITableViewController {
    
    var data:[String] = ["bitcoin", "ethereum", "ripple", "litecoin", "dash", "monero","ethereum-classic", "NEM", "Augur", "maidsafecoin", "zcash", "pivx", "tether", "decred", "golem-network-tokens", "bitconnect", "waves", "dogecoin","factom","stratis"]
    var names:[String] = []
    var prices:[String] = []
    var symbols:[String] = []
    var chg1:[String] = []
    var chg24:[String] = []
    var totalSupp:[String] = []
    var marketCap:[String] = []
    var ids:[String] = []
    let settings = UserDefaults.standard
    let ptr = UIRefreshControl()
    var locIsEur:Bool = false
    
    @IBOutlet var labTotalCoin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Locale.current.currencySymbol!.contains("€") {
            locIsEur = true
            labTotalCoin.text = " Total de monedas que tiene es: 0,0€"
        } else {
            labTotalCoin.text = " Total Coins you have: 0.0$"
            locIsEur = false
        }
        self.downloadJSON()
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        ptr.addTarget(self, action: #selector(downloadJSON), for: .valueChanged)
        ptr.attributedTitle = NSAttributedString(string: NSLocalizedString("Refreshing...", comment: ""),
                                                 attributes: [NSFontAttributeName : UIFont(name: "Gill Sans", size: 12.0)!])
        tableView.addSubview(ptr)
    }
    
    func downloadJSON() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.names = []
            self.prices = []
            self.symbols = []
            self.chg1 = []
            self.chg24 = []
            self.totalSupp = []
            self.marketCap = []
            self.ids = []
            if self.settings.value(forKey: "order") != nil {
                self.data = self.settings.value(forKey: "order") as! [String]
            } else {
                self.settings.set(self.data, forKey: "order")
                self.settings.synchronize()
            }
            do {
                for i in 0..<self.data.count {
                    let json = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(string: "https://api.coinmarketcap.com/v1/ticker/\(self.data[i])/?convert=EUR")!), options: []) as! [Any]
                    if let firstObject = json.first as? [String:Any] {
                        if let names = firstObject["name"] as? String {
                            self.names.append(names)
                        } else {
                            self.names.append("?")
                        }
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.minimumFractionDigits = 2
                        if self.locIsEur {
                            if let amount = Double(firstObject["price_eur"] as! String) {
                                let formattedString = formatter.string(for: amount)
                                if let prices = formattedString {
                                    self.prices.append("€" + prices)
                                } else {
                                    self.prices.append("€ ?")
                                }
                            } else {
                                self.prices.append("€ ?")
                            }
                        } else {
                            if let amount = Double(firstObject["price_usd"] as! String) {
                                let formattedString = formatter.string(for: amount)
                                if let prices = formattedString {
                                    self.prices.append("$" + prices)
                                } else {
                                    self.prices.append("$ ?")
                                }
                            } else {
                                self.prices.append("$ ?")
                            }
                        }
                        if let symbols = firstObject["symbol"] as? String {
                            self.symbols.append(symbols)
                        } else {
                            self.symbols.append("?")
                        }
                        if let chg1 = firstObject["percent_change_1h"] as? String {
                            self.chg1.append(chg1)
                        } else {
                            self.chg1.append("?")
                        }
                        if let chg24 = firstObject["percent_change_24h"] as? String {
                            self.chg24.append(chg24)
                        } else {
                            self.chg24.append("?")
                        }
                        if let totalSupp = firstObject["total_supply"] as? String {
                            self.totalSupp.append(totalSupp)
                        } else {
                            self.totalSupp.append("?")
                        }
                        if self.locIsEur {
                            if let marketCap = firstObject["market_cap_eur"] as? String {
                                self.marketCap.append(marketCap)
                            } else {
                                self.marketCap.append("?")
                            }
                        } else {
                            if let marketCap = firstObject["market_cap_usd"] as? String {
                                self.marketCap.append(marketCap)
                            } else {
                                self.marketCap.append("?")
                            }
                        }
                        if let id = firstObject["id"] as? String {
                            self.ids.append(id)
                        } else {
                            self.ids.append("?")
                        }
                    }
                }
                self.refreshDataStored()
                self.ptr.endRefreshing()
                self.tableView.reloadData()
            } catch {
                print(error)
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Try again later.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.ptr.endRefreshing()
            }
        }
    }
    
    func refreshDataStored() {
        var tot = 0.0
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        if Crypto.shared.coins.count >= 1 {
            for i in 0..<Crypto.shared.coins[0].id.count {
                let h = Crypto.shared.coins[0].hold[i]
                let id = Crypto.shared.coins[0].id[i]
                let pricepos = self.ids.index(of: id)
                let price = self.locIsEur ? self.prices[pricepos!].components(separatedBy: "€") : self.prices[pricepos!].components(separatedBy: "$")
                let dPrice = Double(formatter.number(from: price[1])!)*h
                tot += dPrice
            }
        }
        self.labTotalCoin.text = self.locIsEur ? NSLocalizedString(" Total de monedas que tiene es: ", comment: "") + "\(tot)" + "€" : NSLocalizedString(" Total Coins you have: ", comment: "") + "\(tot)" + "$"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return names.count-1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoinCell
            cell.cname.text = names[indexPath.row]
            
            
            
            cell.symbol.text = symbols[indexPath.row]
            cell.cprice.text = prices[indexPath.row]
            
            if !chg1[indexPath.row].contains("-") {
                cell.cchange.textColor = UIColor.green
                cell.cchange.text = "1h chg: ↑ " + "\(chg1[indexPath.row])" + "%"
            } else {
                cell.cchange.textColor = UIColor.red
                cell.cchange.text = "1h chg: ↓ " + "\(chg1[indexPath.row])" + "%"
            }
            if Crypto.shared.coins.count >= 1 && Crypto.shared.coins[0].id.contains(ids[indexPath.row]) {
                let pos = Crypto.shared.coins[0].id.index(of: ids[indexPath.row])
                let h = Crypto.shared.coins[0].hold[pos!]
                let formatter = NumberFormatter()
                formatter.locale = Locale.current
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                let price = self.locIsEur ? prices[indexPath.row].components(separatedBy: "€") : prices[indexPath.row].components(separatedBy: "$")
                let priceD = formatter.number(from: price[1]) as? Double
                if let value = priceD {
                    cell.totv.text = self.locIsEur ? "\(h*value)" + "€" : "\(h*value)" + "$"
                } else {
                    cell.totv.text = ""
                }
                cell.toth.text = "\(h)"
            } else {
                cell.totv.text = ""
                cell.toth.text = ""
            }
            return cell
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            print(ids[indexPath.row])
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "det") as! DetailsViewController
            vc.data = [names[indexPath.row], "", symbols[indexPath.row], prices[indexPath.row], chg24[indexPath.row], chg1[indexPath.row], totalSupp[indexPath.row], marketCap[indexPath.row], ids[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Override to edit table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        } else if indexPath.section == 1 {
            if editingStyle == .delete {
                // Delete the row
                if Crypto.shared.coins.count >= 1 && Crypto.shared.coins[0].id.contains(ids[indexPath.row]) {
                    let pos = Int(Crypto.shared.coins[0].id.index(of: ids[indexPath.row])!)
                    Crypto.shared.coins[0].id.remove(at: pos)
                    Crypto.shared.coins[0].hold.remove(at: pos)
                    Crypto.shared.save()
                }
                data.remove(at: indexPath.row)
                settings.set(data, forKey: "order")
                settings.synchronize()
                names.remove(at: indexPath.row)
                prices.remove(at: indexPath.row)
                symbols.remove(at: indexPath.row)
                chg1.remove(at: indexPath.row)
                ids.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
            }
        } else {
        }
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if fromIndexPath.section == 0 || to.section == 0 {
        } else {
            let itemData = data[fromIndexPath.row]
            data.remove(at: fromIndexPath.row)
            data.insert(itemData, at: to.row)
            settings.set(data, forKey: "order")
            settings.synchronize()
            let itemNames = names[fromIndexPath.row]
            names.remove(at: fromIndexPath.row)
            names.insert(itemNames, at: to.row)
            let itemprices = prices[fromIndexPath.row]
            prices.remove(at: fromIndexPath.row)
            prices.insert(itemprices, at: to.row)
            let itemsymbols = symbols[fromIndexPath.row]
            symbols.remove(at: fromIndexPath.row)
            symbols.insert(itemsymbols, at: to.row)
            let itemchg1 = chg1[fromIndexPath.row]
            chg1.remove(at: fromIndexPath.row)
            chg1.insert(itemchg1, at: to.row)
            let itemchg24 = chg24[fromIndexPath.row]
            chg24.remove(at: fromIndexPath.row)
            chg24.insert(itemchg24, at: to.row)
            let itemtotalSupp = totalSupp[fromIndexPath.row]
            totalSupp.remove(at: fromIndexPath.row)
            totalSupp.insert(itemtotalSupp, at: to.row)
            let itemmarketCap = marketCap[fromIndexPath.row]
            marketCap.remove(at: fromIndexPath.row)
            marketCap.insert(itemmarketCap, at: to.row)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    
}

