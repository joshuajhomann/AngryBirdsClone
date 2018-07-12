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
    private var player: SKSpriteNode!
    private var playerCopy: SKSpriteNode!
    private var state =  //TODO: add state
    private var launchTime: TimeInterval!
    private var damagedNodes: [SKSpriteNode: CGFloat] = [:]
    private var emitter: SKEmitterNode!
    private var blood: SKEmitterNode!
    // MARK: - Constants
    private enum GameState {
        //TODO: Add in game states
    }
    private let labelAttributes: [NSAttributedStringKey: Any] = [.font: UIFont(name: "ChalkboardSE-Regular", size: 60)!,
                                                                 .foregroundColor: UIColor.white,
                                                                 .strokeColor: UIColor.black,
                                                                 .strokeWidth: -2]
    private let cameraNode = SKCameraNode()
    // MARK: - SKView
    override func didMove(to view: SKView) {
        //TODO: grab asset references
        //TODO: grab asset references
        //TODO: setup camera
        //TODO: add gesture recognizers
        //TODO: add physics delegate
    }
    override func update(_ currentTime: TimeInterval) {
        //TODO: check if we are animatings
        //TODO: apply damage
        //TODO: update camera
        //TODO: update launch time
        //TODO: reset player and camera
    }
    //MARK: - Instance
    @objc private func doubleTap(_ recognizer: UITapGestureRecognizer) {
        //TODO: center camera and reset scale
    }
    @objc private func pinch(_ recognizer: UIPinchGestureRecognizer) {
        //TODO: set camera scale
    }
    @objc private func pan(_ recognizer: UIPanGestureRecognizer) {
        //TODO: handle panning and dragging
    }
    private func apply(_ collisionDamage: CGFloat, to node: SKSpriteNode) {
        //TODO: spawn text
        //TODO: apple image for enemy damage
        //TODO: removeNodes where damage exceeds maxdamage
        //TODO: spawn shatter particles
        //TODO: spawn blood particles
    }
    private func resetPlayer() {
        //TODO: reset player and launch time
    }
    private func clamp(translation: CGPoint) -> CGVector {
        //TODO: convert translation
        //TODO: clamp X to Q2, Q3
        //TODO: clamp magnitude
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        //TODO: accumulate damaged nodes
    }
}

