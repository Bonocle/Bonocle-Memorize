//
//  Grid.swift
//  Memorize
//
//  Created by Mahmoud ELDemery on 24/08/2022.
//

import SwiftUI

struct Grid<Item,ItemView>: View where Item: Identifiable, ItemView: View {
    var items: [Item]
    var viewForItem: (Item) -> ItemView
    
    init(_ items: [Item], _ viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            let layout =  GridLayout(itemCount: items.count, in: geometry.size)
            
            ForEach(items) { item in
                viewForItem(item)
                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
                    .position(layout.location(ofItemAt: items.firstIndex(where: { item.id == $0.id })! ))
            }
        }
    }
}
