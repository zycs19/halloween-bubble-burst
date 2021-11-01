//
//  GameScene.swift
//  BubbleBurst
//
//  Created by Ying Zhu on 10/31/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameScore = 0
    let scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    var healthScore = 0
    let healthLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    var levelNumber = 0
    let levelLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    
    let player = SKSpriteNode(imageNamed: "player")
    let bulletSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let pointsSound = SKAction.playSoundFileNamed("point.wav", waitForCompletion: false)
    
    
    struct physicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1
        static let Bullet : UInt32 = 0b10
        static let Enemy : UInt32 = 0b100
        static let Points : UInt32 = 0b1000
    }
    var gameArea : CGRect
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random()*(max - min) + min
    }
    override init(size: CGSize) {
        let maxAspectRatio : CGFloat = 16.0/10.0
        let playablewidth = size.height/maxAspectRatio
        let margin = (size.width - playablewidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playablewidth, height: size.height)
        //gameArea = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(0.35)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        
        self.addChild(player)
        
        scoreLabel.text = "Score : 0"
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        healthLabel.text = "Health : 0"
        healthLabel.fontSize = 100
        healthLabel.fontColor = SKColor.white
        healthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        healthLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.9)
        healthLabel.zPosition = 100
        self.addChild(healthLabel)
        
        levelLabel.text = "Level : 0"
        levelLabel.fontSize = 100
        levelLabel.fontColor = SKColor.orange
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        levelLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.1)
        levelLabel.zPosition = 100
        self.addChild(levelLabel)
        
        livesLabel.text = "Lives : 3"
        livesLabel.fontSize = 100
        livesLabel.fontColor = SKColor.orange
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.1)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        
        
        startNewLevel()
    }
    
    func addScore(score:Int){
        
        gameScore += score
        scoreLabel.text = "Score : \(gameScore)"
        
        if(gameScore / 10 > levelNumber){
            startNewLevel()
            levelLabel.text = "Level : \(levelNumber)"
        }
        
    }
    
    func updateLives(num:Int){
        livesNumber += num
        livesLabel.text = "Lives : \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
    }
    
    func addHealthScore(score:Int){
        healthScore += score
        healthLabel.text = "Health : \(healthScore)"
        if(healthScore > 15){
            updateLives(num: 1)
            healthScore -= 15
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if(body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Enemy){
            
            spawnExplosion(spawnPosition: body1.node!.position)
            spawnExplosion(spawnPosition: body2.node!.position)
            updateLives(num: -1)
            
            if(body1.node != nil && livesNumber < 0){
                body1.node?.removeFromParent()
            }
            if(body2.node != nil){
                body2.node?.removeFromParent()
            }
            
        }
        
        if(body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Points){
            
            addHealthScore(score: 5)
            spawnAddPoints(spawnPosition: body1.node!.position)
            
            if(body2.node != nil){
                body2.node?.removeFromParent()
            }
            
        }
        
        if (body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.Enemy && body2.node?.position.y ?? 0 < self.size.height) {
            
            addScore(score: 3)
            
            if(body2.node != nil){
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition : CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 4
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 0.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    func spawnAddPoints(spawnPosition : CGPoint){
        let addPoints = SKSpriteNode(imageNamed: "star")
        addPoints.position = spawnPosition
        addPoints.zPosition = 4
        addPoints.setScale(0)
        addPoints.alpha = 0.6
        self.addChild(addPoints)
        
        let scaleIn = SKAction.scale(to: 10, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let addPointsSequence = SKAction.sequence([pointsSound, scaleIn, fadeOut, delete])
        
        addPoints.run(addPointsSequence)
        
    }
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(0.20)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = physicsCategories.Bullet
        
        bullet.physicsBody!.collisionBitMask = physicsCategories.None
        bullet.physicsBody!.contactTestBitMask = physicsCategories.Enemy

        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy(){
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.setScale(0.2)
        enemy.alpha = 0.5
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.None
        enemy.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        

        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.0)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    func spawnPoints(){
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let points = SKSpriteNode(imageNamed: "pumpkin")
        points.setScale(0.7)
        points.position = startPoint
        points.zPosition = 3
        points.physicsBody = SKPhysicsBody(rectangleOf: points.size)
        points.physicsBody!.affectedByGravity = false
        points.physicsBody!.categoryBitMask = physicsCategories.Points
        points.physicsBody!.collisionBitMask = physicsCategories.None
        points.physicsBody!.contactTestBitMask = physicsCategories.Player
        

        self.addChild(points)
        
        let movePoints = SKAction.move(to: endPoint, duration: 2.0)
        let deletePoints = SKAction.removeFromParent()
        let pointsSequence = SKAction.sequence([movePoints, deletePoints])
        points.run(pointsSequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        points.zRotation = amountToRotate
        
    }
    func startNewLevel(){
        
        levelNumber += 1
        
        if(self.action(forKey: "spawningEnermies") != nil){
            self.removeAction(forKey: "spawningEnermies")
        }
        
        var levelDuration = 3.0
        for temp in 1...levelNumber{
            levelDuration *= 0.8
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let spawnPoints = SKAction.run(spawnPoints)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn, waitToSpawn, spawn, waitToSpawn, spawn, waitToSpawn, spawnPoints])
        
        let spawnForever = SKAction.repeat(spawnSequence, count: 100000)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
        //spawnEnemy()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player.position.x += amountDragged
            
            if player.position.x > gameArea.maxX{
                player.position.x = gameArea.maxX
            }
            if player.position.x < gameArea.minX{
                player.position.x = gameArea.minX
            }
            
        }
    }
}
