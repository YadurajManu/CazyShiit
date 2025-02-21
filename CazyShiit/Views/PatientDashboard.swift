import SwiftUI

struct PatientDashboard: View {
    @StateObject private var viewModel: PatientDashboardViewModel
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    init(patient: Patient) {
        _viewModel = StateObject(wrappedValue: PatientDashboardViewModel(patient: patient))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
            if !isLoggedIn {
                dismiss()
            }
        }
    }
}

// Move the existing dashboard content to a new HomeView
struct HomeView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showHealthRecords = false
    
    // Constants for styling
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
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
                .scaleEffect(viewModel.isAnimating ? 1.2 : 0.8)
            
            Circle()
                .fill(secondaryColor.opacity(0.05))
                .frame(width: 250, height: 250)
                .blur(radius: 10)
                .offset(x: 120, y: 400)
                .scaleEffect(viewModel.isAnimating ? 1.2 : 0.8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with user info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome,")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(viewModel.patient.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Profile picture and settings
                        Button(action: { viewModel.showProfileSettings = true }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? .black.opacity(0.3) : .white.opacity(0.7))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(mainColor)
                            }
                            .background(
                                Circle()
                                    .fill(mainColor.opacity(0.1))
                                    .frame(width: 60, height: 60)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Stats Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            StatsCard(
                                title: "Total Appointments",
                                value: "\(viewModel.totalAppointments)",
                                icon: "calendar",
                                color: mainColor
                            )
                            
                            StatsCard(
                                title: "Completed",
                                value: "\(viewModel.completedAppointments)",
                                icon: "checkmark.circle.fill",
                                color: secondaryColor
                            )
                            
                            StatsCard(
                                title: "Upcoming",
                                value: "\(viewModel.upcomingAppointmentsCount)",
                                icon: "clock.fill",
                                color: Color(red: 0.6, green: 0.2, blue: 0.988)
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "Book\nAppointment",
                                systemImage: "calendar.badge.plus",
                                color: mainColor
                            ) {
                                viewModel.showBookAppointment = true
                            }
                            
                            QuickActionButton(
                                title: "My\nAppointments",
                                systemImage: "list.clipboard",
                                color: secondaryColor
                            ) {
                                viewModel.showAppointmentsList = true
                            }
                            
                            QuickActionButton(
                                title: "Health\nRecords",
                                systemImage: "heart.text.square",
                                color: Color(red: 0.6, green: 0.2, blue: 0.988)
                            ) {
                                showHealthRecords = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Appointments
                    VStack(spacing: 16) {
                        HStack {
                            Text("Upcoming Appointments")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            if !viewModel.upcomingAppointments.isEmpty {
                                Button(action: { viewModel.showAppointmentsList = true }) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.upcomingAppointments.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No Upcoming Appointments",
                                message: "Book your first appointment with our specialists"
                            )
                        } else {
                            ForEach(viewModel.upcomingAppointments.prefix(2), id: \.id) { appointment in
                                AppointmentRow(viewModel: viewModel, appointment: appointment)
                                    .onTapGesture {
                                        viewModel.selectedAppointment = appointment
                                    }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Medical History Summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Medical History")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            if !viewModel.patient.medicalHistory.isEmpty {
                                Button(action: { viewModel.showMedicalHistory = true }) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.patient.medicalHistory, id: \.self) { condition in
                                    ConditionCard(condition: condition)
                                        .onTapGesture {
                                            viewModel.selectedSpecialization = condition
                                            viewModel.showBookAppointment = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Recommended Doctors
                    if !viewModel.recommendedDoctors.isEmpty {
                        VStack(spacing: 16) {
                            Text("Recommended Doctors")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.recommendedDoctors, id: \.id) { doctor in
                                        RecommendedDoctorCard(doctor: doctor) {
                                            viewModel.showBookAppointment = true
                                            viewModel.selectedSpecialization = doctor.specialization
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                viewModel.isAnimating = true
            }
        }
        .sheet(isPresented: $viewModel.showBookAppointment) {
            BookAppointmentView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showMedicalHistory) {
            MedicalRecordsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showProfileSettings) {
            ProfileSettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAppointmentsList) {
            AppointmentListView(viewModel: viewModel)
        }
        .sheet(isPresented: $showHealthRecords) {
            HealthRecordsView(viewModel: viewModel)
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .navigationDestination(item: $viewModel.selectedAppointment) { appointment in
            AppointmentDetailView(viewModel: viewModel, appointment: appointment)
        }
    }
}


struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 16) {
            // Time indicator
            VStack(spacing: 4) {
                Text(appointment.date, format: .dateTime.day().month())
                    .font(.system(size: 14, weight: .semibold))
                Text(appointment.date, format: .dateTime.hour().minute())
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Appointment details
            VStack(alignment: .leading, spacing: 4) {
                if let doctor = DummyDataManager.shared.getDoctor(byId: appointment.doctorId) {
                    Text(doctor.name)
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.specialization.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status indicator
            StatusBadge(status: appointment.status)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05),
                        radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

struct StatusBadge: View {
    let status: AppointmentStatus
    
    var statusColor: Color {
        switch status {
        case .scheduled: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )
    }
}

struct ConditionCard: View {
    let condition: DiseaseSpecialization
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(condition.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            let doctors = DummyDataManager.shared.getDoctorsBySpecialization(condition)
            Text("\(doctors.count) Specialists Available")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05),
                        radius: 15, x: 0, y: 5)
        )
    }
}

struct RecommendedDoctorCard: View {
    let doctor: Doctor
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mainColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mainColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dr. \(doctor.name)")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(doctor.specialization.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label("\(doctor.rating, specifier: "%.1f")", systemImage: "star.fill")
                            .foregroundColor(.orange)
                        
                        Label("\(doctor.experience)+ years", systemImage: "clock.fill")
                            .foregroundColor(.green)
                    }
                    .font(.system(size: 12))
                }
            }
            .frame(width: 200)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
        }
    }
}

struct MedicalHistoryView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.patient.medicalHistory, id: \.self) { condition in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(condition.rawValue)
                            .font(.headline)
                        
                        let doctors = DummyDataManager.shared.getDoctorsBySpecialization(condition)
                        Text("\(doctors.count) Specialists Available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Medical History")
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

struct ProfileSettingsView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Information") {
                    DetailRow(title: "Name", value: viewModel.patient.name)
                    DetailRow(title: "Age", value: "\(viewModel.patient.age) years")
                    DetailRow(title: "Phone", value: viewModel.patient.phoneNumber)
                    DetailRow(title: "Email", value: viewModel.patient.email)
                }
                
                Section("Appointments") {
                    DetailRow(title: "Total", value: "\(viewModel.totalAppointments)")
                    DetailRow(title: "Completed", value: "\(viewModel.completedAppointments)")
                    DetailRow(title: "Upcoming", value: "\(viewModel.upcomingAppointmentsCount)")
                    DetailRow(title: "Cancelled", value: "\(viewModel.cancelledAppointmentsCount)")
                }
                
                Section("Medical History") {
                    ForEach(viewModel.patient.medicalHistory, id: \.self) { condition in
                        Text(condition.rawValue)
                    }
                }
            }
            .navigationTitle("Profile")
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

#Preview {
    PatientDashboard(patient: DummyDataManager.shared.patients[0])
} 
