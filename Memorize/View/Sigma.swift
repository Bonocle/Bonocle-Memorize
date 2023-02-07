//
//  Sigma.swift
//  Memorize
//
//  Created by Mahmoud ELDemery on 01/02/2023.
//

import Foundation
import SwiftUI

public struct SigmaView: View {
    public var body: some View {
        ZStack {
            ZStack {
                Image("image 310")
                Image("image 309")
                Image("image 308")
            }
            .position(x: 180, y: 219.5)
            VStack(alignment: .leading, spacing: 0) {
            }
            .padding(.horizontal, 16)
            .position(x: 180, y: 422.5)
            HStack(alignment: .top, spacing: 10) {
                Text("Welcome, Regina")
                    .font(.custom("Noto Sans Arabic UI", size: 28))
                    .foregroundColor(Color(red: 1, green: 1, blue: 1))
            }
            .padding([.horizontal, .bottom], 16)
            .position(x: 180, y: 82)
            HStack(alignment: .center, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text("2,500 points")
                        .font(.custom("Noto Sans Arabic UI", size: 14))
                        .foregroundColor(.black)
                }
            }
            .padding([.horizontal, .bottom], 16)
            .position(x: 180, y: 128)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                    }
                    .padding([.horizontal, .bottom], 16)
                }
                .frame(width: 360, alignment: .topLeading)
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                    }
                    .padding([.horizontal, .bottom], 16)
                }
                VStack(alignment: .leading, spacing: 10) {
                }
                .padding(.all, 16)
            }
            .position(x: 180, y: 807)
        }
        .background(Color(red: 1, green: 1, blue: 1))
    }
}

struct SigmaView_Previews: PreviewProvider {
    static var previews: some View {
        SigmaView()
    }
}
