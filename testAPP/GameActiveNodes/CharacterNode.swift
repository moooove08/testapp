//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import SpriteKit

let scaleX = UIScreen.main.bounds.size.width / 430
let scaleY = UIScreen.main.bounds.size.height / 932

final class CharacterNode: SKNode {
    // MARK: - Public
    enum State {
        case idle
        case happy
        case sad
        case win
    }

    // MARK: - Nodes
    private let body = SKSpriteNode()
    private let eyeBase = SKSpriteNode(imageNamed: "eyebase")
    private let eyes = SKSpriteNode(imageNamed: "eyes")
    private let eyebrows = SKSpriteNode(imageNamed: "eyebrows")

    // MARK: - Actions / State
    private var eyeIdleActionKey = "eyeIdle"
    private var eyeTrackActionKey = "eyeTrack"

    private var baseEyePos: CGPoint = .zero
    private var baseBrowPos: CGPoint = .zero
    private var expressionResetKey = "expressionReset"

    override init() {
        super.init()

        body.texture = SKTexture(imageNamed: "basecatforanim")
        body.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(body)

        eyeBase.zPosition = 10
        eyes.zPosition = 11
        eyebrows.zPosition = 12
        addChild(eyeBase)
        addChild(eyes)
        addChild(eyebrows)

        let ref = SKSpriteNode(imageNamed: "basecatforanim")
        ref.alpha = 0.0
        ref.zPosition = -1
        addChild(ref)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSize(_ size: CGSize) {
        body.size = size

        let s = min(size.width, size.height)
        let eyeW = s * 0.39
        eyeBase.size = CGSize(width: eyeW, height: eyeW * 0.55)
        eyes.size = eyeBase.size
        eyebrows.size = CGSize(width: eyeW, height: eyeW * 0.55)

        let centerY = size.height * 0.08
        baseEyePos = CGPoint(x: 0, y: centerY + 10 * scaleY)
        baseBrowPos = CGPoint(x: 2 * scaleX, y: centerY + 11 * scaleY)

        eyeBase.position = baseEyePos
        eyes.position = baseEyePos
        eyebrows.position = baseBrowPos
    }

    func setState(_ state: State) {
        switch state {
        case .idle:
            body.texture = SKTexture(imageNamed: "basecatforanim")
        case .happy:
            body.texture = SKTexture(imageNamed: "catglad")
        case .sad:
            body.texture = SKTexture(imageNamed: "catsad")
        case .win:
            body.texture = SKTexture(imageNamed: "catwin")
        }
    }

    func setEyesHidden(_ hidden: Bool) {
        eyeBase.isHidden = hidden
        eyes.isHidden = hidden
        eyebrows.isHidden = hidden
    }

    func startIdleEyeMovement() {
        removeAction(forKey: eyeTrackActionKey)
        removeAction(forKey: eyeIdleActionKey)
        scheduleIdleWander()
    }

    func stopIdleEyeMovement() {
        removeAction(forKey: eyeIdleActionKey)
    }

    private func scheduleIdleWander() {
        let wait = SKAction.wait(forDuration: Double.random(in: 2.0...4.0))
        let step = SKAction.run { [weak self] in
            guard let self else { return }
            self.wanderEyesOnce()
            self.scheduleIdleWander()
        }
        run(.sequence([wait, step]), withKey: eyeIdleActionKey)
    }

    private func wanderEyesOnce() {
        let dx = CGFloat.random(in: -7...7)
        let dy = CGFloat.random(in: -3...3)
        let move = SKAction.move(to: CGPoint(x: baseEyePos.x + dx, y: baseEyePos.y + dy), duration: 0.35)
        move.timingMode = .easeInEaseOut
        eyes.run(move)
    }

    func trackEyes(toward scenePoint: CGPoint, in scene: SKScene) {
        removeAction(forKey: eyeTrackActionKey)

        let local = convert(scenePoint, from: scene)
        let maxX = body.size.width * 0.01
        let maxY = body.size.height * 0.006
        let targetX = max(-maxX, min(maxX, local.x * 0.08))
        let targetY = baseEyePos.y + max(-maxY, min(maxY, local.y * 0.06))

        let move = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: 0.12)
        move.timingMode = .easeOut
        eyes.run(move)
    }

    func resetEyes() {
        removeAction(forKey: eyeTrackActionKey)
        let move = SKAction.move(to: baseEyePos, duration: 0.18)
        move.timingMode = .easeInEaseOut
        eyes.run(move)
    }

    func playExpression(_ state: State, duration: TimeInterval) {
        removeAction(forKey: expressionResetKey)
        stopIdleEyeMovement()
        setEyesHidden(true)
        setState(state)

        let wait = SKAction.wait(forDuration: duration)
        let restore = SKAction.run { [weak self] in
            guard let self else { return }
            self.setState(.idle)
            self.setEyesHidden(false)
            self.resetEyes()
            self.startIdleEyeMovement()
        }
        run(.sequence([wait, restore]), withKey: expressionResetKey)
    }

    func forceWin() {
        removeAction(forKey: expressionResetKey)
        removeAction(forKey: eyeTrackActionKey)
        stopIdleEyeMovement()
        setEyesHidden(true)
        setState(.win)
    }
}

