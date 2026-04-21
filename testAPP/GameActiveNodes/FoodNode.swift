//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import SpriteKit

final class FoodNode: SKSpriteNode {
    let fruitType: FruitType
    var homePosition: CGPoint = .zero
    var isLocked: Bool = false

    init(type: FruitType, size: CGSize) {
        self.fruitType = type
        let texture = SKTexture(imageNamed: type.buttonTextureName)
        super.init(texture: texture, color: .clear, size: size)
        isUserInteractionEnabled = false
        name = "food_\(type)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

