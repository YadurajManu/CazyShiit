import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.7
    @State private var opacity = 0.3
    @State private var rotationAngle = 0.0
    @State private var showHeartbeat = false
    @State private var heartbeatOffset: CGFloat = 0
    @State private var particleSystem = ParticleSystem()
    @State private var glowOpacity = 0.0
    @State private var loadingProgress = 0.0
    @State private var dnaOffset: CGFloat = 0
    @State private var showDNA = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showParticles = false
    @State private var showRipple = false
    @State private var rippleScale: CGFloat = 0.5
    @State private var showShimmer = false
    @State private var shimmerOffset: CGFloat = -0.25
    
    // Colors
    let primaryColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    let tertiaryColor = Color(red: 0.6, green: 0.2, blue: 0.988)
    
    // Medical symbols for morphing
    let medicalSymbols = ["cross.fill", "heart.fill", "staroflife.fill", "pills.fill"]
    @State private var currentSymbolIndex = 0
    
    // Shimmer effect
    var shimmer: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                Color.white.opacity(0.2),
                .clear
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 100)
        .offset(x: shimmerOffset * UIScreen.main.bounds.width)
        .blur(radius: 5)
    }
    
    var body: some View {
        if isActive {
            OnboardingView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale),
                    removal: .opacity
                ))
        } else {
            ZStack {
                // Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        primaryColor.opacity(0.2),
                        Color(uiColor: .systemBackground)
                    ]),
                    center: .center,
                    startRadius: 2,
                    endRadius: 650
                )
                .ignoresSafeArea()
                
                // Enhanced DNA Animation with ripple effect
                if showDNA {
                    ZStack {
                        // Ripple circles
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(primaryColor.opacity(0.1))
                                .frame(width: 300 + CGFloat(index * 50))
                                .scaleEffect(showRipple ? 1.2 : 0.8)
                                .opacity(showRipple ? 0 : 0.5)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 2)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.4),
                                    value: showRipple
                                )
                        }
                        
                        DNAAnimation(offset: dnaOffset)
                            .opacity(0.3)
                    }
                }
                
                // Particle effect
                if showParticles {
                    ParticleEffectView(system: particleSystem)
                        .opacity(0.5)
                }
                
                VStack {
                    Spacer()
                    
                    // Logo container
                    ZStack {
                        // Glowing circles with blur effect
                        ForEach(0..<2) { index in
                            Circle()
                                .fill(index == 0 ? primaryColor : secondaryColor)
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)
                                .opacity(glowOpacity)
                                .offset(x: CGFloat(index * 20))
                        }
                        
                        // Rotating circles with gradient
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [primaryColor, secondaryColor, tertiaryColor],
                                        center: .center
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: CGFloat(140 + (index * 30)), height: CGFloat(140 + (index * 30)))
                                .rotationEffect(.degrees(rotationAngle + Double(index * 30)))
                        }
                        
                        // Pulse rings with multiple layers
                        ForEach(0..<2) { index in
                            Circle()
                                .stroke(primaryColor.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                                .frame(width: 180 + CGFloat(index * 20), height: 180 + CGFloat(index * 20))
                                .scaleEffect(pulseScale)
                        }
                        
                        // Main logo with glass effect
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                Text("AI")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(primaryColor)
                                
                                // Animated medical symbols with glow
                                ZStack {
                                    // Glow effect
                                    Image(systemName: medicalSymbols[currentSymbolIndex])
                                        .font(.system(size: 32))
                                        .foregroundColor(primaryColor)
                                        .blur(radius: 4)
                                        .opacity(0.5)
                                    
                                    // Main symbol
                                    Image(systemName: medicalSymbols[currentSymbolIndex])
                                        .font(.system(size: 30))
                                        .foregroundColor(primaryColor)
                                        .rotationEffect(.degrees(rotationAngle))
                                    
                                    // Pulse effect
                                    Circle()
                                        .stroke(primaryColor.opacity(0.5), lineWidth: 2)
                                        .frame(width: 50, height: 50)
                                        .scaleEffect(showHeartbeat ? 1.5 : 1.0)
                                        .opacity(showHeartbeat ? 0 : 1)
                                }
                            }
                            
                            Text("युष")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(24)
                        .background(
                            ZStack {
                                // Glassmorphism effect
                                Color(uiColor: .systemBackground)
                                    .opacity(0.8)
                                    .blur(radius: 10)
                                
                                // Subtle gradient overlay
                                LinearGradient(
                                    colors: [
                                        primaryColor.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                            .clipShape(Circle())
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            primaryColor.opacity(0.5),
                                            secondaryColor.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: primaryColor.opacity(0.3), radius: 20)
                        .scaleEffect(size)
                        .opacity(opacity)
                    }
                    
                    // Heartbeat line with gradient and glow
                    if showHeartbeat {
                        ZStack {
                            // Glow effect
                            HeartbeatLine()
                                .stroke(primaryColor, lineWidth: 6)
                                .blur(radius: 8)
                                .opacity(0.3)
                            
                            // Main line
                            HeartbeatLine()
                                .stroke(
                                    LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 3
                                )
                        }
                        .frame(width: 200, height: 50)
                        .offset(x: heartbeatOffset)
                    }
                    
                    Spacer()
                    
                    // Loading Progress with enhanced visuals
                    VStack(spacing: 12) {
                        // Progress bar with glow
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                
                                // Glowing progress
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [primaryColor, secondaryColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * loadingProgress, height: 6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(primaryColor)
                                            .blur(radius: 4)
                                            .opacity(0.3)
                                    )
                            }
                        }
                        .frame(width: 200, height: 6)
                        
                        // Loading text with fade effect
                        Text("Loading...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .opacity(loadingProgress < 1.0 ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                    }
                    .padding(.bottom, 50)
                }
                
                // Add shimmer effect over the logo
                if showShimmer {
                    shimmer
                        .rotationEffect(.degrees(30))
                        .blendMode(.screen)
                }
                
                // Add floating medical icons
                ForEach(0..<medicalSymbols.count) { index in
                    Image(systemName: medicalSymbols[index])
                        .font(.system(size: 16))
                        .foregroundColor(primaryColor.opacity(0.3))
                        .offset(x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -200...200))
                        .rotationEffect(.degrees(Double.random(in: -30...30)))
                }
            }
            .onAppear {
                startEnhancedAnimations()
            }
        }
    }
    
    private func startEnhancedAnimations() {
        // Start existing animations
        startAnimations()
        
        // Start ripple effect
        withAnimation(.easeInOut(duration: 0.5)) {
            showRipple = true
        }
        
        // Start shimmer animation
        withAnimation {
            showShimmer = true
        }
        
        // Continuous shimmer movement
        withAnimation(
            .linear(duration: 2.5)
            .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 1.25
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        
        // Sequence of haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            generator.impactOccurred(intensity: 0.7)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generator.impactOccurred(intensity: 0.5)
        }
    }
    
    private func startAnimations() {
        // Sequence the animations for better performance
        
        // Initial animations
        withAnimation(.easeIn(duration: 0.5)) {
            showDNA = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 1.2)) {
                size = 1.0
                opacity = 1.0
            }
        }
        
        // Start particle system with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particleSystem.start()
            withAnimation {
                showParticles = true
            }
        }
        
        // Rotating animation
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // DNA movement
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            dnaOffset = 100
        }
        
        // Heartbeat animation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showHeartbeat = true
            }
            
            // Continuous heartbeat animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                heartbeatOffset = 20
            }
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
        
        // Symbol morphing with smoother timing
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentSymbolIndex = (currentSymbolIndex + 1) % medicalSymbols.count
            }
        }
        
        // Progress animation with natural easing
        withAnimation(.easeInOut(duration: 2.5)) {
            loadingProgress = 1.0
        }
        
        // Navigate to main view with proper transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}

// MARK: - DNA Animation
struct DNAAnimation: View {
    let offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // First helix strand
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let waveHeight: CGFloat = 20
                    let frequency: CGFloat = .pi * 2 / 100
                    
                    path.move(to: CGPoint(x: 0, y: height / 2))
                    
                    for x in stride(from: 0, through: width, by: 1) {
                        let y = sin(frequency * x + offset) * waveHeight + height / 2
                        path.addLine(to: CGPoint(x: x, y: y))
                        
                        // Add connecting lines every 25 points
                        if Int(x) % 25 == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                            let y2 = sin(frequency * x + offset + .pi) * waveHeight + height / 2
                            path.addLine(to: CGPoint(x: x, y: y2))
                            path.move(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                
                // Second helix strand (offset by π)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let waveHeight: CGFloat = 20
                    let frequency: CGFloat = .pi * 2 / 100
                    
                    path.move(to: CGPoint(x: 0, y: height / 2))
                    
                    for x in stride(from: 0, through: width, by: 1) {
                        let y = sin(frequency * x + offset + .pi) * waveHeight + height / 2
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [secondaryColor, tertiaryColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                
                // DNA dots
                ForEach(0..<Int(geometry.size.width/25)) { index in
                    let x = CGFloat(index) * 25
                    let y1 = sin(2 * .pi * x / 100 + offset) * 20 + geometry.size.height / 2
                    let y2 = sin(2 * .pi * x / 100 + offset + .pi) * 20 + geometry.size.height / 2
                    
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 4, height: 4)
                        .position(x: x, y: y1)
                        .opacity(0.6)
                    
                    Circle()
                        .fill(secondaryColor)
                        .frame(width: 4, height: 4)
                        .position(x: x, y: y2)
                        .opacity(0.6)
                }
            }
        }
    }
}

// MARK: - Enhanced Particle System
class ParticleSystem {
    var particles: [Particle] = []
    let particleCount = 50
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var speed: Double
        var scale: Double
        var opacity: Double
        var color: Color
    }
    
    func start() {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: Double.random(in: 0...1),
                    y: Double.random(in: 0...1)
                ),
                speed: Double.random(in: 0.5...2),
                scale: Double.random(in: 0.2...0.7),
                opacity: Double.random(in: 0.3...0.7),
                color: [Color.blue, Color.green, Color.purple].randomElement() ?? .blue
            )
        }
    }
}

// MARK: - Enhanced Particle Effect View
struct ParticleEffectView: View {
    let system: ParticleSystem
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(system.particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(particle.scale * (isAnimating ? 1.2 : 0.8))
                    .opacity(particle.opacity * (isAnimating ? 1.0 : 0.5))
                    .position(
                        x: particle.position.x * geometry.size.width,
                        y: particle.position.y * geometry.size.height
                    )
                    .animation(
                        Animation
                            .easeInOut(duration: particle.speed)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Heartbeat Line
struct HeartbeatLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Starting point
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        // First normal beat
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.midY))
        
        // Heartbeat spike
        path.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.midY - 20))
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.midY + 20))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.midY - 5))
        
        // Return to normal
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.midY))
        
        // Second heartbeat
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.midY - 20))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.midY + 20))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.midY - 5))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        
        return path
    }
}

#Preview {
    SplashScreen()
}

extension View {
    func glowEffect(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius / 2)
    }
} 