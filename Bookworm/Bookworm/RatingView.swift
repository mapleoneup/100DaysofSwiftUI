//
//  RatingView.swift
//  Bookworm
//
//  Created by Alex Nguyen on 2023-06-28.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var spaceBetween = 10.0
    
    var label = ""
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColour = Color.gray
    var onColour = Color.yellow
    
    var body: some View {
        HStack(spacing: spaceBetween) {
            if label.isEmpty == false {
                Text(label)
            }
            
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > rating ? offColour : onColour)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: .constant(4))
    }
}
