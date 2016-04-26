//
//  GameViewController.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright (c) 2016 Michael Hardin. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var lifetimeScore: Int = 0
var highestLevelCompleted: Int = 0
var level: Level!
var xlevel = 0
let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

class GameViewController: UIViewController {
    var scene: GameScene!
   var movesLeft = 0
    var score = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
   var musicPlayer: AVAudioPlayer!
   
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func initAudio(){
        let path = NSBundle.mainBundle().pathForResource("backgd", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        }catch let err as NSError {
            print(err.debugDescription)
        }
        
        
        
    }

    
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    func updateLabels() {
        targetLabel.text = String(level.targetScore)
        movesLabel.text = String(movesLeft)
        scoreLabel.text = String(score)
        levelLabel.text = String(xlevel + 1)
    }
    
    @IBAction func shuffleButtonPressed(sender: UIButton) {
        shuffle()
        decrementMoves()
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lfscore = defaults.objectForKey("lifetimeScore") as? Int {
            lifetimeScore = defaults.objectForKey("lifetimeScore") as! Int
            
        }else {
            lifetimeScore = 0
        }
        
        
        if let xlvl = defaults.objectForKey("xlevel") as? Int {
            xlevel = xlvl
            print(xlevel)
            if xlevel < 100 {
                level = Level(filename: "Level_\(xlevel)")
            }else if xlevel >= 100 {
                level = Level(filename: "Level_\(xlevel-100)")
            }
        }else {
            if xlevel < 100 {
                level = Level(filename: "Level_\(xlevel)")
            }else if xlevel >= 100 {
                level = Level(filename: "Level_\(xlevel-100)")
            }
        }
        
        if let hlc = defaults.objectForKey("highestLevelCompleted") as? Int {
            highestLevelCompleted = defaults.objectForKey("highestLevelCompleted") as! Int
            print(highestLevelCompleted)
        }else {
            highestLevelCompleted = 0
        }
        
       
        
        }
    
    override func viewWillAppear(animated: Bool) {
        
        
        
        
        
        
        beginGame()
    }
    
    func beginGame() {
        
        gameOverPanel.hidden = true
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        //initAudio()
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        level = Level(filename: "Level_\(xlevel)")
        scene.level = level
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        skView.presentScene(scene)
        level.resetComboMultiplier()
        movesLeft = level.maximumMoves
        score = 0
        
        

        updateLabels()
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        shuffle()
        
    }
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
        shuffleButton.hidden = true
    }
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }
    func shuffle() {
        scene.removeAllCookieSprites()
       let newBalls = level.shuffle()
       scene.addSpritesForBalls(newBalls)
    }
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }


    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedBalls(chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = level.fillHoles()
            self.scene.animateFallingBalls(columns) {
                let columns = level.topUpBalls()
                self.scene.animateNewBalls(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        decrementMoves()
    }
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if score >= level.targetScore {
            let winpicnum = Int(arc4random_uniform(18))
            gameOverPanel.image = UIImage(named: "win\(winpicnum)")
            showGameOver()
            
            xlevel = xlevel + 1
            
            if xlevel == 200 {
                xlevel = 0
            }
            
            if xlevel < 100 {
                level = Level(filename: "Level_\(xlevel)")
            }else if xlevel >= 100 {
                level = Level(filename: "Level_\(xlevel-100)")
            }
            
            
            
            if (xlevel) > highestLevelCompleted {
                highestLevelCompleted = xlevel
                
                defaults.setObject(highestLevelCompleted, forKey: "highestLevelCompleted")
                defaults.synchronize()
            }
            
            
            defaults.setObject(xlevel, forKey: "xlevel")
            defaults.synchronize()
            
        } else if movesLeft == 0 {
            
            let losepicnum = Int(arc4random_uniform(19))
            gameOverPanel.image = UIImage(named: "lose\(losepicnum)")
            showGameOver()
            
        }
        lifetimeScore = lifetimeScore + score
        defaults.setObject(lifetimeScore, forKey: "lifetimeScore")
        print("\(lifetimeScore)")
        defaults.synchronize()
    }

}