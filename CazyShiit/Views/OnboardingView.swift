import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedRole: UserRole = .patient
    @State private var selectedSpecialties: Set<DiseaseSpecialization> = []
    @State private var name = ""
    @State private var healthGoals: Set<HealthGoal> = []
    @State private var isOnboardingComplete = false
    @State private var animateCards = false
    
    private let mainColor = Color("AccentBlue")
    private let secondaryColor = Color("AccentGreen")
    private let accentPurple = Color("AccentPurple")
    
    private let healthGoalOptions: [HealthGoal] = [
        .init(id: "1", title: "Regular Check-ups", icon: "calendar.badge.clock"),
        .init(id: "2", title: "Manage Chronic Conditions", icon: "heart.text.square"),
        .init(id: "3", title: "Preventive Care", icon: "shield.lefthalf.filled"),
        .init(id: "4", title: "Mental Wellness", icon: "brain.head.profile"),
        .init(id: "5", title: "Physical Fitness", icon: "figure.run"),
        .init(id: "6", title: "Better Sleep", icon: "moon.zzz")
    ]
    
    var body: some View {
        if isOnboardingComplete {
            ContentView()
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        mainColor.opacity(0.1),
                        .clear,
                        accentPurple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Progress Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<4) { step in
                            Capsule()
                                .fill(step <= currentStep ? mainColor : Color.gray.opacity(0.3))
                                .frame(width: step == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentStep)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Welcome Screen
                        WelcomeView(name: $name)
                            .tag(0)
                        
                        // Role Selection
                        RoleSelectionView(selectedRole: $selectedRole)
                            .tag(1)
                        
                        // Specialty Selection (for both roles)
                        SpecialtySelectionView(
                            selectedSpecialties: $selectedSpecialties,
                            role: selectedRole
                        )
                        .tag(2)
                        
                        // Health Goals
                        HealthGoalsView(
                            selectedGoals: $healthGoals,
                            healthGoalOptions: healthGoalOptions
                        )
                        .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Navigation Buttons
                    HStack(spacing: 20) {
                        if currentStep > 0 {
                            Button(action: { currentStep -= 1 }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Back")
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                            }
                        }
                        
                        Button(action: {
                            if currentStep < 3 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        }) {
                            HStack {
                                Text(currentStep == 3 ? "Get Started" : "Next")
                                Image(systemName: currentStep == 3 ? "checkmark" : "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(mainColor)
                            .clipShape(Capsule())
                        }
                        .disabled(isStepValid == false)
                        .opacity(isStepValid ? 1 : 0.6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    private var isStepValid: Bool {
        switch currentStep {
        case 0: return !name.isEmpty
        case 1: return true
        case 2: return !selectedSpecialties.isEmpty
        case 3: return !healthGoals.isEmpty
        default: return true
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            isOnboardingComplete = true
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @Binding var name: String
    private let mainColor = Color("AccentBlue")
    
    var body: some View {
        VStack(spacing: 30) {
            // Welcome Animation
            LottieView(name: "welcome_animation")
                .frame(height: 200)
            
            VStack(spacing: 16) {
                Text("Welcome to AIयुष")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Let's personalize your experience")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.headline)
                
                TextField("Enter your name", text: $name)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
}

// MARK: - Role Selection View
struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole
    private let mainColor = Color("AccentBlue")
    @State private var animateSelection = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("I am a...")
                .font(.system(size: 28, weight: .bold))
            
            HStack(spacing: 20) {
                RoleCard(
                    role: .patient,
                    isSelected: selectedRole == .patient,
                    action: { selectedRole = .patient }
                )
                
                RoleCard(
                    role: .doctor,
                    isSelected: selectedRole == .doctor,
                    action: { selectedRole = .doctor }
                )
            }
            .padding(.horizontal, 24)
        }
    }
}

struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    private let mainColor = Color("AccentBlue")
    
    var roleIcon: String {
        switch role {
        case .patient: return "person.fill"
        case .doctor: return "stethoscope"
        }
    }
    
    var roleDescription: String {
        switch role {
        case .patient: return "I'm looking for medical care"
        case .doctor: return "I'm a healthcare provider"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Circle()
                    .fill(isSelected ? mainColor : Color.clear)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: roleIcon)
                            .font(.system(size: 36))
                            .foregroundColor(isSelected ? .white : mainColor)
                    )
                
                VStack(spacing: 8) {
                    Text(role.rawValue)
                        .font(.headline)
                    
                    Text(roleDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: isSelected ? mainColor.opacity(0.3) : Color.gray.opacity(0.1),
                            radius: isSelected ? 15 : 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? mainColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Specialty Selection View
struct SpecialtySelectionView: View {
    @Binding var selectedSpecialties: Set<DiseaseSpecialization>
    let role: UserRole
    private let mainColor = Color("AccentBlue")
    
    var title: String {
        switch role {
        case .patient: return "What are your health interests?"
        case .doctor: return "Select your specializations"
        }
    }
    
    var subtitle: String {
        switch role {
        case .patient: return "Choose areas you'd like to focus on"
        case .doctor: return "Select the areas you specialize in"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                
                Text(subtitle)
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(DiseaseSpecialization.allCases, id: \.self) { specialty in
                        SpecialtyCard(
                            specialty: specialty,
                            isSelected: selectedSpecialties.contains(specialty),
                            action: {
                                if selectedSpecialties.contains(specialty) {
                                    selectedSpecialties.remove(specialty)
                                } else {
                                    selectedSpecialties.insert(specialty)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct SpecialtyCard: View {
    let specialty: DiseaseSpecialization
    let isSelected: Bool
    let action: () -> Void
    private let mainColor = Color("AccentBlue")
    
    var specialtyIcon: String {
        switch specialty {
        case .arthritis: return "figure.walk"
        case .brain: return "brain.head.profile"
        case .tumor: return "cellularbars"
        case .lungCancer: return "lungs.fill"
        case .diabeticRetinopathy: return "eye"
        case .goiter: return "person.crop.circle.badge.exclamationmark"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: specialtyIcon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : mainColor)
                
                Text(specialty.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mainColor : Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mainColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Health Goals View
struct HealthGoalsView: View {
    @Binding var selectedGoals: Set<HealthGoal>
    let healthGoalOptions: [HealthGoal]
    private let mainColor = Color("AccentBlue")
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Set Your Health Goals")
                    .font(.system(size: 28, weight: .bold))
                
                Text("What would you like to achieve?")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(healthGoalOptions) { goal in
                        HealthGoalCard(
                            goal: goal,
                            isSelected: selectedGoals.contains(goal),
                            action: {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct HealthGoal: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HealthGoal, rhs: HealthGoal) -> Bool {
        lhs.id == rhs.id
    }
}

struct HealthGoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void
    private let mainColor = Color("AccentBlue")
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : mainColor)
                
                Text(goal.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mainColor : Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mainColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
} 