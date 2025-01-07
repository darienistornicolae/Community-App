//
//  SwiftUIView.swift
//  Community
//
//  Created by Nik Dostov on 07/01/2025.
//

import SwiftUI

import SwiftUI

struct EventCardBody: View {
    
    let image: String
    let like_count: Int
    let comment_count: Int
    let view_count: Int
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .roundedCorner(20, corners: [.bottomLeft, .topRight, .bottomRight])
            
//            HStack {
//                HStack(spacing: 3) {
//                    Image(systemName: "heart")
//                    Text("\(like_count.formattedString())")
//                }
//                Spacer()
//                HStack {
//                    Image(systemName: "text.bubble")
//                    Text("\(comment_count.formattedString())")
//                }
//                Spacer()
//                HStack {
//                    Image(systemName: "eye")
//                    Text("\(view_count.formattedString())")
//                }
//                Spacer()
//                HStack {
//                    Image(systemName: "bookmark")
//                }
//            }
//            .font(.callout)
//            
//            Text(description)
//                .lineLimit(2)
//                .multilineTextAlignment(.leading)
//                .font(.callout)
//                .foregroundColor(.gray)
       }
//        .padding(.leading, 55)
    }
}


