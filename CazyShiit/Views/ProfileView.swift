import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
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
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        ZStack {
                            Circle()
                                .fill(mainColor.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                            
                            Circle()
                                .strokeBorder(mainColor, lineWidth: 2)
                                .frame(width: 100, height: 100)
                        }
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(viewModel.patient.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(viewModel.patient.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("+91 \(viewModel.patient.phoneNumber)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Quick Stats
                        HStack(spacing: 24) {
                            StatItem(title: "Appointments", value: "\(viewModel.totalAppointments)")
                            StatItem(title: "Completed", value: "\(viewModel.completedAppointments)")
                            StatItem(title: "Conditions", value: "\(viewModel.patient.medicalHistory.count)")
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
                    
                    // Account Settings
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
                    
                    // Support & Help
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
                    
                    // Logout Button
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
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(viewModel: viewModel)
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

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// Supporting Views
struct EditProfileView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var showAlert = false
    
    init(viewModel: PatientDashboardViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.patient.name)
        _email = State(initialValue: viewModel.patient.email)
        _phone = State(initialValue: viewModel.patient.phoneNumber)
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

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appointmentReminders = true
    @State private var medicationReminders = true
    @State private var promotionalNotifications = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Appointment Reminders", isOn: $appointmentReminders)
                    Toggle("Medication Reminders", isOn: $medicationReminders)
                    Toggle("Promotional Notifications", isOn: $promotionalNotifications)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shareHealthData = false
    @State private var shareLocation = false
    @State private var allowAnalytics = true
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Share Health Data", isOn: $shareHealthData)
                    Toggle("Share Location", isOn: $shareLocation)
                    Toggle("Allow Analytics", isOn: $allowAnalytics)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("FAQs") {
                        Text("Frequently Asked Questions")
                    }
                    NavigationLink("Contact Support") {
                        Text("Support Contact Information")
                    }
                    NavigationLink("Report a Problem") {
                        Text("Problem Reporting Form")
                    }
                }
            }
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 