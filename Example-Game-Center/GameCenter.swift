//
//  GameCenter.swift
//
//  Created by Yannick Stephan DaRk-_-D0G on 19/12/2014.
//  YannickStephan.com
//
//	iOS 7.0, 8.0+
//
//	The MIT License (MIT)
//	Copyright (c) 2014 Tobias Due Munk
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import GameKit


/**
GameCenter iOS
*/
class GameCenter: NSObject, GKGameCenterControllerDelegate {
    
    /// The local player object.
    private let gameCenterPlayer = GKLocalPlayer.localPlayer()
    
    /// player can use GameCenter
    private var canUseGameCenter:Bool = false {
        didSet {
            /* load prev. achievments form Game Center */
            if canUseGameCenter { gameCenterLoadAchievements() }
        }}
    
    /// Achievements of player
    private var gameCenterAchievements = [String:GKAchievement]()
    
    /// ViewController MainView
    private var vc: UIViewController?
    
    ///  Fist load GameCenter if you want open GameCenter
    var openLoginPageIfPlayerNotLogin : Bool = true
    
    var debugMode : Bool = false
    
    
/*_______________________________________ STARTER _______________________________________*/
    /**
    Start With delegate ViewController
    
    :param: delegate UIViewController Delegate
    */
    class func startGameCenter(delegate : UIViewController) -> GameCenter {
        let game = GameCenter.sharedInstance
        game.vc = delegate
        return game
    }
    /**
        Singleton GameCenter Instance
    */
    private class var sharedInstance: GameCenter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: GameCenter? = nil
        }
        
        if Static.instance == nil {
            dispatch_once(&Static.onceToken) {
                Static.instance = GameCenter()
                Static.instance!.loginPlayerToGameCenter()
            }
        }

        return Static.instance!
    }
    
    
    
    /**
    Constructor
    */
    override init() { super.init() }
/*____________________________ GameCenter Private Function __________________________________________________*/
    /**
        Login player to GameCenter With Handler Authentification
    */
    private func loginPlayerToGameCenter () {
        
        self.gameCenterPlayer.authenticateHandler = {(var gameCenterVC:UIViewController!, var gameCenterError:NSError!) -> Void in
            
            /* If got error */
            if gameCenterError != nil {
                if self.debugMode { print("Error when login : " + gameCenterError.localizedDescription) }
                self.canUseGameCenter = false
                
            } else {
                /* If not login open login GameCenter if need */
                if gameCenterVC != nil && self.openLoginPageIfPlayerNotLogin {
                    self.vc!.presentViewController(gameCenterVC, animated: true, completion: nil)
                    
                } else if self.gameCenterPlayer.authenticated == true {
                    self.canUseGameCenter = true
                    
                } else  {
                    self.canUseGameCenter = false
                }
            }
        }
    }
    /**
        Load achievement in cache
    */
    private func gameCenterLoadAchievements(){
        if canUseGameCenter == true && self.gameCenterAchievements.count == 0 {
            GKAchievement.loadAchievementsWithCompletionHandler({ (var achievements:[AnyObject]!, error:NSError!) -> Void in
                if error != nil {
                    if self.debugMode { println("Game Center: could not load achievements, error: \(error)") }
                }
                if achievements != nil {
                    for achievement in achievements  {
                        if let oneAchievement = achievement as? GKAchievement {
                            self.gameCenterAchievements[oneAchievement.identifier] = oneAchievement
                        }
                    }
                }
            })
        }
    }
/*_______________________________ Internal Func _______________________________________________*/
    /**
        Dismiss Game Center when player open
        :param: GKGameCenterViewController
    
        Override of GKGameCenterControllerDelegate
    */
    internal func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
/*____________________________ GameCenter Public Function __________________________________________________*/
    /**
        Show Game Center Player
    
    */
    class func showGameCenter() {
        
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            var gc = GKGameCenterViewController()
            gc.gameCenterDelegate = gameCenter
            gameCenter.vc!.presentViewController(gc, animated: true, completion: nil)
        }
        
    }
    
    /**
        Show Game Center Leaderboard passed as string into func

    */
    class func showGameCenterLeaderboard(leaderboardIdentifier uleaderboardId :String) {
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true && uleaderboardId != "" {
            var gc = GKGameCenterViewController()
            gc.gameCenterDelegate = gameCenter
            gc.leaderboardIdentifier = uleaderboardId
            gc.viewState = GKGameCenterViewControllerState.Leaderboards
            gameCenter.vc!.presentViewController(gc, animated: true, completion: nil)
        }
    }
    
    /**
        If player is Identified to Game Center
    
        :returns: Bool True is identified
    */
    class func ifPlayerIdentifiedToGameCenter() -> Bool { return GameCenter.sharedInstance.canUseGameCenter }
    
    /**
        If achievement is Finished
    
        :param: achievementIdentifier
        :return: Bool True is finished
    */
    class func ifAchievementFinished(achievementIdentifier uAchievementId:String) -> Bool{
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenter.gameCenterAchievements[uAchievementId]
            if let achievement = lookupAchievement {
                if achievement.percentComplete == 100 { return true }
            } else {
                gameCenter.gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                return ifAchievementFinished(achievementIdentifier: uAchievementId)
            }
        }
        return false
    }

    /**
        Add progress to an achievement
    
        :param: Progress achievement Double (ex: 10% = 10.00)
        :param: Achievement Identifier
    */
    class func addProgressToAnAchievement(progress uProgress:Double,achievementIdentifier uAchievementId:String) {
        let gameCenter = GameCenter.sharedInstance

        if gameCenter.canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenter.gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                if achievement.percentComplete != 100 {
                    achievement.percentComplete = uProgress
                    
                    if uProgress == 100.0  {
                        /* show banner only if achievement is fully granted (progress is 100%) */
                        achievement.showsCompletionBanner=true
                    }
                    
                    /* try to report the progress to the Game Center */
                    GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError!) -> Void in
                        if error != nil {
                            if gameCenter.debugMode { println("Couldn't save achievement (\(uAchievementId)) progress to \(uProgress) %") }
                        }
                    })
                }
            /* Is Finish */
            } else {
                
                gameCenter.gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                
                /* recursive recall this func now that the achievement exist */
                addProgressToAnAchievement(progress: uProgress, achievementIdentifier: uAchievementId)
            }
        }
    }
    
    /**
        Reports a  score to Game Center
    
        :param: The score Int
        :param: Leaderboard identifier
    */
    class func reportScore(score uScore: Int,leaderboardIdentifier uleaderboardIdentifier: String)  {
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            
            var scoreReporter = GKScore(leaderboardIdentifier: uleaderboardIdentifier)
            scoreReporter.value = Int64(uScore)
            
            var scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, {(error : NSError!) -> Void in
                
                if error != nil {
                    if gameCenter.debugMode { println(error.localizedDescription) }
                }
                
            })
        }
    }
    
    /**
        Remove One Achievements
    
        :param: Achievement Identifier String
    */
    class func resetOneAchievement(achievementIdentifier uAchievementId:String) {
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            var lookupAchievement:GKAchievement? = gameCenter.gameCenterAchievements[uAchievementId]
            
            if let achievement = lookupAchievement {
                GKAchievement.resetAchievementsWithCompletionHandler({ (var error:NSError!) -> Void in
                    if error != nil {
                        if gameCenter.debugMode { println("Couldn't Reset achievement (\(uAchievementId))") }
                    } else {
                        if gameCenter.debugMode { println("Reset achievement (\(uAchievementId))") }
                    }
                })
                
            } else {
                /* Load in cache if above this is not done */
                gameCenter.gameCenterAchievements[uAchievementId] = GKAchievement(identifier: uAchievementId)
                
                /* recursive recall this func now that the achievement exist */
                self.resetOneAchievement(achievementIdentifier: uAchievementId)
            }
        }
    }
    
    /**
        Remove All Achievements
    */
    class func resetAllAchievements() {
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            
            for lookupAchievement in gameCenter.gameCenterAchievements {
                var achievementID = lookupAchievement.0
                var lookupAchievement:GKAchievement? =  lookupAchievement.1
                
                if let achievement = lookupAchievement {
                    GKAchievement.resetAchievementsWithCompletionHandler({ (var error:NSError!) -> Void in
                        if error != nil {
                            if gameCenter.debugMode { println("Couldn't Reset achievement (\(achievementID))") }
                            
                        } else {
                            if gameCenter.debugMode { println("Reset achievement (\(achievementID))") }
                            
                        }
                    })
                    
                } else {
                    /* Load in cache if above this is not done */
                    gameCenter.gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                    
                    /* recursive recall this func now that the achievement exist */
                    self.resetOneAchievement(achievementIdentifier: achievementID)
                }
            }
        }
    }
}