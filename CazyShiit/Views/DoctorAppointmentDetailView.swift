import SwiftUI

struct DoctorAppointmentDetailView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @State private var showStatusActionSheet = false
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Patient Info Card
                    if let patient = viewModel.getPatient(for: appointment) {
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
                            
                            // Medical History
                            if !patient.medicalHistory.isEmpty {
                                VStack(spacing: 8) {
                                    Text("Medical History")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(patient.medicalHistory, id: \.self) { condition in
                                            Text(condition.rawValue)
                                                .font(.system(size: 12))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                        .shadow(color: mainColor.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                    }
                    
                    // Appointment Details
                    VStack(spacing: 20) {
                        DetailRow(title: "Date", value: appointment.date.formatted(date: .long, time: .omitted))
                        DetailRow(title: "Time", value: appointment.date.formatted(date: .omitted, time: .shortened))
                        DetailRow(title: "Status", value: appointment.status.rawValue, isStatus: true)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    if appointment.status == .scheduled {
                        VStack(spacing: 12) {
                            Button(action: { showStatusActionSheet = true }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Update Status")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(mainColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                viewModel.updateAppointmentStatus(appointment, to: .cancelled)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Cancel Appointment")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Appointment Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Update Status", isPresented: $showStatusActionSheet) {
                Button("Mark as Completed") {
                    viewModel.updateAppointmentStatus(appointment, to: .completed)
                    dismiss()
                }
                Button("Cancel Appointment", role: .destructive) {
                    viewModel.updateAppointmentStatus(appointment, to: .cancelled)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Update appointment status")
            }
        }
    }
}

// MARK: - Availability Settings View
struct AvailabilitySettingsView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDay: DayOfWeek = .monday
    @State private var selectedTimeSlots: Set<TimeSlot> = []
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Day Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                            DaySelectionButton(
                                day: day,
                                isSelected: selectedDay == day,
                                action: { selectedDay = day }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Time Slots
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Available Time Slots")
                            .font(.headline)
                        
                        let slots = viewModel.doctor.availability[selectedDay] ?? []
                        ForEach(slots, id: \.self) { slot in
                            TimeSlotToggle(
                                slot: slot,
                                isSelected: selectedTimeSlots.contains(slot),
                                action: {
                                    if selectedTimeSlots.contains(slot) {
                                        selectedTimeSlots.remove(slot)
                                    } else {
                                        selectedTimeSlots.insert(slot)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Availability")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateAvailability(for: selectedDay, timeSlots: Array(selectedTimeSlots))
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let slots = viewModel.doctor.availability[selectedDay] {
                    selectedTimeSlots = Set(slots)
                }
            }
            .onChange(of: selectedDay) { newDay in
                if let slots = viewModel.doctor.availability[newDay] {
                    selectedTimeSlots = Set(slots)
                } else {
                    selectedTimeSlots = []
                }
            }
        }
    }
}

struct DaySelectionButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            Text(day.rawValue)
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

struct TimeSlotToggle: View {
    let slot: TimeSlot
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(slot.start) - \(slot.end)")
                    .font(.system(size: 16))
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? mainColor : .secondary)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
} 