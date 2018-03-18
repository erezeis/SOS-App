//
//  JoinExistingViewController.swift
//  SOS App
//
//  Created by Oz Arie Tal Shachar on 14/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class JoinExistingViewController: UIViewController {
    
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    var refGames : DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        joinButton.isEnabled = false
        
        let roomTextFieldText : String = roomTextField.text!
        if roomTextFieldText.count == 0 {
            displayError(title: "Error", msg: "Please enter room number")
            return
        }
        
        guard let roomTextFieldInt : Int = Int(roomTextFieldText) else {
            displayError(title: "Error", msg: "Invalid room number: \(roomTextFieldText)")
            return
        }
        
        if roomTextFieldInt<=0{
            displayError(title: "Error", msg: "Invalid room number: \(roomTextFieldInt)")
            return
        }
        
        let i : Int = roomTextFieldInt/10000
        if i<=0{
            displayError(title: "Error", msg: "Inavlid room number: \(roomTextFieldInt)")
            return
        }
        
        refGames = Database.database().reference()
        SVProgressHUD.show()
        refGames.child("games/sos/\(i)").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value : NSDictionary = snapshot.value as? NSDictionary else {
                self.displayError(title: "Error", msg: "Room \(roomTextFieldInt) not found")
                return
            }
           
            let roomNumberDB : String = value["roomNumber"] as! String
            
            if roomTextFieldText==roomNumberDB {
                
                let playerTwoUid : String = value["playerTwoUid"] as! String
                
                print("playerTwoUid=\(playerTwoUid)")
                return
                
                //self.onMatch(index: i)
            } else {
                self.displayError(title: "Error", msg: "Room \(roomTextFieldInt) not found")
            }
        }
    }
    
    func onMatch(index: Int){
        SVProgressHUD.dismiss()
        refGames = Database.database().reference()
        refGames.child("games/sos/\(index)/playerTwoUid").setValue(Auth.auth().currentUser?.uid)
        performSegue(withIdentifier: "goToGame", sender: self)
    }
    
    func displayError(title : String, msg : String) {
        SVProgressHUD.dismiss()
        joinButton.isEnabled = true
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
