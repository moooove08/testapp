//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import Foundation

enum FruitType: CaseIterable, Hashable {
    case apple
    case banana
    case kiwi
    case rasp
    case straw

    var buttonTextureName: String {
        switch self {
        case .apple: return "applebutton"
        case .banana: return "bananabutton"
        case .kiwi: return "kiwibutton"
        case .rasp: return "raspbutton"
        case .straw: return "strawbutton"
        }
    }

    var emptyTextureName: String {
        switch self {
        case .apple: return "appleempty"
        case .banana: return "bananaempty"
        case .kiwi: return "kiwiempty"
        case .rasp: return "raspempty"
        case .straw: return "strawempty"
        }
    }

    var fullTextureName: String {
        switch self {
        case .apple: return "applefull"
        case .banana: return "bananafull"
        case .kiwi: return "kiwifull"
        case .rasp: return "raspfull"
        case .straw: return "strawfull"
        }
    }
}

