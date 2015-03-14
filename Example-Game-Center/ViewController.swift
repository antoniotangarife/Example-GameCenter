//
//  ViewController.swift
//  Example-Game-Center
//
//  Created by DaRk-_-D0G on 08/01/2015.
//  Copyright (c) 2015 DaRk-_-D0G. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gameCenter : GameCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init GameCenter Singleton
        let gameCenter = GameCenter.startGameCenter(self)
        
        // Open Login page if player not login after loading GameCenter
        gameCenter.openLoginPageIfPlayerNotLogin = false
        
        // If want show message Error
        gameCenter.debugMode = true
        
    }

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    /**
        Action Button for open GameCenter of player
    
        :param: sender AnyObject
    */
    @IBAction func ActionOpenGameCenter(sender: AnyObject) {
        
        GameCenter.showGameCenter()
        
    }
    /**
        Action button if player is connected
    
        :param: sender AnyObject
    */
    @IBAction func ActionIfLoginToGameCenter(sender: AnyObject) {
    
        var stringDialog = ""
        
        if GameCenter.ifPlayerIdentifiedToGameCenter() {
            print("YES \n")
            stringDialog = "YES ! I'am connected"
            
        } else {
            print("NON \n")
            stringDialog = "No ! I'm not connected"
        }
        
        self.dialog(stringDialog)
        
    }
    

    /**
        Valide an Achievement
    
        :param: sender AnyObject
    */
    @IBAction func ActionValidAchievement(sender: AnyObject) {
        
        GameCenter.addProgressToAnAchievement(progress: 100.00,achievementIdentifier: "TESTREA")
        
    }
    /**
        Reset One Achievement player Game Center
    */
    @IBAction func ActionOneAchievement(sender: AnyObject) {
        
        GameCenter.resetOneAchievement(achievementIdentifier: "TESTREA")
        
    }
    /**
        Reset all Achievement player Game Center
    */
    @IBAction func ActionResetAchievement(sender: AnyObject) {
        
       GameCenter.resetAllAchievements()
        
    }

    /**
        Report Score to Game Center
    */
    @IBAction func ActionReportScore(sender: AnyObject) {
        
        GameCenter.reportScore(score: 100, leaderboardIdentifier: "IdentifierLeaderBoard")
        
    }
  
    @IBAction func ActionIsFinish(sender: AnyObject) {
        if GameCenter.ifAchievementFinished(achievementIdentifier: "TESTREA") {
            dialog("YES Is finish")
        } else {
            dialog("NON Isn't finish")
        }
    }
    
    /**
        Show Game Center LeaderBoard by Name
    
        :param: sender AnyObject
    */
    @IBAction func ActionShowGameCenterLeaderBoard(sender: AnyObject) {
        
        GameCenter.showGameCenterLeaderboard(leaderboardIdentifier: "CLASSEMENT_francais")
        
    }
/*______________________________ OTHER ______________________________*/
    /**
    Simple dialog func
    
    :param: myString my String
    */
    func dialog(myString : String) {
        var refreshAlert = UIAlertController(title: "Message", message: myString, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
}

