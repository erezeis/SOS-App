//
//  StartNewViewController.swift
//  SOS App
//
//  Created by Oz Arie Tal Shachar on 14/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class StartNewViewController: UIViewController {
    
    @IBOutlet weak var roomNumberLabel: UILabel!
    
    var refGames : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerOneUid : String = (Auth.auth().currentUser?.uid)!
        
        SVProgressHUD.show()
        refGames = Database.database().reference()
        refGames.child("games/sos").observeSingleEvent(of: .value) { (snapshot1) in
            
            let value1 = snapshot1.value as! NSArray
            let count : Int = value1.count
            
            let roomNumber : Int = Int(count * 10000) + Int(arc4random_uniform(10000))
            self.roomNumberLabel.text = String(roomNumber)
            SVProgressHUD.dismiss()
            
            //TODO: - add animation for waiting to player two
            
            var newGame : [String : String] = [String : String]()
            newGame["playerOneUid"] = playerOneUid
            newGame["playerTwoUid"] = "nil"
            newGame["roomNumber"] = String(roomNumber)
            
            value1.adding(newGame)
            
            self.refGames.child("games/sos/\(count)").updateChildValues(newGame)
            
            self.refGames.child("games/sos/\(count)").observe(DataEventType.value, with: { (snapshot2) in
                let value2 = snapshot2.value as! NSDictionary
                let playerTwoUid : String = value2["playerTwoUid"] as! String
                
                if playerTwoUid != "nil" {
                    if playerOneUid != playerTwoUid {
                        self.notifyPlayerTwoJoined()
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        //show alert "are you sure"
        //TODO: - connect to firebase and close room number
        
        SVProgressHUD.dismiss()
        navigationController?.popViewController(animated: true)
        
    }
    
    
    func notifyPlayerTwoJoined() {
        //TODO notify room number
        performSegue(withIdentifier: "goToGame", sender: self)
    }
}




