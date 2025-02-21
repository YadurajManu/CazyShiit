import SwiftUI

class DoctorDashboardViewModel: ObservableObject {
    @Published var doctor: Doctor
    @Published var isAnimating = false
    @Published var showAppointmentsList = false
    @Published var showProfileSettings = false
    @Published var searchText = ""
    @Published var selectedDate = Date()
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var selectedAppointment: Appointment?
    @Published var showAppointmentDetails = false
    @Published var isLoggedIn = true
    @Published var selectedTimeSlot: TimeSlot?
    @Published var selectedDayFilter: DayOfWeek?
    @Published var selectedPatient: Patient?
    @Published var showPatientDetails = false
    
    // Analytics Properties
    var completionRate: Int {
        let completed = completedAppointments
        let total = totalAppointments
        guard total > 0 else { return 0 }
        return Int((Double(completed) / Double(total)) * 100)
    }
    
    var patientGrowthRate: Double {
        // In a real app, this would calculate based on historical data
        return 12.0
    }
    
    var averageRating: Double {
        return doctor.rating
    }
    
    var monthlyStats: [(month: String, count: Int)] {
        // Sample monthly appointment statistics
        return [
            ("Jan", 45),
            ("Feb", 52),
            ("Mar", 58),
            ("Apr", 63),
            ("May", 70),
            ("Jun", 75)
        ]
    }
    
    // Patient Management
    var allPatients: [Patient] {
        let appointments = getAllAppointments()
        return DummyDataManager.shared.patients.filter { patient in
            patient.appointments.contains { appointment in
                appointments.contains { doctorAppointment in
                    doctorAppointment.id == appointment.id
                }
            }
        }
    }
    
    var recentPatients: [Patient] {
        return allPatients.prefix(5).map { $0 }
    }
    
    // Filtered and Sorted Appointments
    var todayAppointments: [Appointment] {
        getAllAppointments()
            .filter { appointment in
                Calendar.current.isDate(appointment.date, inSameDayAs: Date())
            }
            .sorted { $0.date < $1.date }
    }
    
    var upcomingAppointments: [Appointment] {
        getAllAppointments()
            .filter { appointment in
                appointment.status == .scheduled && appointment.date > Date()
            }
            .sorted { $0.date < $1.date }
    }
    
    var pastAppointments: [Appointment] {
        getAllAppointments()
            .filter { appointment in
                appointment.status == .completed || appointment.date < Date()
            }
            .sorted { $0.date > $1.date }
    }
    
    var cancelledAppointments: [Appointment] {
        getAllAppointments()
            .filter { $0.status == .cancelled }
            .sorted { $0.date > $1.date }
    }
    
    // Quick Stats
    var totalAppointments: Int {
        getAllAppointments().count
    }
    
    var completedAppointments: Int {
        getAllAppointments().filter { $0.status == .completed }.count
    }
    
    var todayAppointmentsCount: Int {
        todayAppointments.count
    }
    
    var upcomingAppointmentsCount: Int {
        upcomingAppointments.count
    }
    
    // Patient Statistics
    var patientsByCondition: [(condition: DiseaseSpecialization, count: Int)] {
        var countMap: [DiseaseSpecialization: Int] = [:]
        for patient in allPatients {
            for condition in patient.medicalHistory {
                countMap[condition, default: 0] += 1
            }
        }
        return countMap.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var patientAgeGroups: [(range: String, count: Int)] {
        var groups: [String: Int] = [
            "0-18": 0,
            "19-30": 0,
            "31-50": 0,
            "51+": 0
        ]
        
        for patient in allPatients {
            switch patient.age {
            case 0...18:
                groups["0-18"]? += 1
            case 19...30:
                groups["19-30"]? += 1
            case 31...50:
                groups["31-50"]? += 1
            default:
                groups["51+"]? += 1
            }
        }
        
        return groups.map { ($0.key, $0.value) }
            .sorted { $0.range < $1.range }
    }
    
    // Initialization
    init(doctor: Doctor) {
        self.doctor = doctor
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
        
        // Update doctor information
        let updatedDoctor = Doctor(
            id: doctor.id,
            name: name,
            phoneNumber: phone,
            email: email,
            password: doctor.password,
            role: doctor.role,
            specialization: doctor.specialization,
            experience: doctor.experience,
            availability: doctor.availability,
            rating: doctor.rating
        )
        
        // Update in DummyDataManager
        if let index = DummyDataManager.shared.doctors.firstIndex(where: { $0.id == doctor.id }) {
            DummyDataManager.shared.doctors[index] = updatedDoctor
            doctor = updatedDoctor
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
    
    func getAllAppointments() -> [Appointment] {
        // Get all patients
        let allPatients = DummyDataManager.shared.patients
        
        // Collect all appointments for this doctor
        return allPatients.flatMap { patient in
            patient.appointments.filter { $0.doctorId == doctor.id }
        }
    }
    
    func getPatient(for appointment: Appointment) -> Patient? {
        DummyDataManager.shared.patients.first { patient in
            patient.appointments.contains { $0.id == appointment.id }
        }
    }
    
    func updateAppointmentStatus(_ appointment: Appointment, to status: AppointmentStatus) {
        guard let patient = getPatient(for: appointment) else {
            showAlert("Patient not found")
            return
        }
        
        // Update the appointment status
        let updatedAppointments = patient.appointments.map { apt in
            if apt.id == appointment.id {
                return Appointment(
                    id: apt.id,
                    doctorId: apt.doctorId,
                    date: apt.date,
                    status: status
                )
            }
            return apt
        }
        
        // Create updated patient
        let updatedPatient = Patient(
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
        
        // Update in DummyDataManager
        if let index = DummyDataManager.shared.patients.firstIndex(where: { $0.id == patient.id }) {
            DummyDataManager.shared.patients[index] = updatedPatient
            showAlert("Appointment status updated successfully")
        }
    }
    
    func updateAvailability(for day: DayOfWeek, timeSlots: [TimeSlot]) {
        var updatedAvailability = doctor.availability
        updatedAvailability[day] = timeSlots
        
        let updatedDoctor = Doctor(
            id: doctor.id,
            name: doctor.name,
            phoneNumber: doctor.phoneNumber,
            email: doctor.email,
            password: doctor.password,
            role: doctor.role,
            specialization: doctor.specialization,
            experience: doctor.experience,
            availability: updatedAvailability,
            rating: doctor.rating
        )
        
        // Update in DummyDataManager
        if let index = DummyDataManager.shared.doctors.firstIndex(where: { $0.id == doctor.id }) {
            DummyDataManager.shared.doctors[index] = updatedDoctor
            doctor = updatedDoctor
            showAlert("Availability updated successfully")
        }
    }
    
    // MARK: - Patient Management
    
    func getPatientDetails(_ patient: Patient) -> (appointmentCount: Int, lastVisit: Date?, nextAppointment: Date?) {
        let patientAppointments = patient.appointments.filter { $0.doctorId == doctor.id }
        let lastVisit = patientAppointments
            .filter { $0.status == .completed }
            .sorted { $0.date > $1.date }
            .first?.date
        
        let nextAppointment = patientAppointments
            .filter { $0.status == .scheduled && $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first?.date
        
        return (patientAppointments.count, lastVisit, nextAppointment)
    }
    
    func searchPatients(_ query: String) -> [Patient] {
        if query.isEmpty {
            return allPatients
        }
        
        return allPatients.filter { patient in
            patient.name.localizedCaseInsensitiveContains(query) ||
            patient.medicalHistory.contains { condition in
                condition.rawValue.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    func getPatientName(for appointment: Appointment) -> String {
        if let patient = getPatient(for: appointment) {
            return patient.name
        }
        return "Unknown Patient"
    }
} 