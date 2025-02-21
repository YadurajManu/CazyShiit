import SwiftUI

struct AuthView: View {
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var isSecured = true
    @State private var selectedRole = UserRole.patient
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var activeField: Field? = nil
    @State private var navigateToPatientDashboard: Patient? = nil
    @State private var navigateToDoctorDashboard: Doctor? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    enum Field {
        case phone, email, password
    }
    
    // Constants for styling
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    // Input Validation
    private var isValidPhone: Bool {
        let phoneCount = phoneNumber.count
        let isNumeric = phoneNumber.allSatisfy { $0.isNumber }
        return phoneCount == 10 && isNumeric
    }
    
    private var isValidEmail: Bool {
        let containsAt = email.contains("@")
        let containsDot = email.contains(".")
        return containsAt && containsDot
    }
    
    private var isValidPassword: Bool {
        password.count >= 6
    }
    
    private var isFormValid: Bool {
        if selectedTab == 0 {
            return isValidPhone && isValidPassword
        } else {
            return isValidPhone && isValidEmail && isValidPassword
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        mainColor.opacity(0.08),
                        Color(uiColor: .systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Background circles
                Circle()
                    .fill(mainColor.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .blur(radius: 10)
                    .offset(x: -120, y: -100)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                Circle()
                    .fill(secondaryColor.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .blur(radius: 10)
                    .offset(x: 120, y: 400)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Logo with glass effect
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ? .black.opacity(0.3) : .white.opacity(0.7))
                                .frame(width: 80, height: 80)
                                .blur(radius: 1)
                            
                            HStack(spacing: 0) {
                                Text("AI")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(mainColor)
                                Text("युष")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .background(
                            Circle()
                                .fill(mainColor.opacity(0.15))
                                .frame(width: 90, height: 90)
                                .blur(radius: 8)
                        )
                        .padding(.top, 32)
                        
                        // Welcome Text
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Please sign in to continue")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        // Role Selection with haptic feedback
                        HStack(spacing: 12) {
                            ForEach([UserRole.patient, UserRole.doctor], id: \.self) { role in
                                RoleSelectionButton(
                                    role: role,
                                    isSelected: selectedRole == role,
                                    action: {
                                        withAnimation(.spring()) {
                                            selectedRole = role
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Auth Tabs
                        CustomSegmentedControl(
                            selection: $selectedTab,
                            options: ["Login", "Sign Up"]
                        )
                        .padding(.horizontal)
                        .frame(height: 40)
                        
                        // Input Fields Container
                        VStack(spacing: 14) {
                            // Phone Number Field with validation
                            CustomTextField(
                                text: $phoneNumber,
                                placeholder: "Phone Number",
                                prefix: "+91",
                                keyboardType: .numberPad,
                                isValid: isValidPhone,
                                isFocused: activeField == .phone,
                                onFocus: { activeField = .phone }
                            )
                            .shake(isShaking: showError && !isValidPhone)
                            
                            if selectedTab == 1 {
                                // Email Field with validation
                                CustomTextField(
                                    text: $email,
                                    placeholder: "Email",
                                    systemImage: "envelope",
                                    keyboardType: .emailAddress,
                                    isValid: isValidEmail,
                                    isFocused: activeField == .email,
                                    onFocus: { activeField = .email }
                                )
                                .shake(isShaking: showError && !isValidEmail)
                            }
                            
                            // Password Field with validation
                            CustomSecureField(
                                text: $password,
                                isSecured: $isSecured,
                                placeholder: "Password",
                                isValid: isValidPassword,
                                isFocused: activeField == .password,
                                onFocus: { activeField = .password }
                            )
                            .shake(isShaking: showError && !isValidPassword)
                            
                            if showError {
                                Text(errorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Main Action Button with loading state
                            Button(action: handleAuthentication) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text(selectedTab == 0 ? "Login" : "Sign Up")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        if selectedTab == 0 {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    ZStack {
                                        mainColor.opacity(isFormValid ? 1 : 0.5)
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
                                .shadow(color: mainColor.opacity(isFormValid ? 0.25 : 0),
                                        radius: 12, x: 0, y: 6)
                            }
                            .disabled(!isFormValid || isLoading)
                            .padding(.horizontal)
                            
                            // Social Login
                            VStack(spacing: 12) {
                                Text("Or continue with")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 12) {
                                    SocialLoginButton(
                                        image: "g.circle.fill",
                                        text: "Google",
                                        action: {}
                                    )
                                    
                                    SocialLoginButton(
                                        image: "apple.logo",
                                        text: "Apple",
                                        action: {}
                                    )
                                }
                                .padding(.horizontal)
                            }
                            
                            if selectedTab == 0 {
                                Button(action: {
                                    // Handle guest mode
                                }) {
                                    Text("Continue as Guest")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 16)
                                        .background(Color.gray.opacity(0.08))
                                        .clipShape(Capsule())
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(item: $navigateToPatientDashboard) { patient in
                PatientDashboard(patient: patient)
            }
            .navigationDestination(item: $navigateToDoctorDashboard) { doctor in
                DoctorDashboard(doctor: doctor)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onChange(of: selectedTab) { _ in
            withAnimation {
                showError = false
                errorMessage = ""
            }
        }
    }
    
    private func handleAuthentication() {
        isLoading = true
        showError = false
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let (success, userId) = DummyDataManager.shared.authenticateUser(
                phoneNumber: phoneNumber,
                password: password,
                role: selectedRole
            )
            
            if success, let userId = userId {
                switch selectedRole {
                case .patient:
                    if let patient = DummyDataManager.shared.getPatient(byId: userId) {
                        navigateToPatientDashboard = patient
                    }
                case .doctor:
                    if let doctor = DummyDataManager.shared.getDoctor(byId: userId) {
                        navigateToDoctorDashboard = doctor
                    }
                }
            } else {
                showError = true
                errorMessage = "Invalid credentials. Please try again."
            }
            
            isLoading = false
        }
    }
}

// MARK: - Supporting Views

struct RoleSelectionButton: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(red: 0.0, green: 0.478, blue: 0.988) : Color.gray.opacity(0.08))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: role == .patient ? "person.fill" : "stethoscope")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(role.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 0.0, green: 0.478, blue: 0.988) : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.0, green: 0.478, blue: 0.988).opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                segmentView(for: index)
            }
        }
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func segmentView(for index: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selection = index
            }
        }) {
            Text(options[index])
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(selection == index ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    selection == index ?
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.0, green: 0.478, blue: 0.988))
                        .matchedGeometryEffect(id: "TAB", in: namespace)
                    : nil
                )
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(isShaking: Bool) -> some View {
        modifier(ShakeEffect(animatableData: isShaking ? 1 : 0))
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var prefix: String? = nil
    var systemImage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isValid: Bool = true
    var isFocused: Bool = false
    var onFocus: (() -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        HStack(spacing: 10) {
            if let prefix = prefix {
                Text(prefix)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                    .foregroundColor(isFocused ? mainColor : .secondary)
            }
            
            TextField(placeholder, text: $text) { focused in
                if focused {
                    onFocus?()
                }
            }
            .keyboardType(keyboardType)
            .font(.system(size: 14))
            
            if !text.isEmpty {
                Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isValid ? .green : .red)
                    .font(.system(size: 14))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? mainColor : Color.gray.opacity(0.15), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isValid)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    @Binding var isSecured: Bool
    let placeholder: String
    var isValid: Bool = true
    var isFocused: Bool = false
    var onFocus: (() -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock")
                .font(.system(size: 14))
                .foregroundColor(isFocused ? mainColor : .secondary)
            
            if isSecured {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? mainColor : Color.gray.opacity(0.15), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isValid)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct SocialLoginButton: View {
    let image: String
    let text: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: image)
                    .font(.system(size: 16))
                Text(text)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.gray.opacity(isPressed ? 0.12 : 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .pressEvents(onPress: { isPressed = true },
                    onRelease: { isPressed = false })
    }
}

// Press Event View Modifier
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void,
                    onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

#Preview {
    AuthView()
}