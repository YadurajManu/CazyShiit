import SwiftUI

struct AppointmentListView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var searchText = ""
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    enum AppointmentFilter: String, CaseIterable {
        case all = "All"
        case upcoming = "Upcoming"
        case past = "Past"
        case cancelled = "Cancelled"
        
        var systemImage: String {
            switch self {
            case .all: return "calendar"
            case .upcoming: return "clock"
            case .past: return "checkmark.circle"
            case .cancelled: return "xmark.circle"
            }
        }
    }
    
    var filteredAppointments: [Appointment] {
        let appointments: [Appointment]
        switch selectedFilter {
        case .all:
            appointments = viewModel.patient.appointments
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
            if let doctor = viewModel.getDoctor(for: appointment) {
                return doctor.name.localizedCaseInsensitiveContains(searchText) ||
                    doctor.specialization.rawValue.localizedCaseInsensitiveContains(searchText)
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
                        
                        TextField("Search appointments...", text: $searchText)
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
                        message: "Try adjusting your filters or book a new appointment"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAppointments, id: \.id) { appointment in
                                AppointmentRow(viewModel: viewModel, appointment: appointment)
                                    .onTapGesture {
                                        viewModel.selectedAppointment = appointment
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
        }
    }
}

struct FilterPill: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? mainColor : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? mainColor : Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}