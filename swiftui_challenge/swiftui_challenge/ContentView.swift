//
//  ContentView.swift
//  swiftui_challenge
//
//  Created by dolphilia on 2022/04/25.
//

import SwiftUI

struct ContentView: View {
    @State var buttonText = "Button"
    var body: some View {

        Button(action: {
            buttonText = "Button Tapped"
        }){
            Text(buttonText)
               .font(.largeTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
