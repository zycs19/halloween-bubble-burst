//
//  GameOverScene.swift
//  BubbleBurst
//
//  Created by Ying Zhu on 11/1/21.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabel.text = "Score : \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults.standard
        var highScoreNumber = defaults.integer(forKey: "highScoreNumber")
        
        if(gameScore > highScoreNumber){
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreNumber")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        highScoreLabel.text = "Highest Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch:AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transitionToGOS = SKTransition.fade(with: UIColor.black, duration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transitionToGOS)
            }
        }
    }
}
