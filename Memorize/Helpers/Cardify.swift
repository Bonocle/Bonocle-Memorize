//
//  Cardify.swift
//  Memorize
//
//  Created by Mahmoud ELDemery on 24/08/2022.
//

import SwiftUI


struct Cardify: AnimatableModifier {
    var isFaceUp: Bool {
        rotation < 90
    }
    
    var isHighlited: Bool
    
    var rotation: Double
    
    let exampleColor : Color = Color(red: 0.5, green: 0.8, blue: 0.5)

    init(isFaceUp: Bool, isHighlited: Bool) {
        rotation = isFaceUp ? 0 : 180
        self.isHighlited = isHighlited
    }
    
    var animatableData: Double {
        get { return rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: lineWidth)
                content
            }
                .opacity(isFaceUp ? 1 : 0)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .opacity(isFaceUp ? 0 : 1)
        }
        .foregroundColor(isHighlited ? .green : .blue)
        .rotation3DEffect(.degrees(rotation), axis: (0,1,0))
    }
    
    private let cornerRadius: CGFloat = 10
    private let lineWidth: CGFloat = 3
}


extension View {
    func cardify(isFaceUp: Bool, isHighlited: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp, isHighlited: isHighlited))
    }
}
