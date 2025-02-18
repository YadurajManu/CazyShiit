import SwiftUI

struct PatientDashboard: View {
    @StateObject private var viewModel: PatientDashboardViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    init(patient: Patient) {
        _viewModel = StateObject(wrappedValue: PatientDashboardViewModel(patient: patient))
    }
    
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
                                icon: "calendar.badge.plus",
                                color: mainColor
                            ) {
                                viewModel.showBookAppointment = true
                            }
                            
                            QuickActionButton(
                                title: "My\nAppointments",
                                icon: "list.clipboard",
                                color: secondaryColor
                            ) {
                                viewModel.showAppointmentsList = true
                            }
                            
                            QuickActionButton(
                                title: "Medical\nHistory",
                                icon: "heart.text.square",
                                color: Color(red: 0.6, green: 0.2, blue: 0.988)
                            ) {
                                viewModel.showMedicalHistory = true
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
                                AppointmentCard(appointment: appointment)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.cancelAppointment(appointment)
                                        } label: {
                                            Label("Cancel Appointment", systemImage: "xmark.circle")
                                        }
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
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
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
        .alert(viewModel.alertMessage, isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: color.opacity(0.1),
                        radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: color.opacity(0.1),
                            radius: 15, x: 0, y: 5)
            )
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05),
                        radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
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

#Preview {
    PatientDashboard(patient: DummyDataManager.shared.patients[0])
} 