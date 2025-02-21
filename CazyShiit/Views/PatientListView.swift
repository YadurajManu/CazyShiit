import SwiftUI

struct PatientListView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var filteredPatients: [Patient] {
        viewModel.searchPatients(searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search patients...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                // Patient List
                if filteredPatients.isEmpty {
                    EmptyStateView(
                        icon: "person.2.slash",
                        title: "No Patients Found",
                        message: "Try adjusting your search"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPatients, id: \.id) { patient in
                                PatientCard(viewModel: viewModel, patient: patient)
                                    .onTapGesture {
                                        viewModel.selectedPatient = patient
                                        viewModel.showPatientDetails = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Patients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPatientDetails) {
                if let patient = viewModel.selectedPatient {
                    PatientDetailView(viewModel: viewModel, patient: patient)
                }
            }
        }
    }
}

struct PatientCard: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    let patient: Patient
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        let details = viewModel.getPatientDetails(patient)
        
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Patient Avatar
                ZStack {
                    Circle()
                        .fill(mainColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mainColor)
                }
                
                // Patient Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Age: \(patient.age)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if let lastVisit = details.lastVisit {
                        Text("Last Visit: \(lastVisit.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Visit Count
                VStack(spacing: 4) {
                    Text("\(details.appointmentCount)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(mainColor)
                    
                    Text("Visits")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // Medical Conditions
            if !patient.medicalHistory.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(patient.medicalHistory, id: \.self) { condition in
                            Text(condition.rawValue)
                                .font(.system(size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(mainColor.opacity(0.1))
                                .foregroundColor(mainColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PatientDetailView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    let patient: Patient
    @Environment(\.dismiss) private var dismiss
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Patient Info Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(mainColor.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                        }
                        
                        VStack(spacing: 8) {
                            Text(patient.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Age: \(patient.age)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(patient.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    
                    // Medical History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Medical History")
                            .font(.headline)
                        
                        ForEach(patient.medicalHistory, id: \.self) { condition in
                            HStack {
                                Text(condition.rawValue)
                                    .font(.system(size: 16))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    
                    // Appointment History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appointment History")
                            .font(.headline)
                        
                        let appointments = patient.appointments
                            .filter { $0.doctorId == viewModel.doctor.id }
                            .sorted { $0.date > $1.date }
                        
                        if appointments.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No Appointments",
                                message: "No appointment history found"
                            )
                        } else {
                            ForEach(appointments, id: \.id) { appointment in
                                DoctorAppointmentRow(viewModel: viewModel, appointment: appointment)
                                    .onTapGesture {
                                        viewModel.selectedAppointment = appointment
                                        viewModel.showAppointmentDetails = true
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Patient Details")
            .navigationBarTitleDisplayMode(.inline)
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