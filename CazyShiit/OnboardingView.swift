import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @State private var showLogo = false
    @State private var currentSymbolIndex = 0
    @State private var showLanguageSelection = false
    @Namespace private var animation
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var languageManager = LanguageManager.shared
    
    let medicalSymbols = ["heart.fill", "cross.case.fill", "staroflife.fill", "pills.fill"]
    let floatingIcons = ["syringe.fill", "thermometer.fill", "bandage.fill", "ear.fill", "lungs.fill", "brain.head.fill"]
    
    let onboardingData = [
        OnboardingPage(
            title: "Welcome to AIयुष".localized,
            subtitle: "Your Health, Our Priority".localized,
            description: "Experience the future of healthcare".localized,
            imageName: "heart.fill",
            secondaryImage: "cross.case.fill",
            features: [
                "AI-Powered Health Recommendations".localized,
                "24/7 Doctor Availability".localized,
                "Secure Medical Records".localized
            ],
            statistics: [
                ImpactStatistic(value: "50K+", label: "Active Users".localized),
                ImpactStatistic(value: "1000+", label: "Doctors".localized),
                ImpactStatistic(value: "4.8", label: "App Rating".localized)
            ],
            testimonial: Testimonial(
                text: "AIयुष has revolutionized how I manage my practice. The AI recommendations are spot-on!",
                author: "Dr. Sharma",
                role: "Cardiologist",
                rating: 5
            ),
            accentColor: Color(red: 0.0, green: 0.478, blue: 0.988)
        ),
        OnboardingPage(
            title: "Smart Healthcare",
            subtitle: "AI-Powered Diagnosis",
            description: "Get intelligent health insights and connect with specialists based on your symptoms",
            imageName: "waveform.path.ecg",
            secondaryImage: "brain",
            features: [
                "Symptom Analysis",
                "Specialist Matching",
                "Health Predictions"
            ],
            statistics: [
                ImpactStatistic(value: "95%", label: "Accuracy"),
                ImpactStatistic(value: "2Min", label: "Avg. Response"),
                ImpactStatistic(value: "24/7", label: "Support")
            ],
            testimonial: Testimonial(
                text: "The AI symptom analysis helped me find the right specialist quickly. Saved me so much time!",
                author: "Priya Patel",
                role: "Patient",
                rating: 5
            ),
            accentColor: Color(red: 0.2, green: 0.851, blue: 0.4)
        ),
        OnboardingPage(
            title: "Complete Care",
            subtitle: "Beyond Appointments",
            description: "Comprehensive healthcare management with advanced features for better health outcomes",
            imageName: "heart.text.square",
            secondaryImage: "chart.line.uptrend.xyaxis",
            features: [
                "Health Timeline",
                "Medicine Reminders",
                "Family Health Tracking"
            ],
            statistics: [
                ImpactStatistic(value: "80%", label: "Better Adherence"),
                ImpactStatistic(value: "60%", label: "Faster Care"),
                ImpactStatistic(value: "90%", label: "Satisfaction")
            ],
            testimonial: Testimonial(
                text: "Managing my family's health has never been easier. The medicine reminders are a lifesaver!",
                author: "Rajesh Kumar",
                role: "Family User",
                rating: 5
            ),
            accentColor: Color(red: 0.6, green: 0.2, blue: 0.988)
        )
    ]
    
    var body: some View {
        if isOnboardingComplete {
            ContentView()
                .transition(.asymmetric(insertion: .move(edge: .trailing),
                                      removal: .move(edge: .leading)))
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        onboardingData[currentPage].accentColor.opacity(0.1),
                        Color(uiColor: .systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating Medical Icons
                FloatingIconsView(icons: floatingIcons)
                
                // Company Logo at the top
                VStack {
                    AnimatedLogoView(
                        showLogo: $showLogo,
                        currentSymbolIndex: $currentSymbolIndex,
                        medicalSymbols: medicalSymbols,
                        accentColor: onboardingData[currentPage].accentColor
                    )
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .zIndex(1)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingData[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack {
                    // Top bar with language selection
                    HStack {
                        Button(action: {
                            showLanguageSelection = true
                        }) {
                            HStack {
                                Text(languageManager.currentLanguage.flag)
                                Text(languageManager.currentLanguage.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                            )
                        }
                        
                        Spacer()
                        
                        if currentPage < onboardingData.count - 1 {
                            Button("Skip".localized) {
                                withAnimation(.spring()) {
                                    isOnboardingComplete = true
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bottom Navigation
                    VStack(spacing: 20) {
                        // Custom Page Indicator
                        HStack(spacing: 12) {
                            ForEach(0..<onboardingData.count, id: \.self) { index in
                                Capsule()
                                    .fill(currentPage == index ? onboardingData[index].accentColor : Color.gray.opacity(0.3))
                                    .frame(width: currentPage == index ? 20 : 8, height: 8)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                        
                        // Next/Get Started button
                        Button(action: {
                            withAnimation(.spring()) {
                                if currentPage == onboardingData.count - 1 {
                                    isOnboardingComplete = true
                                } else {
                                    currentPage += 1
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(currentPage == onboardingData.count - 1 ? "Get Started" : "Next")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Image(systemName: currentPage == onboardingData.count - 1 ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(width: currentPage == onboardingData.count - 1 ? 220 : 140, height: 56)
                            .background(
                                ZStack {
                                    onboardingData[currentPage].accentColor
                                    
                                    // Subtle gradient overlay
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .clipShape(Capsule())
                            .shadow(color: onboardingData[currentPage].accentColor.opacity(0.3),
                                    radius: 15, x: 0, y: 10)
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                startAnimations()
            }
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionView()
                    .environmentObject(languageManager)
            }
        }
    }
    
    private func startAnimations() {
        // Start logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5)) {
            showLogo = true
        }
        
        // Start medical symbol morphing
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentSymbolIndex = (currentSymbolIndex + 1) % medicalSymbols.count
            }
        }
    }
}

// MARK: - Animated Logo View
struct AnimatedLogoView: View {
    @Binding var showLogo: Bool
    @Binding var currentSymbolIndex: Int
    let medicalSymbols: [String]
    let accentColor: Color
    
    @State private var isPulsing = false
    
    var body: some View {
        HStack {
            // AI text with medical symbol
            HStack(spacing: 2) {
                Text("AI")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(accentColor)
                
                Image(systemName: medicalSymbols[currentSymbolIndex])
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            }
            
            Text("युष")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground).opacity(0.8))
                .shadow(color: accentColor.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .opacity(showLogo ? 1 : 0)
        .offset(y: showLogo ? 0 : -20)
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Floating Icons View
struct FloatingIconsView: View {
    let icons: [String]
    @State private var positions: [CGPoint] = []
    @State private var animationPhases: [Double] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<icons.count, id: \.self) { index in
                    Image(systemName: icons[index])
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.3))
                        .position(
                            x: positions.count > index ? positions[index].x : 0,
                            y: positions.count > index ? positions[index].y : 0
                        )
                        .animation(
                            Animation
                                .easeInOut(duration: 4)
                                .repeatForever()
                                .delay(animationPhases.count > index ? animationPhases[index] : 0),
                            value: positions
                        )
                }
            }
            .onAppear {
                initializePositions(in: geometry.size)
                startFloatingAnimation(in: geometry.size)
            }
        }
    }
    
    private func initializePositions(in size: CGSize) {
        positions = icons.map { _ in
            CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: CGFloat.random(in: 50...(size.height - 50))
            )
        }
        animationPhases = icons.map { _ in Double.random(in: 0...2) }
    }
    
    private func startFloatingAnimation(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            for i in 0..<positions.count {
                positions[i] = CGPoint(
                    x: CGFloat.random(in: 50...(size.width - 50)),
                    y: CGFloat.random(in: 50...(size.height - 50))
                )
            }
        }
    }
}

// MARK: - Enhanced Data Models
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let secondaryImage: String
    let features: [String]
    let statistics: [ImpactStatistic]
    let testimonial: Testimonial
    let accentColor: Color
}

struct ImpactStatistic: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct Testimonial: Identifiable {
    let id = UUID()
    let text: String
    let author: String
    let role: String
    let rating: Int
}

// MARK: - Enhanced Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    @State private var showFeatures = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                // Image Container
                ZStack {
                    // Background circles
                    Circle()
                        .fill(page.accentColor.opacity(0.15))
                        .frame(width: 280, height: 280)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .blur(radius: 2)
                    
                    Circle()
                        .fill(page.accentColor.opacity(0.1))
                        .frame(width: 230, height: 230)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .blur(radius: 1)
                    
                    // Secondary floating elements
                    Image(systemName: page.secondaryImage)
                        .font(.system(size: 30))
                        .foregroundColor(page.accentColor)
                        .offset(x: isAnimating ? 80 : 60, y: isAnimating ? -60 : -40)
                        .opacity(isAnimating ? 0.8 : 0)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                    
                    Image(systemName: page.secondaryImage)
                        .font(.system(size: 25))
                        .foregroundColor(page.accentColor)
                        .offset(x: isAnimating ? -70 : -50, y: isAnimating ? 50 : 30)
                        .opacity(isAnimating ? 0.6 : 0)
                        .rotationEffect(.degrees(isAnimating ? -15 : 15))
                    
                    // Main icon with glass effect
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.8))
                            .frame(width: 160, height: 160)
                            .blur(radius: 1)
                        
                        Image(systemName: page.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(page.accentColor)
                            .offset(y: isAnimating ? 0 : 20)
                    }
                    .background(
                        Circle()
                            .fill(page.accentColor.opacity(0.3))
                            .frame(width: 165, height: 165)
                            .blur(radius: 10)
                    )
                }
                .padding(.top, 60)
                
                // Content
                VStack(spacing: 24) {
                    // Title and Description
                    VStack(spacing: 16) {
                        Text(page.title)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text(page.subtitle)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(page.accentColor)
                            .opacity(0.8)
                        
                        Text(page.description)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                    }
                    
                    // Impact Statistics
                    HStack(spacing: 20) {
                        ForEach(page.statistics) { stat in
                            VStack(spacing: 8) {
                                Text(stat.value)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(page.accentColor)
                                
                                Text(stat.label)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(page.accentColor.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Features List
                    VStack(spacing: 12) {
                        ForEach(page.features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(page.accentColor)
                                Text(feature)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .opacity(showFeatures ? 1 : 0)
                            .offset(x: showFeatures ? 0 : -20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Testimonial Card
                    TestimonialCard(testimonial: page.testimonial, accentColor: page.accentColor)
                        .padding(.horizontal, 24)
                }
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4)) {
                showFeatures = true
            }
        }
        .onDisappear {
            isAnimating = false
            showFeatures = false
        }
    }
}

// MARK: - Testimonial Card
struct TestimonialCard: View {
    let testimonial: Testimonial
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Quote Icon
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 24))
                .foregroundColor(accentColor)
            
            // Testimonial Text
            Text(testimonial.text)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Rating
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: index < testimonial.rating ? "star.fill" : "star")
                        .foregroundColor(.orange)
                }
            }
            
            // Author Info
            VStack(spacing: 4) {
                Text(testimonial.author)
                    .font(.system(size: 16, weight: .medium))
                
                Text(testimonial.role)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: accentColor.opacity(0.1), radius: 15)
        )
    }
}

#Preview {
    OnboardingView()
} 