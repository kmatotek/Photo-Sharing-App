//
//  FirstPageEver.swift
//  Photo Sharing
//
//  Created by Kadin Matotek on 5/30/24.
//

import SwiftUI

enum nextPage {
    case createAccount
    case Login
}

struct FirstPageEver: View {
    @State private var CreateOrLogin = false
    @State private var nextPage: nextPage?
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.mint
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundStyle(.white)
                
                VStack{
                    Text("Welcome")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    Button("Create Account") {
                        CreateOrLogin = true
                        nextPage = .createAccount
                    }
                        .foregroundStyle(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.indigo)
                        .cornerRadius(10)
                    
                    Button("Login") {
                        CreateOrLogin = true
                        nextPage = .Login
                    }
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.indigo)
                    .cornerRadius(10)
                }
            }
            .navigationDestination(isPresented: $CreateOrLogin){
                switch nextPage {
                case .createAccount:
                    Create_Account()
                case .Login:
                    Login()
                case .none:
                    FirstPageEver()
                }
            }
        }
    }
}

#Preview {
    FirstPageEver()
}
