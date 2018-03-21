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
    @IBOutlet weak var statusBar: UILabel!
    
    var refGames : DatabaseReference!
    var roomNumber : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerOneUid : String = (Auth.auth().currentUser?.uid)!
        
        SVProgressHUD.show()
        refGames = Database.database().reference()
        refGames.child("games/xoxo").observeSingleEvent(of: .value) { (snapshot1) in
            
            let value1 = snapshot1.value as! NSArray
            let count : Int = value1.count
            
            self.roomNumber = Int(count * 10000) + Int(arc4random_uniform(10000))
            self.roomNumberLabel.text = String(self.roomNumber)
            self.statusBar.text = "Waiting for Player Two to join..."
            SVProgressHUD.dismiss()
            
            //TODO: - add animation for waiting to player two
            
            var newGame : [String : String] = [String : String]()
            newGame["playerOneUid"] = playerOneUid
            newGame["playerTwoUid"] = "nil"
            newGame["gameStatus"] = "Room opened"
            newGame["roomNumber"] = String(self.roomNumber)
            newGame["moves"] = ""
            
            value1.adding(newGame)
            
            self.refGames.child("games/xoxo/\(count)").updateChildValues(newGame)
            
            self.refGames.child("games/xoxo/\(count)").observe(DataEventType.value, with: { (snapshot2) in
                let value2 = snapshot2.value as! NSDictionary
                let status : String = value2["gameStatus"] as! String
                let playerTwoUid : String = value2["playerTwoUid"] as! String
                                
                let cond : Bool = (playerTwoUid != "nil") && (status != "Game canceled by 1") && (status != "Game canceled by 2")
                
                if cond {
                    if playerOneUid != playerTwoUid {
                        self.notifyPlayerTwoJoined(roomNumber: self.roomNumber)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameVC = segue.destination as! GameRoomViewController
            gameVC.roomNumber = roomNumber
        }
    }
    
    func notifyPlayerTwoJoined(roomNumber: Int) {
        performSegue(withIdentifier: "goToGame", sender: self)

    }
}
