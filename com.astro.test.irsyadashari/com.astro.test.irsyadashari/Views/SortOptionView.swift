//
//  SortOptionView.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct SortOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .foregroundColor(isSelected ? .white : .primary)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor)
                    }
                }
        }
    }
}
