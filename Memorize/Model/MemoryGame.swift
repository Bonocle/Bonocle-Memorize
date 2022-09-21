//
//  MemoryGame.swift
//  Memorize
//
//  Created by Mahmoud ELDemery on 24/08/2022.

import Foundation

struct MemoryGame<CardContent: Equatable> {
    private(set) var cards: [Card] = [Card]()
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            
            cards.append(Card(content: content))
            cards.append(Card(content: content))
        }
        cards.shuffle()
    }
    
    
    
    private var indexOfOneAndOnlyCard: Int?
    
    mutating func highlight(card: Card) {
        
        for (index,crd) in cards.enumerated() {
            if crd.id == card.id {
                cards[index].isHighlited = true
            } else {
                cards[index].isHighlited = false
            }
        }
    }
    
    mutating func choose(card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if !cards[chosenIndex].isFaceUp && !cards[chosenIndex].isMatched {
            
            if indexOfOneAndOnlyCard == nil {
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                indexOfOneAndOnlyCard = chosenIndex
            } else {
                if cards[indexOfOneAndOnlyCard!].content == cards[chosenIndex].content {
                    cards[indexOfOneAndOnlyCard!].isMatched = true
                    cards[chosenIndex].isMatched = true
                }
                indexOfOneAndOnlyCard = nil
            }
            cards[chosenIndex].isFaceUp.toggle()
        }
    }
    
    
    
    struct Card: Identifiable {
        var id = UUID()
        var content: CardContent
        
                
        var isHighlited: Bool = false {
            didSet {
                if isHighlited {
                    isHighlited = true
                } else {
                    isHighlited = false
                }
            }
        }
        
        var isFaceUp: Bool = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        
        var isMatched: Bool = false {
            didSet {
                if isMatched {
                    stopUsingBonusTime()
                }
            }
        }
    
        
        
        
        var bonusTimeLimit: TimeInterval = 6
        
        private var faceUpTime: TimeInterval {
            if let lastFaceUpdate = lastFaceUpdate {
                return pastFaceUpdate + Date().timeIntervalSince(lastFaceUpdate)
            } else {
                return pastFaceUpdate
            }
        }
        
        var lastFaceUpdate: Date?
        
        var pastFaceUpdate: TimeInterval = 0
        
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpdate == nil {
                lastFaceUpdate = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            pastFaceUpdate = faceUpTime
            lastFaceUpdate = nil
        }
    }
}
