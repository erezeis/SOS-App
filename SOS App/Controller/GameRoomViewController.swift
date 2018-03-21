//
//  GameViewController.swift
//  SOS App
//
//  Created by Oz Arie Tal Shachar on 14/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import UIKit
import Firebase

class GameRoomViewController: UIViewController {
    
    var buttons : [Int : UIButton] = [Int : UIButton]()
    
    var refGames : DatabaseReference!
    
    @IBOutlet weak var board: UIStackView!
    
    @IBOutlet weak var statusBarLabel: UILabel!
    
    @IBOutlet weak var playerOneNameLabel: UILabel!
    @IBOutlet weak var playOneTypeLabel: UILabel!
    @IBOutlet weak var playerTwoNameLabel: UILabel!
    @IBOutlet weak var playerTwoTypeLabel: UILabel!
    
    var playerNumber : Int = -1
    var isTurnToPlay : Bool = false
    
    let myUid : String = (Auth.auth().currentUser?.uid)!
    var roomNumber : Int = 11111 // DONT FORGET TO REMOVE THIS!!!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "X.O.X.O App #\(roomNumber)"
        isTurnToPlay = false
        
        refGames = Database.database().reference()
        setUpPlayers()
        
        let index : Int = roomNumber/10000
        self.refGames.child("games/xoxo/\(index)").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let moves : String = value["moves"] as! String
            self.updateMoves(moves: moves)
        })
    }
    
    func setUpPlayers() {
        playOneTypeLabel.text = "X"
        playerTwoTypeLabel.text = "O"
        
        let i : Int = roomNumber/10000
        
        refGames.child("games/xoxo/\(i)").observeSingleEvent(of: .value) { (snapshot1) in
            
            //Get Dictionary from FireBase
            let value1 : NSDictionary = (snapshot1.value as? NSDictionary)!
            
            let playerOneUid : String = value1["playerOneUid"] as! String
            let playerTwoUid : String = value1["playerTwoUid"] as! String
            
            let uid : String = (Auth.auth().currentUser?.uid)!
            if uid == playerOneUid {
                self.playerNumber = 1
            }
            if uid == playerTwoUid {
                self.playerNumber = 2
            }
            
            self.refGames.child("users/\(playerOneUid)").observeSingleEvent(of: .value) { (snapshot2) in
                let value2 : NSDictionary = (snapshot2.value as? NSDictionary)!
                let displayName : String = value2["displayName"] as! String
                self.playerOneNameLabel.text = displayName
            }
            
            self.refGames.child("users/\(playerTwoUid)").observeSingleEvent(of: .value) { (snapshot2) in
                let value2 : NSDictionary = (snapshot2.value as? NSDictionary)!
                let displayName : String = value2["displayName"] as! String
                self.playerTwoNameLabel.text = displayName
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Prompt: are you sure?
    }
    
    func updateMoves(moves : String){
         print("moves=\(moves)")
    }
}
