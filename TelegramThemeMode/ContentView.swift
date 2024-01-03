//
//  ContentView.swift
//  TelegramThemeMode
//
//  Created by Иван Легенький on 03.01.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: Int = 0
    @State private var toggles: [Bool] = Array(repeating: false, count: 10)
    @AppStorage("toggleDarkMode") private var toggleDarkMode: Bool = false
    @AppStorage("activateDarkMode") private var activateDarkMode: Bool = false
    @State private var buttonRect: CGRect = .zero
    @State private var currentImage: UIImage?
    @State private var previousImage: UIImage?
    @State private var maskAnimation: Bool = false
    
    var body: some View {
        TabView(selection: $activeTab,
                content:  {
            NavigationStack {
                List {
                    Section("Text Section") {
                        Toggle("Large display", isOn: $toggles[0])
                        Toggle("Bold Text", isOn: $toggles[1])
                    }
                    
                    Section {
                        Toggle("Night Light", isOn: $toggles[2])
                        Toggle("True tone", isOn: $toggles[3])
                    } header: {
                        Text("Display section")
                    } footer: {
                        Text("Sample footer")
                    }
                }
                .navigationTitle("Dark Mode")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        })
        .createImage(
            toggleDarkMode: toggleDarkMode,
            currentImage: $currentImage,
            previousImage: $previousImage,
            activateDarkMode: $activateDarkMode
        )
        .overlay(content: {
            GeometryReader(content: { geometry in
                let size = geometry.size
                
                if let previousImage, let currentImage {
                    ZStack {
                        Image(uiImage: previousImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.width, height: size.height)
                        
                        Image(uiImage: currentImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.width, height: size.height)
                            .mask(alignment: .topLeading) {
                                Circle()
                                    .frame(width: buttonRect.width * (maskAnimation ? 80 : 1), height: buttonRect.height * (maskAnimation ? 80 : 1), alignment: .bottomLeading)
                                    .frame(width: buttonRect.width, height: buttonRect.height)
                                    .offset(x: buttonRect.minX, y: buttonRect.minY)
                                    .ignoresSafeArea()
                              
                            }
                    }
                    .task {
                        guard !maskAnimation else { return }
                        
                        withAnimation(.easeInOut(duration: 0.9), completionCriteria: .logicallyComplete) {
                            maskAnimation = true
                        } completion: {
                            self.currentImage = nil
                            self.previousImage = nil
                            maskAnimation = false
                        }
                        
                    }
                }
            })
            .mask({
                Rectangle()
                    .overlay(alignment: .topLeading) {
                        Circle()
                            .frame(width: buttonRect.width, height: buttonRect.height)
                            .offset(x: buttonRect.minX, y: buttonRect.minY)
                            .blendMode(.destinationOut)
                    }
            })
            .ignoresSafeArea()
        })
        .overlay(alignment: .topTrailing) {
            Button(action: {
                toggleDarkMode.toggle()
            }, label: {
                Image(systemName: toggleDarkMode ? "sun.max.fill" : "moon.fill")
                    .font(.title2)
                    .foregroundStyle(Color.primary)
                    .symbolEffect(.bounce, value: toggleDarkMode)
                    .frame(width: 40, height: 40)

            })
            .rect { rect in
                buttonRect = rect
            }
            .padding(10)
            .disabled(currentImage != nil || previousImage != nil || maskAnimation)
        }
        .preferredColorScheme(activateDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
