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
    var roomNumber : Int = -1
    
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
        roomNumber = roomTextFieldInt
        
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
            
            //Get Dictionary from FireBase
            guard let value : NSDictionary = snapshot.value as? NSDictionary else {
                self.displayError(title: "Error", msg: "Room \(roomTextFieldInt) not found")
                return
            }
            
            //Get room number from DB
            let roomNumberDB : String = value["roomNumber"] as! String
            
            //Check if room number from DB is not same as room number typed by user
            if roomTextFieldText != roomNumberDB {
                self.displayError(title: "Error", msg: "Room \(roomTextFieldInt) not found")
                return
            }
            
            //Get player 1's uid
            let playerOneUid : String = value["playerOneUid"] as! String
            let uid : String = (Auth.auth().currentUser?.uid)!
            
            //Check if player 1's uid is the same as current user's uid
            if playerOneUid==uid {
                self.displayError(title: "Error", msg: "Cannot join room \(roomTextFieldInt)")
                return
            }
            
            let playerTwoUid : String = value["playerTwoUid"] as! String
            
            //Check if room is taken
            if playerTwoUid != "nil" {
                self.displayError(title: "Error", msg: "Room \(roomTextFieldInt) is already taken")
                return
            }
            
            //You may now join the game!!
            self.onMatch(index: i, uid: uid)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameVC = segue.destination as! GameRoomViewController
            gameVC.roomNumber = roomNumber
        }
    }
    
    func onMatch(index: Int, uid: String){
        SVProgressHUD.dismiss()
        refGames = Database.database().reference()
        refGames.child("games/sos/\(index)/playerTwoUid").setValue(uid)
        refGames.child("games/sos/\(index)/playerTwoDisplayName").setValue(Auth.auth().currentUser?.email)
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
