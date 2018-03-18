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
    
    let myUid : String = (Auth.auth().currentUser?.uid)!
    
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
        //get room number
    }
    
    @objc func updateUI(forRoomNumber roomNumber: NSNotification){
        
    }
   
    
    @IBAction func cancelGameButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Prompt: are you sure?
    }
    
    
    
    
}
