import SwiftUI

struct AppointmentDetailsSheet: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    let doctor: Doctor
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedTime: Date?
    @State private var reason = ""
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let timeSlots: [Date] = {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        
        return stride(from: 0, to: 16, by: 1).compactMap { hour in
            calendar.date(byAdding: .hour, value: hour, to: startTime)
        }
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Doctor Info Card
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor)
                        
                        Text("Dr. \(doctor.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(doctor.specialization.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    .shadow(color: mainColor.opacity(0.1), radius: 10)
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date")
                            .font(.headline)
                        
                        DatePicker(
                            "Appointment Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(mainColor)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Time")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(timeSlots, id: \.self) { time in
                                    TimeSlotButton(
                                        time: time,
                                        isSelected: time == selectedTime,
                                        action: { selectedTime = time }
                                    )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    
                    // Reason for Visit
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reason for Visit")
                            .font(.headline)
                        
                        TextEditor(text: $reason)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                }
                .padding()
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
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Book") {
                        bookAppointment()
                    }
                    .disabled(selectedTime == nil || reason.isEmpty)
                }
            }
        }
    }
    
    private func bookAppointment() {
        guard let time = selectedTime else { return }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let appointmentDate = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                minute: timeComponents.minute ?? 0,
                                                second: 0,
                                                of: selectedDate) else {
            return
        }
        
        viewModel.bookAppointment(
            with: doctor,
            date: appointmentDate,
            reason: reason
        )
        
        dismiss()
    }
}

struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            Text(time, style: .time)
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