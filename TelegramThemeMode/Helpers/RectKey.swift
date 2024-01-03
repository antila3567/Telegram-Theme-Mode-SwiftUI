//
//  RectKey.swift
//  TelegramThemeMode
//
//  Created by Иван Легенький on 03.01.2024.
//

import SwiftUI

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
