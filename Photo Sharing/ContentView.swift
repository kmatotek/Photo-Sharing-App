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
                    .padding()
                Text("My Lockscreen!")
                    .font(.custom("Quicksand-Bold", size: 20))
                    .fontWeight(.bold)
                
                Spacer()
                
                // Integrate the BottomBarView using UIViewRepresentable
                BottomBarViewRepresentable()
                    .frame(height: 50)
                    .background(Color(red: 101/255.0, green: 77/255.0, blue: 117/255.0))
            }
        }
    }
}

struct BottomBarViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BottomBarView {
        return BottomBarView()
    }
    
    func updateUIView(_ uiView: BottomBarView, context: Context) {
        // Update UIView if needed
    }
}



#Preview {
    ContentView()
}
