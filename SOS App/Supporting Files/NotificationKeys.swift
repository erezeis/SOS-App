//
//  NotificationKeys.swift
//  SOS App
//
//  Created by hackeru on 18/03/2018.
//  Copyright © 2018 Oz Arie Tal Shachar. All rights reserved.
//

import Foundation

struct NotificationKeys {
    
    struct Room {
        static let roomNumber = Notification.Name("roomNumber")
    }
    
    struct Players {
        static let playerOneUid = Notification.Name("playerOneUid")
        static let playerTwoUid = Notification.Name("playerTwoUid")
    }
}
