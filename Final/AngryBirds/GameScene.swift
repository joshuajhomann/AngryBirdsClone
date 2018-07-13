//
//  GameScene.swift
//  AngryBirds
//
//  Created by Joshua Homann on 4/3/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: - Variables
    private var square: SKSpriteNode!
    private var squareCopy: SKSpriteNode!
    private var state = GameState.idle
    private var launchTime: TimeInterval!
    private var damagedNodes: [SKSpriteNode: CGFloat] = [:]
    private var emitter: SKEmitterNode!
    private var blood: SKEmitterNode!
    // MARK: - Constants
    private enum GameState {
        case idle, panning, dragging, animating
    }
    private let labelAttributes: [NSAttributedStringKey: Any] = [.font: UIFont(name: "ChalkboardSE-Regular", size: 60)!,
                                                                 .foregroundColor: UIColor.white,
                                                                 .strokeColor: UIColor.black,
                                                                 .strokeWidth: -2]
    private let cameraNode = SKCameraNode()
    // MARK: - SKView
    override func didMove(to view: SKView) {
        square = childNode(withName: "💩") as? SKSpriteNode
        squareCopy = square.copy() as? SKSpriteNode
        emitter = SKEmitterNode(fileNamed: "explode")!
        blood = SKEmitterNode(fileNamed: "blood")!
        camera = cameraNode
        addChild(cameraNode)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:))))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        physicsWorld.contactDelegate = self

    }
    override func update(_ currentTime: TimeInterval) {
        guard state == .animating else {
            return
        }
        damagedNodes.forEach { self.apply($0.value, to: $0.key)}
        damagedNodes.removeAll()
        cameraNode.position = square.position
        cameraNode.position.y +=  frame.size.height / 4 * cameraNode.yScale
        launchTime = launchTime == nil ? currentTime : launchTime
        if currentTime - launchTime > 8 || square.physicsBody?.isResting ?? true {
            resetSquare()
            state = .idle
            self.camera?.run(SKAction.scale(to: 1, duration: 1))
            self.camera?.run(SKAction.move(to: square.position, duration: 1))
        }
    }
    //MARK: - Instance
    @objc private func doubleTap(_ recognizer: UITapGestureRecognizer) {
        camera?.run(SKAction.group([SKAction.scale(to: 1, duration: 1),
                                    SKAction.move(to: square.position, duration: 1)]))
    }
    @objc private func pinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = max (1, min(1/recognizer.scale * cameraNode.xScale, 3))
        cameraNode.setScale(scale)
    }
    @objc private func pan(_ recognizer: UIPanGestureRecognizer) {
        guard state != .animating else {
            return
        }
        switch recognizer.state {
        case .began:
            let pointInView = recognizer.location(in: view)
            let pointInScene = convertPoint(fromView: pointInView)
            let pointInCamera = pointInScene.applying(CGAffineTransform(scaleX: 1/cameraNode.xScale,
                                                                        y: 1/cameraNode.yScale))
            state = square.frame.insetBy(dx: -40, dy: -40)
                                .contains(pointInScene) ? .dragging : .panning
        case .changed:
            if state == .dragging {
                let vector = clamp(translation: recognizer.translation(in: view))
                square.position.x = squareCopy.position.x + vector.dx
                square.position.y = squareCopy.position.y + vector.dy
            } else if state == .panning {
                let translation = recognizer.translation(in: view)
                cameraNode.position.x -= translation.x * 3
                cameraNode.position.y += translation.y * 3
                recognizer.setTranslation(.zero, in: view)
            }
        case .ended:
            guard state == .dragging else {
                return
            }
            var impulse = clamp(translation: recognizer.translation(in: view))
            impulse.dx *= -1
            impulse.dy *= -1
            square.physicsBody?.applyImpulse(impulse)
            square.physicsBody?.affectedByGravity = true
            state = .animating
            cameraNode.run(SKAction.scale(to: 2.0, duration: 1))
        case .cancelled:
            defer { state = .animating }
            guard state == .dragging else {
                return
            }
            square.position = squareCopy.position
        default:
            break
        }
    }
    private func apply(_ collisionDamage: CGFloat, to node: SKSpriteNode) {
        guard let damage = node.userData?["damage"] as? CGFloat,
              let maxDamage = node.userData?["maxDamage"] as? CGFloat,
              collisionDamage >= 1.0 else {
                return
        }
        let text = NSAttributedString(string: Int(collisionDamage).description,
                                      attributes: labelAttributes)
        let label = SKLabelNode(attributedText: text)
        label.position = node.position
        self.addChild(label)
        label.run(SKAction.sequence([SKAction(named: "floatUp")!,
                                     SKAction.removeFromParent()]))
        let totalDamage = damage + collisionDamage
        node.userData = ["damage": totalDamage, "maxDamage": maxDamage]
        if node.name == "enemy" {
            if totalDamage / maxDamage > 0.66 {
                node.texture = SKTexture(imageNamed: "enemydamage1")
            } else if totalDamage / maxDamage > 0.25 {
                node.texture = SKTexture(imageNamed: "enemyDamage")
            }
        }
        if totalDamage > maxDamage {
            if let squareBody = square.physicsBody,
                squareBody.allContactedBodies().contains(node.physicsBody!) {
                squareBody.velocity = CGVector(dx: squareBody.velocity.dx * -1, dy: squareBody.velocity.dy * -1)
            }
            node.removeFromParent()
            switch node.name {
            case "enemy":
                let particle = blood.copy() as! SKEmitterNode
                particle.position = node.position
                addChild(particle)
                particle.run( SKAction.group( [SKAction.sequence([SKAction.wait(forDuration: 0.25),
                                                                  SKAction.removeFromParent()]),
                                               SKAction.fadeOut(withDuration: 0.25)]))
            case "glass":
                let particle = emitter.copy() as! SKEmitterNode
                particle.position = node.position
                addChild(particle)
                particle.run( SKAction.group( [SKAction.sequence([SKAction.wait(forDuration: 0.25),
                                                                  SKAction.removeFromParent()]),
                                               SKAction.fadeOut(withDuration: 0.25)]))
            default:
                break
            }
        }
    }
    private func resetSquare() {
        square.removeFromParent()
        square = squareCopy.copy() as! SKSpriteNode
        addChild(square)
        launchTime = nil
    }
    private func clamp(translation: CGPoint) -> CGVector {
        var translation = translation
        translation.y *= -1
        translation.x = min(translation.x, 0)
        let theta = atan2(translation.y, translation.x)
        let magnitude = min(hypot(translation.x, translation.y), 150)
        return CGVector(dx: magnitude * cos(theta), dy: magnitude * sin(theta))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard state == .animating else {
            return
        }
        [contact.bodyA, contact.bodyB].compactMap{ $0.node as? SKSpriteNode}
                                      .filter { $0.userData?["damage"] is CGFloat }
                                      .forEach { damagedNodes[$0, default: 0] += contact.collisionImpulse }
    }
}

