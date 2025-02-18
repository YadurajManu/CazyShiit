import SwiftUI

struct BookAppointmentView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedSpecialization: DiseaseSpecialization?
    @State private var selectedDoctor: Doctor?
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    private var filteredDoctors: [Doctor] {
        viewModel.availableDoctors.filter { doctor in
            let matchesSearch = searchText.isEmpty || 
                doctor.name.localizedCaseInsensitiveContains(searchText) ||
                doctor.specialization.rawValue.localizedCaseInsensitiveContains(searchText)
            
            let matchesSpecialization = selectedSpecialization == nil || 
                doctor.specialization == selectedSpecialization
            
            return matchesSearch && matchesSpecialization
        }
    }
    
    private var specializations: [DiseaseSpecialization] {
        DiseaseSpecialization.allCases.sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search doctors...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(specializations, id: \.self) { specialization in
                                SpecializationButton(
                                    title: specialization.rawValue,
                                    isSelected: selectedSpecialization == specialization,
                                    action: {
                                        if selectedSpecialization == specialization {
                                            selectedSpecialization = nil
                                        } else {
                                            selectedSpecialization = specialization
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                // Doctors List
                if filteredDoctors.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Doctors Found",
                        message: "Try adjusting your search or filters"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredDoctors, id: \.id) { doctor in
                                DoctorCard(doctor: doctor)
                                    .onTapGesture {
                                        selectedDoctor = doctor
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Book Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedDoctor) { doctor in
            AppointmentDetailsSheet(viewModel: viewModel, doctor: doctor)
        }
    }
}

struct SpecializationButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? mainColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? mainColor : Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct DoctorCard: View {
    let doctor: Doctor
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        HStack(spacing: 16) {
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
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    BookAppointmentView(viewModel: PatientDashboardViewModel(patient: DummyDataManager.shared.patients[0]))
} 