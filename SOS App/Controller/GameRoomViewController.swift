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
    
    @IBOutlet weak var board: UIStackView!
    
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
        setupBoard()
    }
    
    func setUpPlayers()
    {
        let i : Int = roomNumber/10000
        refGames = Database.database().reference()
        refGames.child("games/sos/\(i)").observeSingleEvent(of: .value) { (snapshot1) in
            
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
    
    func setupBoard() {
        //let screenWidth : CGFloat = UIScreen.main.bounds.width
       //board.frame.h= screenWidth        
        
        for i in 1...GAME_BOARD_DIM {
            
            let row = UIStackView()
            row.distribution = .fillEqually
            
            for j in 1...GAME_BOARD_DIM {
                
                let button = UIButton()
                button.backgroundColor = UIColor.blue                
                button.setTitle("\(i),\(j)", for: .normal)

                row.addSubview(button)
            }
            board.addSubview(row)
        }
        board.distribution = .fillEqually
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
