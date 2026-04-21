//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import SpriteKit

final class TargetNode: SKSpriteNode {
    let expectedType: FruitType
    private(set) var isFilled: Bool = false

    init(expectedType: FruitType, size: CGSize) {
        self.expectedType = expectedType
        let texture = SKTexture(imageNamed: expectedType.emptyTextureName)
        super.init(texture: texture, color: .clear, size: size)
        name = "target_\(expectedType)"
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fill() {
        guard !isFilled else { return }
        isFilled = true
        texture = SKTexture(imageNamed: expectedType.fullTextureName)
        run(.sequence([
            .scale(to: 1.08, duration: 0.12),
            .scale(to: 1.0, duration: 0.12),
        ]))
    }
}

