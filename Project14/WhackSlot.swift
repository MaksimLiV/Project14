//
//  WhackSlot.swift
//  Project14
//
//  Created by Maksim Li on 31/12/2024.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        // Add mud effect when coming out
        if let gameScene = self.scene as? GameScene {
            let mudEffect = gameScene.createMudEffect(at: CGPoint(x: 0, y: -50))
            mudEffect.numParticlesToEmit = 15
            addChild(mudEffect)
            
            // Remove the mud effect after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                mudEffect.removeFromParent()
            }
        }
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        // Add mud effect when going back in
        if let gameScene = self.scene as? GameScene {
            let mudEffect = gameScene.createMudEffect(at: CGPoint(x: 0, y: -50))
            mudEffect.numParticlesToEmit = 15
            addChild(mudEffect)
            
            // Remove the mud effect after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                mudEffect.removeFromParent()
            }
        }
        
        charNode.run(SKAction.move(to: CGPoint(x: 0, y: -80), duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        // Add smoke effect when hit
        if let gameScene = self.scene as? GameScene {
            let smokeEffect = gameScene.createSmokeEffect(at: CGPoint(x: 0, y: 0))
            addChild(smokeEffect)
            
            // Remove the smoke effect after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                smokeEffect.removeFromParent()
            }
        }
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in self?.isVisible = false }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
}
