import SwiftUI

struct DoctorProfileView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEditProfile = false
    @State private var showNotificationSettings = false
    @State private var showPrivacySettings = false
    @State private var showHelpCenter = false
    @State private var showLogoutAlert = false
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderView(viewModel: viewModel)
                    AccountSettingsView(
                        showEditProfile: $showEditProfile,
                        showNotificationSettings: $showNotificationSettings,
                        showPrivacySettings: $showPrivacySettings
                    )
                    SupportHelpView(
                        showHelpCenter: $showHelpCenter,
                        mainColor: mainColor,
                        secondaryColor: secondaryColor
                    )
                    LogoutButtonView(showLogoutAlert: $showLogoutAlert)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showEditProfile) {
            EditDoctorProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showHelpCenter) {
            HelpCenterView()
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(mainColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "stethoscope.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(mainColor)
                
                Circle()
                    .strokeBorder(mainColor, lineWidth: 2)
                    .frame(width: 100, height: 100)
            }
            
            // Doctor Info
            VStack(spacing: 8) {
                Text("Dr. \(viewModel.doctor.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(viewModel.doctor.specialization.rawValue)
                    .font(.subheadline)
                    .foregroundColor(mainColor)
                
                Text(viewModel.doctor.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("+91 \(viewModel.doctor.phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Quick Stats
            HStack(spacing: 24) {
                StatItem(title: "Experience", value: "\(viewModel.doctor.experience)+ yrs")
                StatItem(title: "Rating", value: String(format: "%.1f", viewModel.doctor.rating))
                StatItem(title: "Patients", value: "\(viewModel.totalAppointments)")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: mainColor.opacity(0.1), radius: 15)
        )
        .padding(.horizontal)
    }
}

// MARK: - Account Settings View
struct AccountSettingsView: View {
    @Binding var showEditProfile: Bool
    @Binding var showNotificationSettings: Bool
    @Binding var showPrivacySettings: Bool
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Settings")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ProfileMenuButton(
                    title: "Edit Profile",
                    icon: "person.circle",
                    color: mainColor
                ) {
                    showEditProfile = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileMenuButton(
                    title: "Notification Settings",
                    icon: "bell",
                    color: .orange
                ) {
                    showNotificationSettings = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileMenuButton(
                    title: "Privacy Settings",
                    icon: "lock",
                    color: .purple
                ) {
                    showPrivacySettings = true
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

// MARK: - Support & Help View
struct SupportHelpView: View {
    @Binding var showHelpCenter: Bool
    let mainColor: Color
    let secondaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support & Help")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ProfileMenuButton(
                    title: "Help Center",
                    icon: "questionmark.circle",
                    color: secondaryColor
                ) {
                    showHelpCenter = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileMenuButton(
                    title: "Terms of Service",
                    icon: "doc.text",
                    color: .blue
                ) {
                    // Handle terms of service
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileMenuButton(
                    title: "Privacy Policy",
                    icon: "shield",
                    color: .indigo
                ) {
                    // Handle privacy policy
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

// MARK: - Logout Button View
struct LogoutButtonView: View {
    @Binding var showLogoutAlert: Bool
    
    var body: some View {
        Button(action: { showLogoutAlert = true }) {
            HStack {
                Image(systemName: "arrow.right.square")
                Text("Logout")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
            )
            .padding(.horizontal)
        }
    }
}

// Supporting Views
struct EditDoctorProfileView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var showAlert = false
    
    init(viewModel: DoctorDashboardViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.doctor.name)
        _email = State(initialValue: viewModel.doctor.email)
        _phone = State(initialValue: viewModel.doctor.phoneNumber)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Professional Information") {
                    HStack {
                        Text("Specialization")
                        Spacer()
                        Text(viewModel.doctor.specialization.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Experience")
                        Spacer()
                        Text("\(viewModel.doctor.experience) years")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Rating")
                        Spacer()
                        Text("\(viewModel.doctor.rating, specifier: "%.1f")")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.updateProfile(name: name, email: email, phone: phone) {
                            dismiss()
                        }
                    }
                }
            }
            .alert(viewModel.alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
} 
