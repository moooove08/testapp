//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRequestPause(_ scene: GameScene)
    func gameSceneDidRequestExitToMenu(_ scene: GameScene)
    func gameSceneDidRequestReplay(_ scene: GameScene)
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Z Positions
    private enum Z {
        static let background: CGFloat = 0
        static let dimOverlay: CGFloat = 90
        static let confetti: CGFloat = 95
        static let ui: CGFloat = 100
        static let dragged: CGFloat = 200
    }

    // MARK: - Nodes
    private let background = SKSpriteNode(imageNamed: "backgroundmain")
    private let pauseButton = SKSpriteNode(imageNamed: "pause")
    private let restartButton = SKSpriteNode(imageNamed: "restart")

    private let character = CharacterNode()
    private var targets: [TargetNode] = []
    private var foods: [FoodNode] = []

    // MARK: - State
    private var activeDrag: FoodNode?
    private var levelCompleted: Bool = false

    // MARK: - Win UI Nodes
    private var dimNode: SKSpriteNode?
    private var continueButton: SKNode?
    private var replayButton: SKNode?
    private var winBackground: SKSpriteNode?
    private var winCat: SKSpriteNode?
    private var confettiNode: SKEmitterNode?

    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .black

        GameSoundPlayer.shared.preload(fileNames: ["cor.wav", "fail.wav"])

        setupBackground()
        setupPauseButton()
        setupCharacter()
        createLevel()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutForCurrentSize()
    }

    private func setupBackground() {
        background.zPosition = Z.background
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        layoutBackground()
    }

    private func layoutBackground() {
        background.position = .zero
        background.size = size
    }

    private func setupPauseButton() {
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = Z.ui
        pauseButton.setScale(1.0)
        addChild(pauseButton)

        restartButton.name = "restartButton"
        restartButton.zPosition = Z.ui
        restartButton.setScale(1.0)
        addChild(restartButton)

        layoutPauseButton()
    }

    private func layoutPauseButton() {
        let margin = max(16.0, size.width * 0.04)
        let safeTop = (view?.safeAreaInsets.top ?? 0)
        let topY = size.height / 2 - margin - CGFloat(safeTop) * 0.5
        let leftX = -size.width / 2 + margin
        let rightX = size.width / 2 - margin

        pauseButton.size = CGSize(width: 50, height: 50)
        pauseButton.position = CGPoint(x: leftX + pauseButton.size.width / 2, y: topY - pauseButton.size.height / 2)

        restartButton.size = pauseButton.size
        restartButton.position = CGPoint(x: rightX - restartButton.size.width / 2, y: topY - restartButton.size.height / 2)
    }

    private func setupCharacter() {
        character.zPosition = Z.ui
        addChild(character)
        layoutCharacter()
        character.setState(.idle)
        character.startIdleEyeMovement()
    }

    private func layoutCharacter() {
       
        character.setSize(size)
        character.position = .zero
    }

    // MARK: - Level
    private func createLevel() {
        levelCompleted = false
        activeDrag = nil
        pauseButton.isHidden = false
        restartButton.isHidden = false
        character.isHidden = false
        character.setState(.idle)
        character.setEyesHidden(false)
        character.resetEyes()
        character.startIdleEyeMovement()
        removeWinOverlayIfNeeded()

        targets.forEach { $0.removeFromParent() }
        foods.forEach { $0.removeFromParent() }
        targets.removeAll()
        foods.removeAll()

        let correct = Array(FruitType.allCases.shuffled().prefix(3))
        let incorrectPool = FruitType.allCases.filter { !correct.contains($0) }.shuffled()
        let incorrect = Array(incorrectPool.prefix(2))
        let bottomTypes = (correct + incorrect).shuffled()

        setupTargets(types: correct)
        setupFoods(types: bottomTypes)
        layoutForCurrentSize()
    }

    private func setupTargets(types: [FruitType]) {
        let base = min(size.width, size.height)
        targets = types.enumerated().map { index, type in
            let multiplier: CGFloat = 0.27
            let slotSize = CGSize(width: base * multiplier, height: base * multiplier)
            return TargetNode(expectedType: type, size: slotSize)
        }
        for t in targets {
            t.zPosition = Z.ui
            addChild(t)
        }
    }

    private func setupFoods(types: [FruitType]) {
        let w = min(size.width, size.height) * 0.22
        let itemSize = CGSize(width: w, height: w)
        foods = types.map { FoodNode(type: $0, size: itemSize) }
        for f in foods {
            f.zPosition = Z.ui
            addChild(f)
        }
    }

    private func layoutForCurrentSize() {
        layoutBackground()
        layoutPauseButton()
        layoutCharacter()
        layoutTargets()
        layoutFoods()
        layoutWinOverlayIfNeeded()
    }

    private func layoutTargets() {
        guard !targets.isEmpty else { return }
        let topBandY = size.height * 0.32
        let spacing = min(size.width * 0.06, 34)
        let totalW = targets.reduce(0) { $0 + $1.size.width } + spacing * CGFloat(max(0, targets.count - 1))
        var x = -totalW / 2
        for (index, t) in targets.enumerated() {
            x += t.size.width / 2
            let yOffset: CGFloat = index == 1 ? size.height * 0.055 : 0
            t.position = CGPoint(x: x, y: topBandY + yOffset)
            x += t.size.width / 2 + spacing
        }
    }

    private func layoutFoods() {
        guard !foods.isEmpty else { return }
        let topRowY = -size.height * 0.29
        let bottomRowY = -size.height * 0.40
        let topRow = Array(foods.prefix(2))
        let bottomRow = Array(foods.dropFirst(2))

        func layoutRow(_ nodes: [FoodNode], at y: CGFloat, spacingFactor: CGFloat) {
            guard let first = nodes.first else { return }
            let spacing = min(size.width * spacingFactor, 24)
            let totalW = nodes.reduce(0) { $0 + $1.size.width } + spacing * CGFloat(max(0, nodes.count - 1))
            var x = -totalW / 2 + first.size.width / 2
            for f in nodes {
                f.position = CGPoint(x: x, y: y)
                f.homePosition = f.position
                x += f.size.width + spacing
            }
        }

        layoutRow(topRow, at: topRowY, spacingFactor: 0.05)
        layoutRow(bottomRow, at: bottomRowY, spacingFactor: 0.03)

        for f in foods where f.homePosition == .zero {
            f.homePosition = f.position
        }
    }

    // MARK: - Touch handling (Drag & Drop)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !levelCompleted else {
            handleWinUI(touches)
            return
        }
        guard activeDrag == nil, let touch = touches.first else { return }
        let p = touch.location(in: self)

        if pauseButton.contains(p) {
            gameDelegate?.gameSceneDidRequestPause(self)
            return
        }

        if restartButton.contains(p) {
            gameDelegate?.gameSceneDidRequestReplay(self)
            return
        }

        if let food = foods.first(where: { !$0.isLocked && $0.contains(p) }) {
            activeDrag = food
            food.zPosition = Z.dragged
            food.removeAllActions()
            character.stopIdleEyeMovement()
            character.trackEyes(toward: food.position, in: self)

            let scale = SKAction.scale(to: 1.08, duration: 0.12)
            scale.timingMode = .easeOut
            food.run(scale, withKey: "scaleUp")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let drag = activeDrag, let touch = touches.first else { return }
        let p = touch.location(in: self)
        drag.position = p
        character.trackEyes(toward: p, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finalizeDrag()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finalizeDrag()
    }

    private func finalizeDrag() {
        guard let drag = activeDrag else { return }
        activeDrag = nil

        let droppedType = drag.fruitType
        let hitTarget = targets.first(where: { !$0.isFilled && drag.frame.intersects($0.frame) })

        if let target = hitTarget, target.expectedType == droppedType {
            playSoundIfEnabled(named: "cor.wav")
            target.fill()
            drag.isLocked = true
            character.playExpression(.happy, duration: 2.0)

            // ALWAYS animate back to home, then remove and disable.
            let move = SKAction.move(to: drag.homePosition, duration: 0.22)
            move.timingMode = .easeInEaseOut
            let scale = SKAction.scale(to: 1.0, duration: 0.18)
            scale.timingMode = .easeInEaseOut
            drag.run(.group([move, scale])) { [weak self, weak drag] in
                guard let self, let drag else { return }
                drag.removeFromParent()
                self.foods.removeAll { $0 === drag }
                self.checkWin()
            }
        } else {
            playSoundIfEnabled(named: "fail.wav")
            character.playExpression(.sad, duration: 2.0)
            let move = SKAction.move(to: drag.homePosition, duration: 0.26)
            move.timingMode = .easeInEaseOut
            let scale = SKAction.scale(to: 1.0, duration: 0.18)
            scale.timingMode = .easeInEaseOut
            drag.run(.group([move, scale]))
        }

        drag.zPosition = Z.ui
        character.resetEyes()
        character.startIdleEyeMovement()
    }

    private func checkWin() {
        guard targets.allSatisfy({ $0.isFilled }) else { return }
        levelCompleted = true
        clearGameplayBeforeWin()
        showWinOverlay()
    }

    // MARK: - Win UI
    private func showWinOverlay() {
        let bg = SKSpriteNode(imageNamed: "backgroundmain")
        bg.zPosition = Z.dimOverlay
        bg.position = .zero
        bg.size = size
        addChild(bg)
        winBackground = bg

        let dim = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.38), size: size)
        dim.zPosition = Z.dimOverlay + 1
        dim.position = .zero
        dim.name = "dimOverlay"
        addChild(dim)
        dimNode = dim

        let cat = SKSpriteNode(imageNamed: "catwin")
        cat.zPosition = Z.dimOverlay + 2
        cat.position = .zero
        cat.size = size
        addChild(cat)
        winCat = cat

        let homeButton = makeIconButton(imageNamed: "home", name: "continueButton")
        homeButton.zPosition = Z.ui
        addChild(homeButton)
        continueButton = homeButton

        let replayBtn = makeIconButton(imageNamed: "restart", name: "replayButton")
        replayBtn.zPosition = Z.ui
        addChild(replayBtn)
        replayButton = replayBtn

        let confetti = makeConfettiEmitter()
        addChild(confetti)
        confettiNode = confetti

        layoutWinOverlayIfNeeded()
    }

    private func removeWinOverlayIfNeeded() {
        dimNode?.removeFromParent()
        winBackground?.removeFromParent()
        winCat?.removeFromParent()
        continueButton?.removeFromParent()
        replayButton?.removeFromParent()
        confettiNode?.removeFromParent()
        dimNode = nil
        winBackground = nil
        winCat = nil
        continueButton = nil
        replayButton = nil
        confettiNode = nil
    }

    private func clearGameplayBeforeWin() {
        activeDrag?.removeAllActions()
        activeDrag = nil

        pauseButton.isHidden = true
        restartButton.isHidden = true
        character.removeAllActions()
        character.isHidden = true

        targets.forEach { $0.removeFromParent() }
        foods.forEach { $0.removeFromParent() }
        targets.removeAll()
        foods.removeAll()
    }

    private func layoutWinOverlayIfNeeded() {
        guard let dimNode else { return }
        dimNode.size = size
        dimNode.position = .zero
        winBackground?.size = size
        winBackground?.position = .zero
        winCat?.size = size
        winCat?.position = .zero
        confettiNode?.position = CGPoint(x: 0, y: size.height / 2 + 10)
        confettiNode?.particlePositionRange = CGVector(dx: size.width, dy: 0)

        let buttonInset: CGFloat = 50
        let buttonSize: CGFloat = 88
        let y = -size.height / 2 + buttonInset + buttonSize / 2
        continueButton?.position = CGPoint(x: -60, y: y)
        replayButton?.position = CGPoint(x: 60, y: y)

        // Center buttons on small screens
        if size.width < 360 {
            continueButton?.position = CGPoint(x: 0, y: y + 42)
            replayButton?.position = CGPoint(x: 0, y: y - 42)
        }
    }

    private func handleWinUI(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)
        let nodes = nodes(at: p)
        if nodes.contains(where: { $0.name == "continueButton" }) {
            gameDelegate?.gameSceneDidRequestExitToMenu(self)
        } else if nodes.contains(where: { $0.name == "replayButton" }) {
            gameDelegate?.gameSceneDidRequestReplay(self)
        }
    }

    private func makeIconButton(imageNamed: String, name: String) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: imageNamed)
        node.name = name
        node.size = CGSize(width: 88, height: 88)
        return node
    }

    private func makeConfettiEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.zPosition = Z.confetti
        emitter.particleTexture = makeConfettiTexture()
        emitter.particleBirthRate = 38
        emitter.numParticlesToEmit = 220
        emitter.particleLifetime = 5.2
        emitter.particleLifetimeRange = 1.4
        emitter.particleSpeed = 210
        emitter.particleSpeedRange = 90
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 3
        emitter.yAcceleration = -180
        emitter.xAcceleration = 14
        emitter.particleAlpha = 0.95
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.16
        emitter.particleScale = 0.34
        emitter.particleScaleRange = 0.18
        emitter.particleScaleSpeed = -0.03
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 3.2
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.position = CGPoint(x: 0, y: size.height / 2 + 10)

        let colors: [UIColor] = [
            UIColor.systemYellow,
            UIColor.systemPink,
            UIColor.systemGreen,
            UIColor.systemBlue,
            UIColor.systemOrange
        ]
        emitter.particleColor = colors.randomElement() ?? .white

        let cycle = SKAction.repeatForever(.sequence([
            .run { [weak emitter] in
                let colors: [UIColor] = [
                    UIColor.systemYellow,
                    UIColor.systemPink,
                    UIColor.systemGreen,
                    UIColor.systemBlue,
                    UIColor.systemOrange
                ]
                emitter?.particleColor = colors.randomElement() ?? .white
            },
            .wait(forDuration: 0.08)
        ]))
        emitter.run(cycle, withKey: "confettiColors")

        return emitter
    }

    private func makeConfettiTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 14))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 10, height: 14))
        }
        return SKTexture(image: image)
    }

    private func playSoundIfEnabled(named fileName: String) {
        GameSoundPlayer.shared.play(fileName)
    }
}
