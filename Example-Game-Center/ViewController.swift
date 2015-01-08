//
//  ViewController.swift
//  Example-Game-Center
//
//  Created by DaRk-_-D0G on 08/01/2015.
//  Copyright (c) 2015 DaRk-_-D0G. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /******* ADD GameCenter Swift *******/
    var gameCenter: GameCenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /******* ADD delegate root view controller GameCenter Swift *******/
        self.gameCenter = GameCenter(rootViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var textIDAchievement: UITextField!

    @IBAction func ActionValidAchievement(sender: AnyObject) {
        self.gameCenter.addProgressToAnAchievement(progress: 100.00,achievementIdentifier: textIDAchievement.text!)
    }

    @IBAction func ActionOpenGameCenter(sender: AnyObject) {
        self.gameCenter.showGameCenter()
    }
    
    @IBAction func ActionResetAchievement(sender: AnyObject) {
        self.gameCenter.resetAllAchievements()
    }
  
    @IBAction func ActionIsFinish(sender: AnyObject) {
        self.gameCenter.isAchievementFinished(achievementIdentifier: textIDAchievement.text!)
    }
    
}

