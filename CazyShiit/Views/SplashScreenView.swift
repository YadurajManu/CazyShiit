import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.7
    @State private var opacity = 0.4
    @State private var showRings = false
    @State private var showSymbols = false
    @State private var rotationAngle: Double = 0
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    private let accentPurple = Color(red: 0.6, green: 0.2, blue: 0.988)
    
    private let medicalSymbols = ["heart.fill", "cross.case.fill", "staroflife.fill", "pills.fill"]
    
    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            mainColor.opacity(0.2),
                            .clear,
                            accentPurple.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Animated rings
                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(mainColor.opacity(0.2), lineWidth: 2)
                                .frame(width: 150 + CGFloat(i * 50),
                                       height: 150 + CGFloat(i * 50))
                                .scaleEffect(showRings ? 1 : 0.5)
                                .opacity(showRings ? 0.2 : 0)
                                .animation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                    value: showRings
                                )
                        }
                    }
                    
                    // Floating medical symbols
                    ZStack {
                        ForEach(0..<medicalSymbols.count, id: \.self) { index in
                            Image(systemName: medicalSymbols[index])
                                .font(.system(size: 24))
                                .foregroundColor(mainColor)
                                .offset(
                                    x: 100 * cos(2 * .pi * Double(index) / Double(medicalSymbols.count) + rotationAngle),
                                    y: 100 * sin(2 * .pi * Double(index) / Double(medicalSymbols.count) + rotationAngle)
                                )
                                .opacity(showSymbols ? 0.6 : 0)
                        }
                    }
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                    
                    // Main Logo
                    VStack(spacing: 10) {
                        // App Icon
                        ZStack {
                            Circle()
                                .fill(mainColor.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "stethoscope.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        
                        // App Name
                        HStack(spacing: 2) {
                            Text("AI")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(mainColor)
                            
                            Text("युष")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        
                        // Tagline
                        Text("Your Health, Our Priority")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .opacity(opacity)
                            .padding(.top, 8)
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                    
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        self.showRings = true
                    }
                    
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.showSymbols = true
                    }
                    
                    // Start rotating symbols
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        self.rotationAngle = 2 * .pi
                    }
                    
                    // Navigate to main app after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
} 