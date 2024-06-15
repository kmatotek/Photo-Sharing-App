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
                    .font(.custom("Quicksand-Bold", size: 20))
                    .fontWeight(.bold)
            }
            
        }
    }
     /**
        init(){
            for familyName in UIFont.familyNames {
                print(familyName)
                
                for fontName in UIFont.fontNames(forFamilyName: familyName){
                    print("-- \(fontName)")
                }
                
            }
        }
    **/
    
}

#Preview {
   ContentView()
}
