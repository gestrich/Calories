//
//  CalorieRowView.swift
//  Calories
//
//  Created by Bill Gestrich on 8/30/20.
//  Copyright © 2020 Bill Gestrich. All rights reserved.
//

import SwiftUI

struct CalorieRowView: View {
    
    let name: String
    let calories: Int
    let shouldShowAddButton: Bool
    
    var body: some View {
        HStack{
            Text("\(calories)")
                .frame(width:40, height: 30)
                .background(Color(ThemeKit.baseColor()))
                .clipShape(Ellipse())
                .foregroundColor(Color.white)
                .font(.footnote)
            Text(name)
            Spacer()
            if shouldShowAddButton {
                Image(systemName: "plus")
                    .font(.system(size: ThemeKit.plusButtonLength()))
                    .foregroundColor(Color(ThemeKit.buttonTextColor()))
            }
        }
    }
}


struct CalorieRowView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieRowView(name: "Test", calories: 100, shouldShowAddButton: true)
    }
}
