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
    private var achievementsCache = [String:GKAchievement]()
    
    /// ViewController MainView
    var delegate: UIViewController?
    
    ///  Fist load GameCenter if you want open GameCenter
    var openLoginPageIfPlayerNotLogin : Bool = true
    
    var debugMode : Bool = false
    
    private var achievementsCacheSeeAfter : [String:GKAchievement]?
    
    var showAchievementWhenComplete: Bool = true {
        didSet {
            /* if want show banner when you want */
            if !showAchievementWhenComplete { self.achievementsCacheSeeAfter = [String:GKAchievement]() }
        }
    }
    
/*_______________________________________ STARTER _______________________________________*/
    /**
        Singleton GameCenter Instance
    */
    class var sharedInstance: GameCenter {
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
                if let delegateController = self.delegate {
                    /* If not login open login GameCenter if need */
                    if gameCenterVC != nil && self.openLoginPageIfPlayerNotLogin {
                        delegateController.presentViewController(gameCenterVC, animated: true, completion: nil)
                        
                    } else if self.gameCenterPlayer.authenticated == true {
                        self.canUseGameCenter = true
                        
                    } else  {
                        self.canUseGameCenter = false
                    }
                }

            }
        }
    }
    /**
        Load achievement in cache
    */
    private func gameCenterLoadAchievements(){
        if canUseGameCenter == true && self.achievementsCache.count == 0 {
            GKAchievement.loadAchievementsWithCompletionHandler({ (var achievements:[AnyObject]!, error:NSError!) -> Void in
                if error != nil {
                    if self.debugMode { println("Game Center: could not load achievements, error: \(error)") }
                }
                if achievements != nil {
                    for achievement in achievements  {
                        if let oneAchievement = achievement as? GKAchievement {
                            self.achievementsCache[oneAchievement.identifier] = oneAchievement
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
        if let delegateController = gameCenter.delegate {
            if gameCenter.canUseGameCenter == true {
                var gc = GKGameCenterViewController()
                gc.gameCenterDelegate = gameCenter
                delegateController.presentViewController(gc, animated: true, completion: nil)
            }
        }

        
    }
    
    /**
        Show Game Center Leaderboard passed as string into func

    */
    class func showGameCenterLeaderboard(leaderboardIdentifier uleaderboardId :String) {
        let gameCenter = GameCenter.sharedInstance

        if let delegateController = gameCenter.delegate {
            if gameCenter.canUseGameCenter == true && uleaderboardId != "" {
                var gc = GKGameCenterViewController()
                gc.gameCenterDelegate = gameCenter
                gc.leaderboardIdentifier = uleaderboardId
                gc.viewState = GKGameCenterViewControllerState.Leaderboards
                delegateController.presentViewController(gc, animated: true, completion: nil)
            }
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
    class func ifAchievementFinished(#achievementIdentifier: String) -> Bool{
        
        if let achievement = GameCenter.achievementForIndetifier(identifierAchievement: achievementIdentifier) {
            if achievement.percentComplete == 100 { return true }
            
        }

        return false
    }

    /**
        Add progress to an achievement
    
        :param: Progress achievement Double (ex: 10% = 10.00)
        :param: Achievement Identifier
    */
    class func addProgressToAnAchievement( #progress : Double, achievementIdentifier : String) {
        
        if let achievement = GameCenter.achievementForIndetifier(identifierAchievement: achievementIdentifier) {
            if achievement.percentComplete != 100 {
                achievement.percentComplete = progress
                
                /* show banner only if achievement is fully granted (progress is 100%) */
                if progress == 100.0 {
                    let gameCenter = GameCenter.sharedInstance
                    if gameCenter.showAchievementWhenComplete {
                        achievement.showsCompletionBanner = true
                    } else {
                        gameCenter.achievementsCacheSeeAfter![achievement.identifier] = achievement
                    }
                }
                
                
                /* try to report the progress to the Game Center */
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError!) -> Void in
                    
                    if error != nil {
                        println("Couldn't save achievement (\(achievementIdentifier)) progress to \(progress) %")
                    }
                })
            }
        }
    }
    /**
        Get Achievement Complete if you have ( showAchievementWhenComplete = false )
    
        Example :
        for achievement achievement as? GKAchievement in achievements  {
            if let oneAchievement = achievement as? GKAchievement {
                oneAchievement.identifier
            }
        }
    
        :returns: [String : GKAchievement] or nil
    */
    class func achievementsShowAfterWhenYouWantComplete() -> [String : GKAchievement]? {

        return GameCenter.sharedInstance.achievementsCacheSeeAfter
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
    class func resetOneAchievement(#achievementIdentifier :String) {
        
            if let achievement = GameCenter.achievementForIndetifier(identifierAchievement: achievementIdentifier) {
                GKAchievement.resetAchievementsWithCompletionHandler({ (var error:NSError!) ->
                    Void in
                    
                    if error != nil {
                        println("Couldn't Reset achievement (\(achievementIdentifier))")
                        
                    } else {
                   
                        
                        if let achievementsSeeAfter = GameCenter.sharedInstance.achievementsCacheSeeAfter {
                            if let achievementFind = achievementsSeeAfter[achievementIdentifier] {
                               achievementFind.percentComplete = 0
                            }
                        }
                        
                        achievement.percentComplete = 0
                        println("Reset achievement (\(achievementIdentifier))")
                    }
                    
                })
            }
    }
    
    /**
        Remove All Achievements
    */
    class func resetAllAchievements() {
        let gameCenter = GameCenter.sharedInstance
        
        //if gameCenter.canUseGameCenter == true {
            
            for lookupAchievement in gameCenter.achievementsCache {
                
                var achievementID = lookupAchievement.0
                GameCenter.resetOneAchievement(achievementIdentifier: achievementID)

            }
       // }
    }
    /**
    Get Achievement
    
    :param: identifierAchievement Identifier achievement
    
    :returns: GKAchievement Or nil if not exist
    */
    class func achievementForIndetifier(#identifierAchievement : NSString) -> GKAchievement? {
        let gameCenter = GameCenter.sharedInstance
        
        if gameCenter.canUseGameCenter == true {
            
            if let achievementFind = gameCenter.achievementsCache[identifierAchievement]? {
                return achievementFind
            } else {
                
                if  let achievementGet = GKAchievement(identifier: identifierAchievement) {
                    gameCenter.achievementsCache[identifierAchievement] = achievementGet
                    
                    /* recursive recall this func now that the achievement exist */
                    return GameCenter.achievementForIndetifier(identifierAchievement: identifierAchievement)
                } else {
                    return nil
                }
            }
        }
        return nil
    }
/*____________________________ GameCenter Public GKAchievement __________________________________________________*/


}