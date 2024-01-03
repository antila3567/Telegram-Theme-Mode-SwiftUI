//
//  View+Extensions.swift
//  TelegramThemeMode
//
//  Created by Иван Легенький on 03.01.2024.
//

import SwiftUI

extension View {
    @ViewBuilder
    func rect(value: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader(content: { geometry in
                    let rect = geometry.frame(in: .global)
                    
                    Color.clear
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: { rect in
                            value(rect)
                        })
                })
            }
    }
    
    @MainActor
    @ViewBuilder
    func createImage(toggleDarkMode: Bool, currentImage: Binding<UIImage?>, previousImage: Binding<UIImage?>, activateDarkMode: Binding<Bool>) -> some View {
        self
            .onChange(of: toggleDarkMode) { oldValue, newValue in
                Task {
                    if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
                        $0.isKeyWindow
                    }) {
                        let imageView = UIImageView()
                        imageView.frame = window.frame
                        imageView.image = window.rootViewController?.view.image(window.frame.size)
                        imageView.contentMode = .scaleAspectFit
                        window.addSubview(imageView)
                        
                        if let rootView = window.rootViewController?.view {
                            //SNAPSHOW
                            let frameSize = rootView.frame.size
                            
                            activateDarkMode.wrappedValue = !newValue
                            previousImage.wrappedValue = rootView.image(frameSize)
                            
                            activateDarkMode.wrappedValue = newValue
                            
                            try await Task.sleep(for: .seconds(0.01))
                            currentImage.wrappedValue = rootView.image(frameSize)
                            
                            try await Task.sleep(for: .seconds(0.01))
                            imageView.removeFromSuperview()
                            
                            
                        }
                    }
                }
            }
    }
}

extension UIView {
    func image(_ size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            drawHierarchy(in: .init(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }
}
