import Foundation


// MARK: - User Models
protocol DummyUser: Identifiable {
    var id: String { get }
    var name: String { get }
    var phoneNumber: String { get }
    var email: String { get }
    var password: String { get }
    var role: UserRole { get }
}

struct Doctor: DummyUser, Hashable {
    let id: String
    let name: String
    let phoneNumber: String
    let email: String
    let password: String
    let role: UserRole
    let specialization: DiseaseSpecialization
    let experience: Int
    let availability: [DayOfWeek: [TimeSlot]]
    let rating: Double
    
    // Implement Hashable manually since Dictionary isn't Hashable by default
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(phoneNumber)
        hasher.combine(email)
        hasher.combine(password)
        hasher.combine(role)
        hasher.combine(specialization)
        hasher.combine(experience)
        hasher.combine(rating)
    }
    
    static func == (lhs: Doctor, rhs: Doctor) -> Bool {
        lhs.id == rhs.id
    }
}

struct Patient: DummyUser, Hashable {
    let id: String
    let name: String
    let phoneNumber: String
    let email: String
    let password: String
    let role: UserRole
    let age: Int
    let medicalHistory: [DiseaseSpecialization]
    let appointments: [Appointment]
    
    // Implement Hashable manually since Array isn't Hashable by default
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(phoneNumber)
        hasher.combine(email)
        hasher.combine(password)
        hasher.combine(role)
        hasher.combine(age)
        hasher.combine(medicalHistory)
    }
    
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Supporting Types
enum DiseaseSpecialization: String, CaseIterable {
    case arthritis = "Arthritis"
    case brain = "Brain"
    case tumor = "Tumor"
    case lungCancer = "Lung Cancer"
    case diabeticRetinopathy = "Diabetic Retinopathy"
    case goiter = "Goiter"
}

enum DayOfWeek: String, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

struct TimeSlot: Hashable {
    let start: String
    let end: String
}

struct Appointment: Hashable {
    let id: String
    let doctorId: String
    let date: Date
    let status: AppointmentStatus
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(doctorId)
        hasher.combine(date)
        hasher.combine(status)
    }
    
    static func == (lhs: Appointment, rhs: Appointment) -> Bool {
        lhs.id == rhs.id
    }
}

enum AppointmentStatus: String {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Dummy Data Manager
class DummyDataManager {
    static let shared = DummyDataManager()
    
    private init() {}
    
    // Time slots for doctors
    let morningSlot = TimeSlot(start: "09:00", end: "12:00")
    let afternoonSlot = TimeSlot(start: "14:00", end: "17:00")
    let eveningSlot = TimeSlot(start: "18:00", end: "21:00")
    
    // Dummy Doctors
    lazy var doctors: [Doctor] = [
        // Arthritis Specialists
        Doctor(id: "D001", name: "Dr. Rahul Sharma", phoneNumber: "9876543210", 
               email: "rahul.sharma@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .arthritis, experience: 15,
               availability: defaultAvailability(), rating: 4.8),
        Doctor(id: "D002", name: "Dr. Priya Patel", phoneNumber: "9876543211",
               email: "priya.patel@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .arthritis, experience: 12,
               availability: defaultAvailability(), rating: 4.7),
        
        // Brain Specialists
        Doctor(id: "D003", name: "Dr. Amit Kumar", phoneNumber: "9876543212",
               email: "amit.kumar@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .brain, experience: 20,
               availability: defaultAvailability(), rating: 4.9),
        Doctor(id: "D004", name: "Dr. Sneha Reddy", phoneNumber: "9876543213",
               email: "sneha.reddy@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .brain, experience: 18,
               availability: defaultAvailability(), rating: 4.8),
        
        // Tumor Specialists
        Doctor(id: "D005", name: "Dr. Rajesh Gupta", phoneNumber: "9876543214",
               email: "rajesh.gupta@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .tumor, experience: 22,
               availability: defaultAvailability(), rating: 4.9),
        Doctor(id: "D006", name: "Dr. Meera Singh", phoneNumber: "9876543215",
               email: "meera.singh@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .tumor, experience: 16,
               availability: defaultAvailability(), rating: 4.7),
        
        // Lung Cancer Specialists
        Doctor(id: "D007", name: "Dr. Vikram Malhotra", phoneNumber: "9876543216",
               email: "vikram.malhotra@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .lungCancer, experience: 25,
               availability: defaultAvailability(), rating: 5.0),
        Doctor(id: "D008", name: "Dr. Anjali Desai", phoneNumber: "9876543217",
               email: "anjali.desai@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .lungCancer, experience: 19,
               availability: defaultAvailability(), rating: 4.8),
        
        // Diabetic Retinopathy Specialists
        Doctor(id: "D009", name: "Dr. Suresh Iyer", phoneNumber: "9876543218",
               email: "suresh.iyer@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .diabeticRetinopathy, experience: 17,
               availability: defaultAvailability(), rating: 4.6),
        Doctor(id: "D010", name: "Dr. Kavita Menon", phoneNumber: "9876543219",
               email: "kavita.menon@aiyush.com", password: "doctor123", role: .doctor,
               specialization: .diabeticRetinopathy, experience: 14,
               availability: defaultAvailability(), rating: 4.7)
    ]
    
    // Dummy Patients
    lazy var patients: [Patient] = [
        Patient(id: "P001", name: "Raj Malhotra", phoneNumber: "9898989801",
                email: "raj.malhotra@gmail.com", password: "patient123", role: .patient,
                age: 45, medicalHistory: [.arthritis], appointments: []),
        Patient(id: "P002", name: "Anita Shah", phoneNumber: "9898989802",
                email: "anita.shah@gmail.com", password: "patient123", role: .patient,
                age: 35, medicalHistory: [.brain], appointments: []),
        Patient(id: "P003", name: "Mohan Kumar", phoneNumber: "9898989803",
                email: "mohan.kumar@gmail.com", password: "patient123", role: .patient,
                age: 55, medicalHistory: [.tumor, .lungCancer], appointments: []),
        Patient(id: "P004", name: "Priya Sharma", phoneNumber: "9898989804",
                email: "priya.sharma@gmail.com", password: "patient123", role: .patient,
                age: 28, medicalHistory: [.diabeticRetinopathy], appointments: []),
        Patient(id: "P005", name: "Sanjay Verma", phoneNumber: "9898989805",
                email: "sanjay.verma@gmail.com", password: "patient123", role: .patient,
                age: 50, medicalHistory: [.goiter], appointments: [])
    ]
    
    private func defaultAvailability() -> [DayOfWeek: [TimeSlot]] {
        var availability: [DayOfWeek: [TimeSlot]] = [:]
        for day in DayOfWeek.allCases {
            availability[day] = [morningSlot, afternoonSlot, eveningSlot]
        }
        return availability
    }
    
    // Authentication Methods
    func authenticateUser(phoneNumber: String, password: String, role: UserRole) -> (Bool, String?) {
        switch role {
        case .doctor:
            if let doctor = doctors.first(where: { $0.phoneNumber == phoneNumber && $0.password == password }) {
                return (true, doctor.id)
            }
        case .patient:
            if let patient = patients.first(where: { $0.phoneNumber == phoneNumber && $0.password == password }) {
                return (true, patient.id)
            }
        }
        return (false, nil)
    }
    
    func getDoctor(byId id: String) -> Doctor? {
        doctors.first { $0.id == id }
    }
    
    func getPatient(byId id: String) -> Patient? {
        patients.first { $0.id == id }
    }
    
    func getDoctorsBySpecialization(_ specialization: DiseaseSpecialization) -> [Doctor] {
        doctors.filter { $0.specialization == specialization }
    }
} 
