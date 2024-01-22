
//
//  TypewriterView.swift
//  Moodify
//
//  Created by Chisom on 1/15/24.
//

import SwiftUI

struct TypeWriterView: View {
    
    // MARK: - Properties
    
    private let speed:TimeInterval
    @Binding var text:String
    @Binding var isStarted:Bool
    @State private var textArray:String = ""
    
    init(text: Binding<String>, speed: TimeInterval = 0.1, isStarted: Binding<Bool>) {
        self._text = text
        self.speed = speed
        self._isStarted = isStarted
    }
    
    // MARK: - Body
    
    var body: some View {
        
        
        Text(text.isEmpty ? "" : textArray)
            .onChange(of: isStarted) { _, _ in
                startAnimate()
            }
    }
}

// MARK: - TypeWriterView

extension TypeWriterView{
    
    // TODO: - startAnimate
    
    private func startAnimate(){
        DispatchQueue.global().async {
            let _ = text.map {
                Thread.sleep(forTimeInterval: speed)
                textArray += $0.description
            }
        }
    }
}
