//
//  GameViewController.swift
//  SOS App
//
//  Created by Oz Arie Tal Shachar on 14/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class GameRoomViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    
    var buttons : [String : UIButton] = [String : UIButton]()
    
    var refGames : DatabaseReference! = Database.database().reference()
    
    @IBOutlet weak var board: UIStackView!
    
    @IBOutlet weak var statusBarLabel: UILabel!
    
    @IBOutlet weak var playerOneNameLabel: UILabel!
    @IBOutlet weak var playOneTypeLabel: UILabel!
    @IBOutlet weak var playerTwoNameLabel: UILabel!
    @IBOutlet weak var playerTwoTypeLabel: UILabel!
    
    var playerNumber : Int = -1
    var playerType : String = ""
    var isTurnToPlay : Bool = false
    var isGameOver : Bool = false
    var moves : String = ""
    
    let myUid : String = (Auth.auth().currentUser?.uid)!
    var roomNumber : Int = -1 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
        self.title = "#\(roomNumber)"
        isTurnToPlay = false
        isGameOver = false
        setUpButtons()
        setUpPlayers()
    }
    
    func postPlayersSetup(){
        let index : Int = roomNumber/10000
        self.refGames.child("games/xoxo/\(index)/moves").observe(DataEventType.value, with: { (snapshot) in
            let moves = snapshot.value as! NSString
            self.moves = String("\(moves)")
            self.updateMoves(moves: self.moves)
        })
        
        if playerNumber==1 {
            refGames.child("games/xoxo/\(index)/gameStatus").setValue("Game started")
        }
        
        self.refGames.child("games/xoxo/\(index)/gameStatus").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! NSString
            let status : String = String("\(value)")
            self.onStatusChanged(status: status)
        })
    }
    
    func setUpButtons(){
        button1.setTitle("", for: .normal)
        button2.setTitle("", for: .normal)
        button3.setTitle("", for: .normal)
        button4.setTitle("", for: .normal)
        button5.setTitle("", for: .normal)
        button6.setTitle("", for: .normal)
        button7.setTitle("", for: .normal)
        button8.setTitle("", for: .normal)
        button9.setTitle("", for: .normal)
        
        buttons["1"] = button1
        buttons["2"] = button2
        buttons["3"] = button3
        buttons["4"] = button4
        buttons["5"] = button5
        buttons["6"] = button6
        buttons["7"] = button7
        buttons["8"] = button8
        buttons["9"] = button9
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
                self.playerType = "X"
            }
            if uid == playerTwoUid {
                self.playerNumber = 2
                self.playerType = "O"
            }
            
            self.refGames.child("users/\(playerOneUid)").observeSingleEvent(of: .value) { (snapshot2) in
                let value2 : NSDictionary = (snapshot2.value as? NSDictionary)!
                let displayName : String = value2["displayName"] as! String
                self.playerOneNameLabel.text = displayName
                self.makeSureNamesAreNotTheSame()
            }
            
            self.refGames.child("users/\(playerTwoUid)").observeSingleEvent(of: .value) { (snapshot2) in
                let value2 : NSDictionary = (snapshot2.value as? NSDictionary)!
                let displayName : String = value2["displayName"] as! String
                self.playerTwoNameLabel.text = displayName
                self.makeSureNamesAreNotTheSame()
            }
            
            self.postPlayersSetup()
        }
    }
    
    func makeSureNamesAreNotTheSame(){
        let name1 : String = self.playerOneNameLabel.text!
        let name2 : String = self.playerTwoNameLabel.text!
        
        if name1 != "" && name1==name2 {
            if playerNumber==1 {
                self.playerOneNameLabel.text = "\(name1) (you)"
            } else if playerNumber==2 {
                self.playerTwoNameLabel.text = "\(name2) (you)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        if isGameOver {
                return
        }
        
        let alert = UIAlertController(title: "Cancel game", message: "Are you sure?", preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            self.gameCanceledByMe()
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func gameButtonPressed(_ sender: UIButton) {
        guard isTurnToPlay else {
            return
        }
        
        guard !isGameOver else {
            return
        }
        
        let currentTitle : String = sender.currentTitle!        
        guard currentTitle=="" else {
            return
        }
        
        isTurnToPlay = false
        let key : String = "\(sender.tag)"
        buttons[key]?.setTitle(playerType, for: .normal)
        checkForWin()
        addMove(tag: sender.tag)
    }
    
    func updateMoves(moves : String) {
        if moves=="" {
            statusBarLabel.text = "It is X turn to play"
            isTurnToPlay = playerNumber==1
            SVProgressHUD.dismiss()
            return
        }
        
        let n : Int = moves.count
        
        var type : String = "X"
        
        for i in 0..<n{
            type = i%2==0 ? "X" : "O"
            
            let index = moves.index(moves.startIndex, offsetBy: i)
            let key : String = "\(moves[index])"
            buttons[key]?.setTitle(type, for: .normal)
        }
        
        switch playerNumber {
        case 1:
            if type == "O" {
                isTurnToPlay = true
                statusBarLabel.text = "It is X turn to play"
            } else {
                isTurnToPlay = false
                statusBarLabel.text = "It is O turn to play"
            }
            
            break
        case 2:
            if type == "X" {
                isTurnToPlay = true
                statusBarLabel.text = "It is O turn to play"
            } else {
                isTurnToPlay = false
                statusBarLabel.text = "It is X turn to play"
            }
            
            break
        default:
            break
        }
        
        SVProgressHUD.dismiss()
        let winnerDeclared : Bool = checkForWin()
        let cond : Bool = !winnerDeclared && n>=9
        if cond {
            declareNoWinner()
        }
    }
    
    func checkForWin() -> Bool {
        var winnerType : String = getWinnerType(key1: "1", key2: "2", key3: "3")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "4", key2: "5", key3: "6")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "7", key2: "8", key3: "9")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "1", key2: "4", key3: "7")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "2", key2: "5", key3: "8")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "3", key2: "6", key3: "9")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "1", key2: "5", key3: "9")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        winnerType = getWinnerType(key1: "3", key2: "5", key3: "7")
        if winnerType != "" {
            declareWinner(winner: winnerType)
            return true
        }
        
        return false
    }
    
    func getWinnerType(key1 : String, key2 : String, key3 : String) -> String {
        let button1 : UIButton = buttons[key1]!
        let button2 : UIButton = buttons[key2]!
        let button3 : UIButton = buttons[key3]!
        
        if button1.currentTitle == button2.currentTitle && button2.currentTitle == button3.currentTitle {
            return button1.currentTitle!
        }
        
        return ""
    }
    
    func declareWinner(winner : String){
        if playerType==winner {
                statusBarLabel.text = "Oh yeah! \(winner) wins!!"
        } else {
            statusBarLabel.text = "Oh no... \(winner) won"
        }
        
        postGame()
    }
    
    func declareNoWinner(){
        statusBarLabel.text = "It's a Tied Game"
        postGame()
    }
    
    func postGame(){
        isGameOver = true
        self.navigationItem.setRightBarButton(nil, animated: false)
        
        self.navigationItem.backBarButtonItem?.action = #selector(goBackToMainMenu)
        self.navigationItem.backBarButtonItem?.title = "Main Menu"
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    func addMove(tag: Int){
        let index : Int = roomNumber/10000
        refGames.child("games/xoxo/\(index)/moves").setValue("\(moves)\(tag)")
    }
    
    func gameCanceledByMe(){
        isGameOver = true
        let index : Int = roomNumber/10000
        refGames.child("games/xoxo/\(index)/gameStatus").setValue("Game canceled by \(playerNumber)")
        refGames.removeAllObservers()
        goBackToMainMenu()
    }
    
    func gameCanceledByOtherPlayer(){
        isGameOver = true
        var name : String = playerOneNameLabel.text!
        if playerNumber==1 {
            name = playerTwoNameLabel.text!
        }
        
        let alert = UIAlertController(title: "Room closed", message: "\(name) has left the room. Press 'OK' to return to Main Menu.", preferredStyle: .alert)
        
        let actionOK = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            self.goBackToMainMenu()
        }
        
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func goBackToMainMenu(){
        self.performSegue(withIdentifier: "goBackToMainMenu", sender: self)
    }
    
    func onStatusChanged(status : String) {
        let cond : Bool = (playerNumber==1 && status=="Game canceled by 2") || (playerNumber==2 && status=="Game canceled by 1")
        if cond {
            self.gameCanceledByOtherPlayer()
        }
    }
}
