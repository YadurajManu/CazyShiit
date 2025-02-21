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
    @Published var isLoggedIn = true
    
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
    
    // MARK: - Profile Management
    
    func updateProfile(name: String, email: String, phone: String) -> Bool {
        // Validate input
        guard !name.isEmpty && !email.isEmpty && !phone.isEmpty else {
            showAlert("All fields are required")
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            showAlert("Please enter a valid email address")
            return false
        }
        
        guard phone.count == 10 && phone.allSatisfy({ $0.isNumber }) else {
            showAlert("Please enter a valid 10-digit phone number")
            return false
        }
        
        // Update patient information
        let updatedPatient = Patient(
            id: patient.id,
            name: name,
            phoneNumber: phone,
            email: email,
            password: patient.password,
            role: patient.role,
            age: patient.age,
            medicalHistory: patient.medicalHistory,
            appointments: patient.appointments
        )
        
        // Update in DummyDataManager
        if let index = DummyDataManager.shared.patients.firstIndex(where: { $0.id == patient.id }) {
            DummyDataManager.shared.patients[index] = updatedPatient
            patient = updatedPatient
            showAlert("Profile updated successfully")
            return true
        }
        
        showAlert("Failed to update profile")
        return false
    }
    
    // MARK: - Authentication
    
    func logout() {
        // Clear user data
        isLoggedIn = false
        // Additional cleanup if needed
    }
    
    // MARK: - Appointment Management
    
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
        
        // Update doctor's schedule (in a real app, this would be handled by the backend)
        if let doctorIndex = DummyDataManager.shared.doctors.firstIndex(where: { $0.id == doctor.id }) {
            // Here we would update the doctor's availability
            // For now, we'll just show a success message
            showAlert("Appointment booked successfully!")
            showBookAppointment = false
        }
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
        
        // Update in DummyDataManager
        if let index = DummyDataManager.shared.patients.firstIndex(where: { $0.id == patient.id }) {
            DummyDataManager.shared.patients[index] = patient
        }
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
    
    // MARK: - Health Records Management
    
    // Lab Results
    func getLabResults() -> [LabResult] {
        DummyDataManager.shared.getLabResults(for: patient)
    }
    
    func getLabResults(for category: LabResult.LabCategory) -> [LabResult] {
        getLabResults().filter { $0.category == category }
    }
    
    // Vaccinations
    func getVaccinations() -> [Vaccination] {
        DummyDataManager.shared.getVaccinations(for: patient)
    }
    
    func getUpcomingVaccinations() -> [Vaccination] {
        getVaccinations().filter { $0.status == .upcoming }
    }
    
    func getOverdueVaccinations() -> [Vaccination] {
        getVaccinations().filter { $0.status == .overdue }
    }
    
    // Prescriptions
    func getPrescriptions() -> [Prescription] {
        DummyDataManager.shared.getPrescriptions(for: patient)
    }
    
    func getActivePrescriptions() -> [Prescription] {
        getPrescriptions().filter { $0.status == .active }
    }
    
    func getPrescriptionsByDoctor(doctorId: String) -> [Prescription] {
        getPrescriptions().filter { $0.doctorId == doctorId }
    }
    
    // Medical Bills
    func getMedicalBills() -> [MedicalBill] {
        DummyDataManager.shared.getMedicalBills(for: patient)
    }
    
    func getPendingBills() -> [MedicalBill] {
        getMedicalBills().filter { $0.status == .pending || $0.status == .underInsurance }
    }
    
    func getBillsByCategory(_ category: MedicalBill.BillCategory) -> [MedicalBill] {
        getMedicalBills().filter { $0.category == category }
    }
    
    // Health Records Stats
    var healthRecordsStats: (labResults: Int, vaccinations: Int, prescriptions: Int, bills: Int) {
        (
            labResults: getLabResults().count,
            vaccinations: getVaccinations().count,
            prescriptions: getPrescriptions().count,
            bills: getMedicalBills().count
        )
    }
    
    var pendingActionsCount: Int {
        getOverdueVaccinations().count +
        getPendingBills().count
    }
    
    // Doctor Helper
    func getDoctor(byId id: String) -> Doctor? {
        DummyDataManager.shared.getDoctor(byId: id)
    }
} 