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
    
    let GAME_BOARD_DIM : Int = 4
    
    var refGames : DatabaseReference!
    
    @IBOutlet weak var playerOneNameLabel: UILabel!
    @IBOutlet weak var playOneScoreLabel: UILabel!
    @IBOutlet weak var playerTwoNameLabel: UILabel!
    @IBOutlet weak var playerTwoScoreLabel: UILabel!
    
    var playerOneScore : Int = 0
    var playerTwoScore : Int = 0
    var playerNumber : Int = -1
    
    let myUid : String = (Auth.auth().currentUser?.uid)!
    var roomNumber : Int = -1
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "S.O.S App #\(roomNumber)"
        
        setUpPlayers()
        
        playerOneScore = 0
        playerTwoScore = 0
        updateScores()
    }
    
    func setUpPlayers()
    {
        let i : Int = roomNumber/10000
        refGames = Database.database().reference()
        refGames.child("games/sos/\(i)").observeSingleEvent(of: .value) { (snapshot) in
            
            //Get Dictionary from FireBase
            let value : NSDictionary = (snapshot.value as? NSDictionary)!
            
            let playerOneUid : String = value["playerOneUid"] as! String
            let playerTwoUid : String = value["playerTwoUid"] as! String
            
            let uid : String = (Auth.auth().currentUser?.uid)!
            if uid == playerOneUid {
                self.playerNumber = 1
            }
            if uid == playerTwoUid {
                self.playerNumber = 2
            }
            
            let playerOneDisplayName : String = value["playerOneDisplayName"] as! String
            let playerTwoDisplayName : String = value["playerTwoDisplayName"] as! String
         
            self.playerOneNameLabel.text = (playerOneDisplayName=="nil") ? "Player One" : playerOneDisplayName
            self.playerTwoNameLabel.text = (playerTwoDisplayName=="nil") ? "Player Two" : playerTwoDisplayName
        }
    }
    
    func updateScores(){
        playOneScoreLabel.text = "\(playerOneScore)"
        playerTwoScoreLabel.text = "\(playerTwoScore)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Prompt: are you sure?
    }
}
