import SwiftUI

struct LandingPage: View {
    @State private var isMainPagePresented = false

    var body: some View {
        NavigationView {
            VStack {
                Image("landing_background_image") // Replace with your landing page background image
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxHeight: .infinity)

                Spacer()

                Button(action: {
                    isMainPagePresented = true
                }) {
                    Text("Start Here")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black) // Customize the button color
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isMainPagePresented, content: {
                ContentView()
            })
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
}
