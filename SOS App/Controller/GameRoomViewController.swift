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
    
    //colors
    let BGCOLOR_UNSELECTED : UIColor = UIColor.gray
    let BGCOLOR_S_SELECTED : UIColor = UIColor.blue
    let BGCOLOR_O_SELECTED : UIColor = UIColor.blue
    let BGCOLOR_SCORED_BUTTON : UIColor = UIColor.red
    
    let GAME_BOARD_DIM : Int = 7
    var buttons : [Int : UIButton] = [Int : UIButton]()
    var count : Int = 0
    
    var refGames : DatabaseReference!
    
    @IBOutlet weak var board: UIStackView!
    
    @IBOutlet weak var output: UILabel!
    
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
        
        board.axis = .horizontal
        board.alignment = .center
        board.spacing = 0
        
        for i in 1...GAME_BOARD_DIM*2 {
            
            let row = UIStackView()
            row.axis = .vertical
            
            row.distribution = .fillEqually
            row.spacing = 0
            
            for j in 1...GAME_BOARD_DIM {
                
                var type : String = "S"
                if i%2==0 {
                    type = "O"
                }
                
                let key : Int = j*100 + i
                
                let button = UIButton()
                button.tag = key
                button.backgroundColor = BGCOLOR_UNSELECTED
                button.setTitle(type, for: .normal)
                button.addTarget(self, action: #selector(gameButtonPressed(sender:)), for: .touchUpInside)
                
                buttons[key] = button
                
                row.alignment = .center
                row.addArrangedSubview(button)
            }
            board.addArrangedSubview(row)
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
    
    @objc func gameButtonPressed(sender: UIButton){
        sender.isEnabled = false
        
        disableButton(button: sender, color: sender.backgroundColor!, clear: false)
        
        let tag : Int = sender.tag
        let type : String = (buttons[tag]?.titleLabel?.text)!
        var color : UIColor = BGCOLOR_O_SELECTED
        
        if type == "S" {
            color = BGCOLOR_S_SELECTED
        }
        
        sender.backgroundColor = color
        
        let row : Int = tag/100
        let col : Int = tag%100
        
        if tag%2==0{
            disableButton(button: buttons[tag-1]!, color: color, clear: true)
        } else {
            disableButton(button: buttons[tag+1]!, color: color, clear: true)
        }
        
        checkForPoints(tag: tag, row: row, col: col, type: type)
        
        if count == buttons.count {
            gameOver()
        }
    }
    
    
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Prompt: are you sure?
    }
    
    func disableButton(button: UIButton?, color: UIColor, clear: Bool){
        count = count + 1
        button?.isEnabled = false
        button?.backgroundColor = color
        if clear {
            button?.setTitle(" ", for: .normal)
        }
    }
    
    func checkForPoints(tag: Int, row: Int, col: Int, type: String)
    {
        if type == "O" {
            checkForPoints(button1: buttons[tag-3], button2: buttons[tag], button3: buttons[tag+1])
            checkForPoints(button1: buttons[tag-101], button2: buttons[tag], button3: buttons[tag+99])
            
            //checkForPoints(button1: buttons[tag-103], button2: buttons[tag], button3: buttons[tag+101])
            //checkForPoints(button1: buttons[tag+97], button2: buttons[tag], button3: buttons[tag-97])
        }
        
        if type == "S" {
            //checkForPoints(button1: buttons[tag], button2: buttons[tag+3], button3: buttons[tag+4])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag+103], button3: buttons[tag+204])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag+101], button3: buttons[tag+200])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag-1], button3: buttons[tag-4])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag-99], button3: buttons[tag-200])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag-97], button3: buttons[tag-196])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag-101], button3: buttons[tag-204])
            //checkForPoints(button1: buttons[tag], button2: buttons[tag+99], button3: buttons[tag+196])
        }
    }
    
    func checkForPoints(button1: UIButton?, button2: UIButton?, button3: UIButton?){
        let cond : Bool = button1 != nil && button2 != nil && button3 != nil
        if cond {
            checkForPointsNoNulls(button1: button1!, button2: button2!, button3: button3!)
        }
    }
    
    func checkForPointsNoNulls(button1: UIButton!, button2: UIButton!, button3: UIButton!){
        let cond : Bool = button1?.isEnabled==false && button1?.isEnabled==false && button1?.isEnabled==false
        if cond {
            disableButton(button: button1!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            disableButton(button: buttons[(button1?.tag)!+1]!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            
            disableButton(button: button2!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            disableButton(button: buttons[(button2?.tag)!-1]!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            
            disableButton(button: button3!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            disableButton(button: buttons[(button3?.tag)!+1]!, color: BGCOLOR_SCORED_BUTTON, clear: false)
            
            playerScored()
        }
    }
    
    func playerScored(){
        
    }
    
    func gameOver(){
        output.text = "GAME OVER"
    }
}
