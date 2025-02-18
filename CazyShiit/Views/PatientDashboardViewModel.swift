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
    
    // Filtered and Sorted Appointments
    var upcomingAppointments: [Appointment] {
        patient.appointments.filter { appointment in
            appointment.status == .scheduled && appointment.date > Date()
        }.sorted { $0.date < $1.date }
    }
    
    var pastAppointments: [Appointment] {
        patient.appointments.filter { appointment in
            appointment.status == .completed || appointment.date < Date()
        }.sorted { $0.date > $1.date }
    }
    
    // Available Doctors
    var availableDoctors: [Doctor] {
        if let specialization = selectedSpecialization {
            return DummyDataManager.shared.getDoctorsBySpecialization(specialization)
                .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.rating > $1.rating }
        }
        return []
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
        // Create new appointment
        let newAppointment = Appointment(
            id: UUID().uuidString,
            doctorId: doctor.id,
            date: date,
            status: .scheduled
        )
        
        // Update patient's appointments
        // Note: In a real app, this would be handled by a backend service
        var updatedAppointments = patient.appointments
        updatedAppointments.append(newAppointment)
        
        // Update patient
        patient = Patient(
            id: patient.id,
            name: patient.name,
            phoneNumber: patient.phoneNumber,
            email: patient.email,
            password: patient.password,
            role: patient.role,
            age: patient.age,
            medicalHistory: patient.medicalHistory,
            appointments: updatedAppointments
        )
        
        showAlert("Appointment booked successfully!")
        showBookAppointment = false
    }
    
    func cancelAppointment(_ appointment: Appointment) {
        // Update appointment status
        // Note: In a real app, this would be handled by a backend service
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
        patient = Patient(
            id: patient.id,
            name: patient.name,
            phoneNumber: patient.phoneNumber,
            email: patient.email,
            password: patient.password,
            role: patient.role,
            age: patient.age,
            medicalHistory: patient.medicalHistory,
            appointments: updatedAppointments
        )
        
        showAlert("Appointment cancelled successfully")
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
} 