import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingAppScreen = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mint
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundStyle(.white)
                VStack {
                    Text("Login")
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

                    Button("Login") {
                        // Simulate authentication for example purposes
                        if username == "user" && password == "pass" {
                            showingAppScreen = true
                        } else {
                            // Handle wrong credentials
                            wrongUsername += 1
                            wrongPassword += 1
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.indigo)
                    .cornerRadius(10)
                
                }
            }
            .navigationDestination(isPresented: $showingAppScreen) {
                ContentView()
            }
        }
    }
}

#Preview {
    Login()
}
