//
//  SearchTableViewController.swift
//  Cody’s Cryptocurrencies
//
//  Created by Ezana Lemma on 5/10/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var allCurr:[String] = []
    var allCurrResults:[String] = []
    var isSearch:Bool = false
    var mySearchBar:UISearchBar = UISearchBar()
    let settings = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saved = self.settings.value(forKey: "order") as! [String]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                let source = try String(contentsOf: URL(string: "https://api.coinmarketcap.com/v1/ticker/")!)
                let newline = source.components(separatedBy: .newlines)
                for i in newline {
                    if i.contains("\"id\":") {
                        let p1 = i.components(separatedBy: "\",")
                        let p2 = p1[0].components(separatedBy: "\"")
                        let id = p2[3]
                        if !saved.contains(id) {
                            self.allCurr.append(id)
                        }
                    }
                }
                self.tableView.reloadData()
                
            } catch {
                print(error)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func documents() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch && mySearchBar.text!.characters.count > 0 {
            return allCurrResults.count
        } else {
            return allCurr.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isSearch && mySearchBar.text!.characters.count > 0 {
            cell.textLabel?.text = allCurrResults[indexPath.row]
        } else {
            cell.textLabel?.text = allCurr[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        mySearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        mySearchBar.delegate = self
        mySearchBar.placeholder = NSLocalizedString("Search", comment: "")
        return mySearchBar
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        isSearch = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        isSearch = false
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        allCurrResults.removeAll()
        allCurrResults = allCurr.filter() {
            $0.range(of: mySearchBar.text!, options: .caseInsensitive) !=  nil
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearch && mySearchBar.text!.characters.count > 0 {
            var allCurr = settings.value(forKey: "order") as! [String]
            allCurr.insert(self.allCurrResults[indexPath.row], at: 0)
            settings.set(allCurr, forKey: "order")
            settings.synchronize()
        } else {
            var allCurr = settings.value(forKey: "order") as! [String]
            allCurr.insert(self.allCurr[indexPath.row], at: 0)
            settings.set(allCurr, forKey: "order")
            settings.synchronize()
        }
        let alert = UIAlertController(title: NSLocalizedString("Cody’s Cryptocurrencies", comment: ""), message: NSLocalizedString("Cryptocurrency successfully added.", comment: "") + "\n" + NSLocalizedString("Go back and refresh the list.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go back", comment: ""), style: .cancel, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add another", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
