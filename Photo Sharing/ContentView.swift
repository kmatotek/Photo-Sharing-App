//
//  ContentView.swift
//  Photo Sharing
//
//  Created by Kadin Matotek on 5/27/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        ZStack {
            Color(.brown)
                .ignoresSafeArea()
            VStack {
                Image("poopyDoop")
                    .resizable()
                    .cornerRadius(30)
                    .aspectRatio(contentMode: .fit)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                Text("My Lockcreen!")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
        }
    }
}

#Preview {
   ContentView()
}
