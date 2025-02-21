import SwiftUI

struct DoctorAppointmentListView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var searchText = ""
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    enum AppointmentFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case past = "Past"
        case cancelled = "Cancelled"
        
        var systemImage: String {
            switch self {
            case .all: return "calendar"
            case .today: return "clock"
            case .upcoming: return "calendar.badge.plus"
            case .past: return "checkmark.circle"
            case .cancelled: return "xmark.circle"
            }
        }
    }
    
    var filteredAppointments: [Appointment] {
        let appointments: [Appointment]
        switch selectedFilter {
        case .all:
            appointments = viewModel.getAllAppointments()
        case .today:
            appointments = viewModel.todayAppointments
        case .upcoming:
            appointments = viewModel.upcomingAppointments
        case .past:
            appointments = viewModel.pastAppointments
        case .cancelled:
            appointments = viewModel.cancelledAppointments
        }
        
        if searchText.isEmpty {
            return appointments
        }
        
        return appointments.filter { appointment in
            if let patient = viewModel.getPatient(for: appointment) {
                return patient.name.localizedCaseInsensitiveContains(searchText)
            }
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search patients...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                                FilterPill(
                                    title: filter.rawValue,
                                    systemImage: filter.systemImage,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                // Appointments List
                if filteredAppointments.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        title: "No Appointments Found",
                        message: "No appointments match your current filters"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAppointments, id: \.id) { appointment in
                                DoctorAppointmentRow(viewModel: viewModel, appointment: appointment)
                                    .onTapGesture {
                                        viewModel.selectedAppointment = appointment
                                        viewModel.showAppointmentDetails = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAppointmentDetails) {
                if let appointment = viewModel.selectedAppointment {
                    DoctorAppointmentDetailView(viewModel: viewModel, appointment: appointment)
                }
            }
        }
    }
}

struct DoctorAppointmentRow: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    let appointment: Appointment
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Column
            VStack(spacing: 4) {
                Text(appointment.date.formatted(.dateTime.day().month()))
                    .font(.system(size: 16, weight: .semibold))
                Text(appointment.date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            // Patient Info
            if let patient = viewModel.getPatient(for: appointment) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.system(size: 16, weight: .semibold))
                    Text("Age: \(patient.age)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Badge
            AppointmentStatusBadge(status: appointment.status)
                .opacity(0.8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
} 