//
//  DetailsViewController.swift
//  Cody’s Cryptocurrencies
//
//  Created by Ezana Lemma on 5/10/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit

class DetailsViewController: UITableViewController, UITextFieldDelegate {
    
    var data:[String] = []
    var textField = UITextField()
    let settings = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Details", comment: "")
        textField.delegate = self
        textField = UITextField(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width - 16.0, height: 21.0))
        textField.backgroundColor = UIColor.white
        textField.borderStyle = .roundedRect
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Return", comment: ""), style: .plain, target: self, action: #selector(dismissKeyboard))
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(didPressAdd))
        toolbar.setItems([flexibleSpace, cancelButton, doneButton], animated: false)
        
        /*let doneButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(self.didPressAdd))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)*/
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissTapGesture)
        
        textField.inputAccessoryView = toolbar
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: max(self.view.bounds.width, self.view.bounds.height), height: max(self.view.bounds.width, self.view.bounds.height))
        let color1 = UIColor(red: 255/255, green: 228/255, blue: 122/255, alpha: 1.0).cgColor
        let color2 = UIColor(red: 61/255, green: 126/255, blue: 170/255, alpha: 1.0).cgColor
        gradientLayer.colors = [color1, color2]
        view.layer.insertSublayer(gradientLayer, at:0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func didPressAdd() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        if let dText = formatter.number(from: textField.text!) as? Double {
            if Crypto.shared.coins.count >= 1 && Crypto.shared.coins[0].id.contains(data.last!) {
                let pos = Crypto.shared.coins[0].id.index(of: data.last!)
                let old = Crypto.shared.coins[0].hold[pos!]
                let new = old + dText
                Crypto.shared.coins[0].hold[pos!] = new
                Crypto.shared.save()
            } else if Crypto.shared.coins.count >= 1 {
                Crypto.shared.coins[0].id.append(data.last!)
                Crypto.shared.coins[0].hold.append(dText)
                Crypto.shared.save()
            } else {
                Crypto.shared.addCoin(id: data.last!, hold: dText)
            }
        } else {
            let simpleAlert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Text is empty or invalid.", comment: ""), preferredStyle: .alert)
            simpleAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(simpleAlert, animated: true, completion: nil)
        }
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count-1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 54.0
        } else if indexPath.row == 1 {
            return 59.0
        } else {
            return 44.0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("Name: ", comment: "") + data[indexPath.row]
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 27.0)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        } else if indexPath.row == 1 {
            let lab = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width - 16.0, height: 21.0))
            lab.text = NSLocalizedString("Enter coins you hold:", comment: "")
            cell.addSubview(lab)
            lab.translatesAutoresizingMaskIntoConstraints = false
            lab.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16.0).isActive = true
            lab.topAnchor.constraint(equalTo: cell.topAnchor, constant: 4.0).isActive = true
            lab.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -16.0).isActive = true
            textField.keyboardType = .decimalPad
            cell.addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16.0).isActive = true
            textField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30.0).isActive = true
            textField.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -16.0).isActive = true
        } else if indexPath.row == 2 {
            cell.textLabel?.text = NSLocalizedString("Symbol: ", comment: "") + data[indexPath.row]
        } else if indexPath.row == 3 {
            cell.textLabel?.text = NSLocalizedString("Price: ", comment: "") + data[indexPath.row]
        } else if indexPath.row == 4 {
            if !data[indexPath.row].contains("-") {
                cell.textLabel?.textColor = UIColor.green
                cell.textLabel?.text = NSLocalizedString("24h chg: ↑ ", comment: "") + data[indexPath.row] + "%"
            } else {
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.text = NSLocalizedString("24h chg: ↓ ", comment: "") + data[indexPath.row] + "%"
            }
        } else if indexPath.row == 5 {
            if !data[indexPath.row].contains("-") {
                cell.textLabel?.textColor = UIColor.green
                cell.textLabel?.text = NSLocalizedString("1h chg: ↑ ", comment: "") + data[indexPath.row] + "%"
            } else {
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.text = NSLocalizedString("1h chg: ↓ ", comment: "") + data[indexPath.row] + "%"
            }
        } else if indexPath.row == 6 {
            cell.textLabel?.text = NSLocalizedString("Total Supply: ", comment: "") + data[indexPath.row]
        } else if indexPath.row == 7 {
            cell.textLabel?.text = NSLocalizedString("Market Cap: ", comment: "") + data[indexPath.row]
        }
        return cell
    }
    

}
