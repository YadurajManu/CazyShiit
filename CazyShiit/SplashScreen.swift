import SwiftUI

// MARK: - Theme Colors
struct AppTheme {
    static let primaryColor = Color.blue
    static let secondaryColor = Color.green
    static let tertiaryColor = Color.purple
    static let accentColor = Color.teal
    static let backgroundColor = Color(uiColor: .systemBackground)
    static let textColor = Color.primary
    static let subtleColor = Color.secondary
    
    static let gradientColors = [primaryColor, accentColor, tertiaryColor]
    static let particleColors = [primaryColor, accentColor, Color.mint]
    static let glowColors = [primaryColor.opacity(0.5), accentColor.opacity(0.3)]
}

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
    @State private var showScanEffect = false
    @State private var showDataPoints = false
    
    // Medical symbols for morphing
    let medicalSymbols = ["cross.fill", "heart.fill", "staroflife.fill", "pills.fill"]
    @State private var currentSymbolIndex = 0
    
    let dataPoints = [
        DataPoint(label: "Heart Rate", value: "72 BPM", color: .green),
        DataPoint(label: "Blood Pressure", value: "120/80", color: .blue),
        DataPoint(label: "SpO2", value: "98%", color: .cyan),
        DataPoint(label: "Temperature", value: "98.6°F", color: .orange)
    ]
    
    var shimmer: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                .white.opacity(0.2),
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
                // MARK: - Background Layer
                RadialGradient(
                    gradient: Gradient(colors: [
                        AppTheme.primaryColor.opacity(0.1),
                        AppTheme.backgroundColor
                    ]),
                    center: .center,
                    startRadius: 2,
                    endRadius: 650
                )
                .ignoresSafeArea()
                
                // MARK: - Particle Effect Layer
                if showParticles {
                    ParticleEffectView(system: particleSystem)
                        .opacity(0.3)
                }
                
                // MARK: - DNA Animation Layer
                if showDNA {
                    DNAAnimation(offset: dnaOffset)
                        .opacity(0.2)
                        .frame(height: 100)
                        .offset(y: 200)
                }
                
                // MARK: - Main Content Layer
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo Container
                    ZStack {
                        // Glow circles
                        Circle()
                            .fill(AppTheme.primaryColor)
                            .frame(width: 150, height: 150)
                            .blur(radius: 30)
                            .opacity(glowOpacity * 0.3)
                        
                        // Logo content
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text("AI")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(AppTheme.primaryColor)
                                
                                Image(systemName: medicalSymbols[currentSymbolIndex])
                                    .font(.system(size: 32))
                                    .foregroundColor(AppTheme.primaryColor)
                                    .rotationEffect(.degrees(rotationAngle))
                            }
                            
                            Text("युष")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppTheme.textColor)
                        }
                        .padding(30)
                        .background(
                            Circle()
                                .fill(Color(uiColor: .systemBackground))
                                .opacity(0.9)
                                .shadow(color: AppTheme.primaryColor.opacity(0.2), radius: 20)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.primaryColor.opacity(0.5),
                                            AppTheme.secondaryColor.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(size)
                    }
                    
                    // MARK: - Medical Scan Data
                    if showScanEffect {
                        VStack(spacing: 15) {
                            // Data points in a grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(dataPoints, id: \.label) { point in
                                    DataPointView(point: point)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .opacity(showDataPoints ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Elements
                    VStack(spacing: 20) {
                        // Heartbeat line
                        if showHeartbeat {
                            HeartbeatLine()
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 200, height: 30)
                                .offset(x: heartbeatOffset)
                        }
                        
                        // Progress bar
                        ProgressView(value: loadingProgress)
                            .frame(width: 200)
                            .tint(AppTheme.primaryColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.primaryColor.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("Initializing AI Health System...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.subtleColor)
                            .opacity(loadingProgress < 1.0 ? 1 : 0)
                    }
                    .padding(.bottom, 50)
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
        
        // Start scan effect with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showScanEffect = true
            }
        }
        
        // Show data points with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showDataPoints = true
            }
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
    
    private func createHelixPath(in geometry: GeometryProxy, offset: CGFloat, phase: CGFloat = 0) -> Path {
        let width = geometry.size.width
        let height = geometry.size.height
        let waveHeight: CGFloat = 20
        let frequency: CGFloat = .pi * 2 / 100
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 1) {
            let y = sin(frequency * x + offset + phase) * waveHeight + height / 2
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
    
    private func createConnectingLines(in geometry: GeometryProxy, offset: CGFloat) -> Path {
        let width = geometry.size.width
        let height = geometry.size.height
        let waveHeight: CGFloat = 20
        let frequency: CGFloat = .pi * 2 / 100
        
        var path = Path()
        
        for x in stride(from: 0, through: width, by: 25) {
            let y1 = sin(frequency * x + offset) * waveHeight + height / 2
            let y2 = sin(frequency * x + offset + .pi) * waveHeight + height / 2
            
            path.move(to: CGPoint(x: x, y: y1))
            path.addLine(to: CGPoint(x: x, y: y2))
        }
        
        return path
    }
    
    private func createDNADot(at position: CGPoint, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 4, height: 4)
            .position(position)
            .opacity(0.6)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // First helix strand
                createHelixPath(in: geometry, offset: offset)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                
                // Second helix strand
                createHelixPath(in: geometry, offset: offset, phase: .pi)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.secondaryColor, AppTheme.tertiaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                
                // Connecting lines
                createConnectingLines(in: geometry, offset: offset)
                    .stroke(
                        AppTheme.primaryColor.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1, lineCap: .round)
                    )
                
                // DNA dots
                ForEach(0..<Int(geometry.size.width/25), id: \.self) { index in
                    let x = CGFloat(index) * 25
                    let frequency: CGFloat = .pi * 2 / 100
                    let y1 = sin(frequency * x + offset) * 20 + geometry.size.height / 2
                    let y2 = sin(frequency * x + offset + .pi) * 20 + geometry.size.height / 2
                    
                    Group {
                        createDNADot(
                            at: CGPoint(x: x, y: y1),
                            color: AppTheme.primaryColor
                        )
                        
                        createDNADot(
                            at: CGPoint(x: x, y: y2),
                            color: AppTheme.secondaryColor
                        )
                    }
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
                color: AppTheme.particleColors.randomElement() ?? AppTheme.primaryColor
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

// MARK: - Data Point View
struct DataPointView: View {
    let point: DataPoint
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(point.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(point.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(point.value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(point.color)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .opacity(0.9)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Update DataPoint struct to be identifiable
struct DataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let color: Color
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