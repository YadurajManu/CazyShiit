import SwiftUI

class PatientDashboardViewModel: ObservableObject {
    @Published var patient: Patient
    @Published var isAnimating = false
    @Published var showBookAppointment = false
    @Published var showAppointmentsList = false
    @Published var showMedicalHistory = false
    @Published var showProfileSettings = false
    @Published var selectedSpecialization: DiseaseSpecialization?
    @Published var showDoctorsList = false
    @Published var searchText = ""
    @Published var selectedTimeSlot: TimeSlot?
    @Published var selectedDate = Date()
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var showAppointmentDetails = false
    @Published var selectedAppointment: Appointment?
    @Published var showRescheduleSheet = false
    @Published var showCancelConfirmation = false
    
    // Filtered and Sorted Appointments
    var upcomingAppointments: [Appointment] {
        patient.appointments
            .filter { appointment in
                appointment.status == .scheduled && appointment.date > Date()
            }
            .sorted { $0.date < $1.date }
    }
    
    var pastAppointments: [Appointment] {
        patient.appointments
            .filter { appointment in
                appointment.status == .completed || appointment.date < Date()
            }
            .sorted { $0.date > $1.date }
    }
    
    var cancelledAppointments: [Appointment] {
        patient.appointments
            .filter { $0.status == .cancelled }
            .sorted { $0.date > $1.date }
    }
    
    // Available Doctors
    var availableDoctors: [Doctor] {
        DummyDataManager.shared.doctors
            .filter { doctor in
                if let specialization = selectedSpecialization {
                    return doctor.specialization == specialization
                }
                return true
            }
            .filter { searchText.isEmpty || 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.specialization.rawValue.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.rating > $1.rating }
    }
    
    // Quick Stats
    var totalAppointments: Int {
        patient.appointments.count
    }
    
    var completedAppointments: Int {
        patient.appointments.filter { $0.status == .completed }.count
    }
    
    var upcomingAppointmentsCount: Int {
        upcomingAppointments.count
    }
    
    var cancelledAppointmentsCount: Int {
        cancelledAppointments.count
    }
    
    // Doctor Recommendations
    var recommendedDoctors: [Doctor] {
        // Get doctors based on patient's medical history
        let specializations = Set(patient.medicalHistory)
        return DummyDataManager.shared.doctors
            .filter { specializations.contains($0.specialization) }
            .sorted { $0.rating > $1.rating }
            .prefix(3)
            .map { $0 }
    }
    
    // Initialization
    init(patient: Patient) {
        self.patient = patient
        // Start the animation when the view model is initialized
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            self.isAnimating = true
        }
    }
    
    // MARK: - Actions
    
    func bookAppointment(with doctor: Doctor, date: Date, reason: String) {
        // Validate appointment time
        guard date > Date() else {
            showAlert("Please select a future date and time")
            return
        }
        
        // Check for conflicting appointments
        if hasConflictingAppointment(at: date) {
            showAlert("You already have an appointment at this time")
            return
        }
        
        // Create new appointment
        let newAppointment = Appointment(
            id: UUID().uuidString,
            doctorId: doctor.id,
            date: date,
            status: .scheduled
        )
        
        // Update patient's appointments
        var updatedAppointments = patient.appointments
        updatedAppointments.append(newAppointment)
        
        // Update patient
        updatePatient(appointments: updatedAppointments)
        
        showAlert("Appointment booked successfully!")
        showBookAppointment = false
    }
    
    func cancelAppointment(_ appointment: Appointment) {
        // Validate cancellation
        guard appointment.status == .scheduled else {
            showAlert("This appointment cannot be cancelled")
            return
        }
        
        guard appointment.date > Date() else {
            showAlert("Past appointments cannot be cancelled")
            return
        }
        
        // Update appointment status
        let updatedAppointments = patient.appointments.map { apt in
            if apt.id == appointment.id {
                return Appointment(
                    id: apt.id,
                    doctorId: apt.doctorId,
                    date: apt.date,
                    status: .cancelled
                )
            }
            return apt
        }
        
        // Update patient
        updatePatient(appointments: updatedAppointments)
        showAlert("Appointment cancelled successfully")
    }
    
    func rescheduleAppointment(_ appointment: Appointment, to newDate: Date) {
        // Validate rescheduling
        guard appointment.status == .scheduled else {
            showAlert("This appointment cannot be rescheduled")
            return
        }
        
        guard newDate > Date() else {
            showAlert("Please select a future date")
            return
        }
        
        guard !hasConflictingAppointment(at: newDate, excluding: appointment.id) else {
            showAlert("You already have an appointment at this time")
            return
        }
        
        // Update appointment
        let updatedAppointments = patient.appointments.map { apt in
            if apt.id == appointment.id {
                return Appointment(
                    id: apt.id,
                    doctorId: apt.doctorId,
                    date: newDate,
                    status: .scheduled
                )
            }
            return apt
        }
        
        // Update patient
        updatePatient(appointments: updatedAppointments)
        showAlert("Appointment rescheduled successfully")
        showRescheduleSheet = false
    }
    
    // MARK: - Helper Methods
    
    private func hasConflictingAppointment(at date: Date, excluding appointmentId: String? = nil) -> Bool {
        let calendar = Calendar.current
        return patient.appointments.contains { appointment in
            guard appointment.status == .scheduled else { return false }
            guard appointment.id != appointmentId else { return false }
            
            let appointmentDate = appointment.date
            let difference = calendar.dateComponents([.minute], from: appointmentDate, to: date)
            return abs(difference.minute ?? 0) < 30 // 30-minute buffer
        }
    }
    
    private func updatePatient(appointments: [Appointment]) {
        patient = Patient(
            id: patient.id,
            name: patient.name,
            phoneNumber: patient.phoneNumber,
            email: patient.email,
            password: patient.password,
            role: patient.role,
            age: patient.age,
            medicalHistory: patient.medicalHistory,
            appointments: appointments
        )
    }
    
    func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    func getDoctorName(for appointment: Appointment) -> String {
        if let doctor = DummyDataManager.shared.getDoctor(byId: appointment.doctorId) {
            return "Dr. \(doctor.name)"
        }
        return "Unknown Doctor"
    }
    
    func getDoctor(for appointment: Appointment) -> Doctor? {
        DummyDataManager.shared.getDoctor(byId: appointment.doctorId)
    }
} 