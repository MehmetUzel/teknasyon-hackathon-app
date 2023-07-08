//
//  Theme.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

struct AppTheme {
    static let backgroundColor: Color = Color("Background")
    static let textColor: Color = Color("TextColor")
    static let headerTextSize: Double = UIScreen.screenWidth*0.07
    static let bodyTextSize: Double = UIScreen.screenWidth*0.05

    
}
