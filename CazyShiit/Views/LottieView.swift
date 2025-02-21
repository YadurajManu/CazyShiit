import SwiftUI

struct LottieView: View {
    let name: String
    
    var body: some View {
        // Placeholder for Lottie animation
        // In a real app, this would use the Lottie framework
        Image(systemName: "heart.text.square.fill")
            .font(.system(size: 100))
            .foregroundColor(Color("AccentBlue"))
            .opacity(0.8)
    }
} 