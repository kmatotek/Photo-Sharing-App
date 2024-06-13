//
//  Create Account.swift
//  Photo Sharing
//
//  Created by Kadin Matotek on 5/30/24.
//

import SwiftUI

enum AlertType {
    case passwordsDoNotMatch
    case emptyUsername
    case emptyPassword
}

struct Create_Account: View {
    @State private var username = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var AccountCreated = false
    @State private var showAlert = false
    @State private var alertType: AlertType?
    
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
                
                VStack {
                    Text("Create Account")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    TextField("Username", text: $username)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .border(.gray, width: CGFloat(2))
                        .cornerRadius(3)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .border(.gray, width: CGFloat(2))
                        .cornerRadius(3)
                    
                    SecureField("Repeat Password", text: $password2)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .border(.gray, width: CGFloat(2))
                        .cornerRadius(3)
                    
                    Button("Create Account") {
                        // Simulate authentication for example purposes
                        if username.isEmpty {
                            alertType = .emptyUsername

                            showAlert = true
                        }
                        else if password.isEmpty {
                            alertType = .emptyPassword
                            showAlert = true
                        }
                        else if password != password2{
                            alertType = .passwordsDoNotMatch
                            showAlert = true
                        } else {
                            // Handle wrong credentials
                            AccountCreated = true
                            
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.indigo)
                    .cornerRadius(10)
                }
            }
            .navigationDestination(isPresented: $AccountCreated){
                ContentView()
            }
            .alert(isPresented: $showAlert){
                switch alertType {
                case .passwordsDoNotMatch:
                    return Alert(
                        title: Text("Error"),
                        message: Text("Passwords Don't Match"),
                        dismissButton: .default(Text("Try Again"))
                    )
                case .emptyUsername:
                    return Alert(
                        title: Text("Error"),
                        message: Text("Empty Username"),
                        dismissButton: .default(Text("Try Again"))
                    )
                case .emptyPassword:
                    return Alert(
                        title: Text("Error"),
                        message: Text("Empty Password"),
                        dismissButton: .default(Text("Try Again"))
                    )
                case .none:
                    return Alert(
                        title: Text("Error"),
                        message: Text("Unknown Error"),
                        dismissButton: .default(Text("Try Again"))
                    )
                }
            }
        }
    }
}

#Preview {
    Create_Account()
}
