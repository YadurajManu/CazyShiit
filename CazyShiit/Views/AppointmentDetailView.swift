import SwiftUI

struct AppointmentDetailView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @State private var showRescheduleSheet = false
    @State private var showCancelConfirmation = false
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Doctor Info Card
                if let doctor = viewModel.getDoctor(for: appointment) {
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
                            Text("Dr. \(doctor.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(doctor.specialization.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                Label("\(doctor.rating, specifier: "%.1f")", systemImage: "star.fill")
                                    .foregroundColor(.orange)
                                
                                Label("\(doctor.experience)+ years", systemImage: "clock.fill")
                                    .foregroundColor(.green)
                            }
                            .font(.system(size: 14))
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                    .shadow(color: mainColor.opacity(0.1), radius: 10)
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
                
                // Action Buttons
                if appointment.status == .scheduled && appointment.date > Date() {
                    VStack(spacing: 12) {
                        Button(action: { showRescheduleSheet = true }) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Reschedule Appointment")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mainColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showCancelConfirmation = true }) {
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
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Appointment Details")
        .sheet(isPresented: $showRescheduleSheet) {
            RescheduleSheet(viewModel: viewModel, appointment: appointment)
        }
        .alert("Cancel Appointment", isPresented: $showCancelConfirmation) {
            Button("Cancel Appointment", role: .destructive) {
                viewModel.cancelAppointment(appointment)
                dismiss()
            }
            Button("Keep Appointment", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this appointment? This action cannot be undone.")
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var isStatus: Bool = false
    
    var statusColor: Color {
        switch value.lowercased() {
        case "scheduled": return .blue
        case "completed": return .green
        case "cancelled": return .red
        default: return .secondary
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if isStatus {
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(statusColor.opacity(0.1))
                    )
            } else {
                Text(value)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

struct RescheduleSheet: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedTime: Date?
    
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
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select New Date")
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
                        Text("Select New Time")
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
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Reschedule Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Reschedule") {
                        rescheduleAppointment()
                    }
                    .disabled(selectedTime == nil)
                }
            }
        }
    }
    
    private func rescheduleAppointment() {
        guard let time = selectedTime else { return }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let newDate = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                        minute: timeComponents.minute ?? 0,
                                        second: 0,
                                        of: selectedDate) else {
            return
        }
        
        viewModel.rescheduleAppointment(appointment, to: newDate)
        dismiss()
    }
} 