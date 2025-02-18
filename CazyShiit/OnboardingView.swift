import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @State private var showLogo = false
    @Namespace private var animation
    @Environment(\.colorScheme) private var colorScheme
    
    let onboardingData = [
        OnboardingPage(title: "Welcome to AIयुष",
                      subtitle: "Your Health, Our Priority",
                      description: "Experience the future of healthcare with India's most intelligent appointment booking platform",
                      imageName: "heart.fill",
                      secondaryImage: "cross.case.fill",
                      features: ["AI-Powered Recommendations", "24/7 Availability", "Secure Platform"],
                      accentColor: Color(red: 0.0, green: 0.478, blue: 0.988)),
        OnboardingPage(title: "Smart Booking",
                      subtitle: "Book in Seconds",
                      description: "Book appointments with doctors instantly with just a few taps",
                      imageName: "calendar.badge.plus",
                      secondaryImage: "clock.fill",
                      features: ["Instant Confirmation", "Smart Scheduling", "Reminder System"],
                      accentColor: Color(red: 0.2, green: 0.851, blue: 0.4)),
        OnboardingPage(title: "Health Journey",
                      subtitle: "All in One Place",
                      description: "Keep all your medical appointments and records in one secure place",
                      imageName: "list.clipboard",
                      secondaryImage: "chart.line.uptrend.xyaxis",
                      features: ["Digital Records", "Progress Tracking", "Health Insights"],
                      accentColor: Color(red: 0.6, green: 0.2, blue: 0.988))
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
                
                // Company Logo at the top
                VStack {
                    HStack {
                        Text("AI")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(onboardingData[currentPage].accentColor)
                        + Text("युष")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : -20)
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
                    // Top Skip Button
                    HStack {
                        Spacer()
                        if currentPage < onboardingData.count - 1 {
                            Button(action: {
                                withAnimation(.spring()) {
                                    isOnboardingComplete = true
                                }
                            }) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    
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
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5)) {
                    showLogo = true
                }
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let secondaryImage: String
    let features: [String]
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    @State private var showFeatures = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
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
                    .padding(.top, 8)
                
                // Feature List
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
            }
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
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

#Preview {
    OnboardingView()
} 