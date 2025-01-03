//
//  GameScene.swift
//  Project14
//
//  Created by Maksim Li on 29/12/2024.
//

import SpriteKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                whackSlot.charNode?.xScale = 0.85
                whackSlot.charNode?.yScale = 0.85
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            run(SKAction.playSoundFileNamed("gameOver.caf", waitForCompletion: false))
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            let finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            finalScoreLabel.text = "Final Score: \(score)"
            finalScoreLabel.position = CGPoint(x: 512, y: 300)
            finalScoreLabel.fontSize = 48
            finalScoreLabel.zPosition = 1
            addChild(finalScoreLabel)
            
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func createSmokeEffect(at position: CGPoint) -> SKEmitterNode {
        let smoke = SKEmitterNode()
        smoke.particleTexture = SKTexture(imageNamed: "spark")
        smoke.position = position
        smoke.zPosition = 1
        
        smoke.particleBirthRate = 100
        smoke.numParticlesToEmit = 40
        smoke.particleLifetime = 1.0
        smoke.particleLifetimeRange = 0.5
        
        smoke.particleColor = .gray
        smoke.particleColorBlendFactor = 1
        smoke.particleColorBlendFactorRange = 0.3
        smoke.particleAlpha = 0.4
        smoke.particleAlphaRange = 0.3
        smoke.particleAlphaSpeed = -0.2
        
   
        smoke.particleSpeed = 80
        smoke.particleSpeedRange = 20
        smoke.emissionAngle = -.pi / 2
        smoke.emissionAngleRange = .pi / 2
        smoke.xAcceleration = 0
        smoke.yAcceleration = 15
        
        smoke.particleScale = 0.5
        smoke.particleScaleRange = 0.2
        smoke.particleScaleSpeed = 0.4
        
        return smoke
    }

    func createMudEffect(at position: CGPoint) -> SKEmitterNode {
        let mud = SKEmitterNode()
        mud.particleTexture = SKTexture(imageNamed: "spark")
        mud.position = position
        mud.zPosition = 1
        
        mud.particleBirthRate = 200
        mud.numParticlesToEmit = 30
        mud.particleLifetime = 0.8
        mud.particleLifetimeRange = 0.4
        
        mud.particleColor = .brown
        mud.particleColorBlendFactor = 1
        mud.particleColorBlendFactorRange = 0.2
        mud.particleAlpha = 0.7
        mud.particleAlphaRange = 0.3
        mud.particleAlphaSpeed = -0.8
        
        mud.particleSpeed = 50
        mud.particleSpeedRange = 20
        mud.emissionAngle = 0
        mud.emissionAngleRange = .pi * 2
        mud.xAcceleration = 0
        mud.yAcceleration = -150
        

        mud.particleScale = 0.4
        mud.particleScaleRange = 0.2
        mud.particleScaleSpeed = -0.2
        
        return mud
    }
}
