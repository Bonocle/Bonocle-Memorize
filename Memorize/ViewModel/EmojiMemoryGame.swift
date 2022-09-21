//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Mahmoud ELDemery on 24/08/2022.

import SwiftUI
import BonocleKit
import CoreBluetooth

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
    @Published private var currentIndex = 0

    var peripheral: BonocleDevice? = nil
    let textToSpeechManager = TextToSpeechManager.sharedInstance

    init() {
        BonocleCommunicationHelper.shared.setOpticalSubscription(peripheral: nil, to: true)
        BonocleCommunicationHelper.shared.setIMUSubscription(peripheral: nil, to: false)

        BonocleCommunicationHelper.shared.deviceDelegate = self
        BonocleCommunicationHelper.shared.searchForBonocle()
    }

    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["🇶🇦", "🇪🇬", "🇸🇦", "🇦🇪", "🇰🇼", "🇸🇩", "🇧🇭", "🇴🇲"].shuffled()

        return MemoryGame<String>(numberOfPairsOfCards: Int.random(in: 2...5)) { index in
            return emojis[index]
        }
    }
    
    var cards: [MemoryGame<String>.Card] {
        return model.cards
    }
    
    
    // MARK: - Intents
    
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
    
    func resetGame() {
        model = EmojiMemoryGame.createMemoryGame()
    }
}


extension EmojiMemoryGame: BonocleDelegate {
    
    func rightAction() {
        let index = currentIndex + 1
        
        
        if index >= 0, index < model.cards.count {
            currentIndex += 1
            model.highlight(card: model.cards[currentIndex])
        } else {
            // reached right edge
        }
        
        
    }
    
    func leftAction() {
        let index = currentIndex - 1

        if index >= 0, index < model.cards.count {
            currentIndex -= 1
            model.highlight(card: model.cards[currentIndex])
       

//            choose(card: card)
        } else {
            // reached left edge
        }
    }
    
    func downAction() {
        let index = currentIndex + 2
        
        if index >= 0, index < model.cards.count {
            currentIndex += 2
            model.highlight(card: model.cards[currentIndex])

//            choose(card: card)
        } else {
            // reached left edge
        }
    }
    
    func upAction() {
        let index = currentIndex - 2
        if index >= 0, index < model.cards.count {
            currentIndex -= 2
            model.highlight(card: model.cards[currentIndex])
//            choose(card: card)
        } else {
            // reached left edge
        }
    }
    
    
    func deviceDidDisconnect(peripheral: BonocleDevice) {
        self.peripheral = nil
    }
    
    func deviceDidConnect(peripheral: BonocleDevice) {
        self.peripheral = peripheral
    }
    
    func foundDevices(peripherals: [BonocleDevice]) {
        if peripherals.count > 0 {
            for peripheral in peripherals {
                    self.peripheral = peripheral
                    BonocleCommunicationHelper.shared.connectToDevice(device: (self.peripheral?.peripheral)!)
            }
                
        }
    }
    
    func opticalEvent(peripheral: BonocleDevice, x: Int, y: Int) {
        self.peripheral = peripheral
        if y > 0 {
            upAction()
        }
        if y < 0 {
            downAction()

        }
        if x > 0 {
            rightAction()

        }
        if x < 0 {
            leftAction()
        }
        BonocleCommunicationHelper.shared.vibrate(peripheral: self.peripheral!, hapticMotor: .both, with: .nudge)
    }
    
    func buttonEvent(peripheral: BonocleDevice, button: Buttons, event: ButtonEvents) {
        self.peripheral = peripheral
        
        switch event {
        case .singleClick:
            switch button {
            case .middle:
                if currentIndex >= 0, currentIndex < model.cards.count {
                    let card = model.cards[currentIndex]
                    choose(card: card)
                }
            default: break
            }

        default:
            break
        }
    }

}
