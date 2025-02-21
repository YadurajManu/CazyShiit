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
    
    // MARK: - Health Records Data
    
    private var labResults: [String: [LabResult]] = [:]
    private var vaccinations: [String: [Vaccination]] = [:]
    private var prescriptions: [String: [Prescription]] = [:]
    private var medicalBills: [String: [MedicalBill]] = [:]
    
    func getLabResults(for patient: Patient) -> [LabResult] {
        if let results = labResults[patient.id] {
            return results
        }
        
        // Generate sample data for this patient
        let newResults = generateSampleLabResults(for: patient)
        labResults[patient.id] = newResults
        return newResults
    }
    
    func getVaccinations(for patient: Patient) -> [Vaccination] {
        if let records = vaccinations[patient.id] {
            return records
        }
        
        // Generate sample data for this patient
        let newRecords = generateSampleVaccinations(for: patient)
        vaccinations[patient.id] = newRecords
        return newRecords
    }
    
    func getPrescriptions(for patient: Patient) -> [Prescription] {
        if let records = prescriptions[patient.id] {
            return records
        }
        
        // Generate sample data for this patient
        let newRecords = generateSamplePrescriptions(for: patient)
        prescriptions[patient.id] = newRecords
        return newRecords
    }
    
    func getMedicalBills(for patient: Patient) -> [MedicalBill] {
        if let records = medicalBills[patient.id] {
            return records
        }
        
        // Generate sample data for this patient
        let newRecords = generateSampleMedicalBills(for: patient)
        medicalBills[patient.id] = newRecords
        return newRecords
    }
    
    // MARK: - Sample Data Generators
    
    private func generateSampleLabResults(for patient: Patient) -> [LabResult] {
        [
            LabResult(
                id: "LR001",
                testName: "Complete Blood Count",
                date: Date().addingTimeInterval(-7 * 24 * 3600),
                category: .blood,
                results: [
                    LabParameter(id: "P1", name: "Hemoglobin", value: "14.5", unit: "g/dL", referenceRange: "13.5-17.5", isNormal: true),
                    LabParameter(id: "P2", name: "WBC Count", value: "11.2", unit: "K/µL", referenceRange: "4.5-11.0", isNormal: false),
                    LabParameter(id: "P3", name: "Platelets", value: "250", unit: "K/µL", referenceRange: "150-450", isNormal: true)
                ],
                doctorId: "D001",
                reportURL: "report1.pdf",
                status: .completed
            ),
            LabResult(
                id: "LR002",
                testName: "Lipid Profile",
                date: Date().addingTimeInterval(-14 * 24 * 3600),
                category: .blood,
                results: [
                    LabParameter(id: "P4", name: "Total Cholesterol", value: "190", unit: "mg/dL", referenceRange: "<200", isNormal: true),
                    LabParameter(id: "P5", name: "HDL", value: "45", unit: "mg/dL", referenceRange: ">40", isNormal: true),
                    LabParameter(id: "P6", name: "LDL", value: "130", unit: "mg/dL", referenceRange: "<130", isNormal: true)
                ],
                doctorId: "D002",
                reportURL: "report2.pdf",
                status: .normal
            )
        ]
    }
    
    private func generateSampleVaccinations(for patient: Patient) -> [Vaccination] {
        [
            Vaccination(
                id: "V001",
                name: "COVID-19 Booster",
                date: Date().addingTimeInterval(-90 * 24 * 3600),
                dueDate: Date().addingTimeInterval(275 * 24 * 3600),
                status: .completed,
                provider: "City Hospital",
                batchNumber: "BT123456",
                notes: "Moderna Booster Shot"
            ),
            Vaccination(
                id: "V002",
                name: "Influenza",
                date: Date().addingTimeInterval(-180 * 24 * 3600),
                dueDate: Date().addingTimeInterval(185 * 24 * 3600),
                status: .upcoming,
                provider: "City Hospital",
                batchNumber: "FL789012",
                notes: "Annual Flu Shot"
            )
        ]
    }
    
    private func generateSamplePrescriptions(for patient: Patient) -> [Prescription] {
        [
            Prescription(
                id: "PR001",
                medications: [
                    Medication(
                        id: "M001",
                        name: "Amoxicillin",
                        dosage: "500mg",
                        frequency: "Twice daily",
                        timing: ["Morning", "Night"],
                        instructions: "Take with food"
                    )
                ],
                doctorId: "D001",
                date: Date().addingTimeInterval(-5 * 24 * 3600),
                duration: 7,
                notes: "Complete the full course",
                status: .active
            ),
            Prescription(
                id: "PR002",
                medications: [
                    Medication(
                        id: "M002",
                        name: "Paracetamol",
                        dosage: "650mg",
                        frequency: "As needed",
                        timing: ["When needed"],
                        instructions: "Take for fever or pain"
                    ),
                    Medication(
                        id: "M003",
                        name: "Cetirizine",
                        dosage: "10mg",
                        frequency: "Once daily",
                        timing: ["Night"],
                        instructions: "Take before bedtime"
                    )
                ],
                doctorId: "D002",
                date: Date().addingTimeInterval(-15 * 24 * 3600),
                duration: 5,
                notes: nil,
                status: .completed
            )
        ]
    }
    
    private func generateSampleMedicalBills(for patient: Patient) -> [MedicalBill] {
        [
            MedicalBill(
                id: "B001",
                date: Date().addingTimeInterval(-10 * 24 * 3600),
                amount: 2500.00,
                category: .consultation,
                status: .underInsurance,
                insuranceClaim: InsuranceClaim(
                    id: "IC001",
                    insuranceProvider: "Health Insurance Co.",
                    policyNumber: "POL123456",
                    claimAmount: 2000.00,
                    status: .underReview,
                    submissionDate: Date().addingTimeInterval(-9 * 24 * 3600),
                    approvalDate: nil,
                    coveragePercentage: 80
                ),
                itemizedCharges: [
                    BillItem(id: "BI001", description: "Consultation Fee", amount: 1500.00, quantity: 1, category: .consultation),
                    BillItem(id: "BI002", description: "Blood Test", amount: 1000.00, quantity: 1, category: .laboratory)
                ],
                doctorId: "D001"
            ),
            MedicalBill(
                id: "B002",
                date: Date().addingTimeInterval(-20 * 24 * 3600),
                amount: 1200.00,
                category: .medication,
                status: .paid,
                insuranceClaim: nil,
                itemizedCharges: [
                    BillItem(id: "BI003", description: "Antibiotics", amount: 800.00, quantity: 1, category: .medication),
                    BillItem(id: "BI004", description: "Pain Medication", amount: 400.00, quantity: 2, category: .medication)
                ],
                doctorId: "D002"
            )
        ]
    }
} 
