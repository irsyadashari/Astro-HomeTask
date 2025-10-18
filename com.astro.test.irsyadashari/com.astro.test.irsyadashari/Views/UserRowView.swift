//
//  UserRowView.swift
//  com.astro.test.irsyadashari
//
//  Created by Muh Irsyad Ashari on 10/18/25.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    let onLikeTapped: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 44))
            }
            .frame(width: 44, height: 44)
            
            Text(user.login)
                .font(.body)
            
            Spacer()
        
            Button(action: onLikeTapped) {
                Image(systemName: user.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(user.isLiked ? .red : .gray)
            }
            .buttonStyle(.plain)
        }
    }
}
