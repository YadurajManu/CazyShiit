import SwiftUI

struct MedicalRecordsView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCondition: DiseaseSpecialization?
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Conditions",
                            value: "\(viewModel.patient.medicalHistory.count)",
                            icon: "heart.text.square",
                            color: mainColor
                        )
                        
                        StatCard(
                            title: "Appointments",
                            value: "\(viewModel.totalAppointments)",
                            icon: "calendar",
                            color: Color(red: 0.2, green: 0.851, blue: 0.4)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Medical Conditions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Medical Conditions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.patient.medicalHistory, id: \.self) { condition in
                            ConditionDetailCard(
                                viewModel: viewModel,
                                condition: condition,
                                isSelected: selectedCondition == condition,
                                doctors: DummyDataManager.shared.getDoctorsBySpecialization(condition),
                                action: {
                                    if selectedCondition == condition {
                                        selectedCondition = nil
                                    } else {
                                        selectedCondition = condition
                                    }
                                }
                            )
                        }
                    }
                    
                    // Treatment History
                    if let condition = selectedCondition {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Treatment History")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            let appointments = viewModel.patient.appointments.filter { appointment in
                                if let doctor = viewModel.getDoctor(for: appointment) {
                                    return doctor.specialization == condition
                                }
                                return false
                            }
                            
                            if appointments.isEmpty {
                                EmptyStateView(
                                    icon: "clipboard",
                                    title: "No Treatment History",
                                    message: "Book an appointment with a specialist"
                                )
                            } else {
                                ForEach(appointments, id: \.id) { appointment in
                                    AppointmentRow(viewModel: viewModel, appointment: appointment)
                                        .onTapGesture {
                                            viewModel.selectedAppointment = appointment
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Medical Records")
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

struct StatCard: View {
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
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: color.opacity(0.1),
                        radius: 15, x: 0, y: 5)
        )
    }
}

struct ConditionDetailCard: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    let condition: DiseaseSpecialization
    let isSelected: Bool
    let doctors: [Doctor]
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(condition.rawValue)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("\(doctors.count) Specialists Available")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isSelected ? 90 : 0))
                }
                
                if isSelected {
                    // Top Specialists
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Specialists")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ForEach(doctors.prefix(3), id: \.id) { doctor in
                            HStack {
                                Text("Dr. \(doctor.name)")
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Label("\(doctor.rating, specifier: "%.1f")", systemImage: "star.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Button(action: {
                            viewModel.selectedSpecialization = condition
                            viewModel.showBookAppointment = true
                            dismiss()
                        }) {
                            Text("Book Appointment")
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(mainColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
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
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
} 