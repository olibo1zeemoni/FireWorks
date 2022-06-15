//
//  GameScene.swift
//  Project20
//
//  Created by Olibo moni on 22/02/2022.
//

import SpriteKit


class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var gameOver: SKLabelNode!
    var finalScore: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var isGameOver = false
    
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    var cycle = 0
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "score: \(score)"
        }
    }
    
    
    
    override func didMove(to view: SKView) {
    
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 12
        scoreLabel.position = CGPoint(x: 12, y: 12)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireWorks), userInfo: nil, repeats: true)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer: )))
        self.view?.addGestureRecognizer(pinchRecognizer)
        
        
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int){
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2){
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        fireworks.append(node)
        addChild(node)
        
    }
    
    
    @objc func launchFireWorks(){
        
        cycle += 1
        if cycle > 3 {
            gameTimer?.invalidate()
            endGame()
            return
        }
        
        let movementAmount: CGFloat = 1000
        
        switch Int.random(in: 0...3){
        case 0:
            //fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            //fire five in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break

        }
        
    }
    
    func checkTouches(_ touches: Set<UITouch>){
        guard let touch = touches.first else { return}
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint{
            guard node.name == "firework" else { continue}
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue}
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed(){
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode){
        guard !isGameOver else { return }
        guard let emitter = SKEmitterNode(fileNamed: "explode") else {return}
        emitter.position = firework.position
        addChild(emitter)
          
        let delay = SKAction.wait(forDuration: 1)
                
        firework.removeFromParent()
        
        //remove emitter
        
        //let sequence = SKAction.sequence([delay], emitter.removeFromParent())
        //run sequence
        
    }
    
    func explodeFireworks(){
        guard !isGameOver else { return }
        var numExploded = 0
        
        for (index,fireworkContainer) in fireworks.enumerated().reversed(){
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue}
            
            if firework.name == "selected"{
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
            
        }
        
        switch numExploded{
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
            
        }
        
    }
    
    @objc func tapToExplode(){
        guard !isGameOver else { return }
        explodeFireworks()
    }
    
    func endGame(){
        isGameOver = true
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "Game Over"
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        gameOver.fontSize = 44
        addChild(gameOver)
        
        finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore.text = "Final Score: \(score)"
        finalScore.fontSize = 44
        finalScore.zPosition = 1
        finalScore.position = CGPoint(x: gameOver.position.x, y: gameOver.position.y + 100)
        addChild(finalScore)
        
        gameOverLabel = SKLabelNode(fontNamed: "chalkDuster")
        gameOverLabel.text = "Pinch to restart"
        gameOverLabel!.position = CGPoint(x: 512, y: 600)
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel!.zPosition = 1
        addChild(gameOverLabel)
        return
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer){
        if recognizer.state == .ended {
            restartGame()
        }
    }
    
    @objc func restartGame(){
         isUserInteractionEnabled = true
         isGameOver = false
        
        let transition = SKTransition.fade(with: .magenta, duration: 2)
        let restartScene = GameScene()
        restartScene.size = CGSize(width: 1024, height: 768)
       // restartScene.scaleMode = .fill
        self.view?.presentScene(restartScene, transition: transition)
        
     }
    
}
