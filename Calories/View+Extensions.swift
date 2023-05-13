//
//  View+Extensions.swift
//  Calories
//
//  Created by Bill Gestrich on 9/5/20.
//  Copyright © 2020 Bill Gestrich. All rights reserved.
//

import SwiftUI

//https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
