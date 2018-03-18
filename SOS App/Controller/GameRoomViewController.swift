//
//  GameViewController.swift
//  SOS App
//
//  Created by Oz Arie Tal Shachar on 14/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import UIKit


class GameRoomViewController: UIViewController {
    
    
    //TODO: - initialize the gameModel variable
    var gameModel : GameModel = GameModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        createdObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func createdObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(forRoomNumber:)), name: NotificationKeys.Room.roomNumber, object: nil)        
    }
    
    @objc func updateUI(forRoomNumber roomNumber: NSNotification){
        
    }
   
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Prompt: are you sure?
    }
    
    
    
    
}
