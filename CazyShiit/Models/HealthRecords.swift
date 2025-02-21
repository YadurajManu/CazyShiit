import Foundation

// Lab Results
struct LabResult: Identifiable, Hashable {
    let id: String
    let testName: String
    let date: Date
    let category: LabCategory
    let results: [LabParameter]
    let doctorId: String
    let reportURL: String?
    let status: ResultStatus
    
    enum LabCategory: String, CaseIterable {
        case blood = "Blood Test"
        case urine = "Urine Test"
        case imaging = "Imaging"
        case cardiology = "Cardiology"
        case pathology = "Pathology"
    }
    
    enum ResultStatus: String {
        case pending = "Pending"
        case completed = "Completed"
        case abnormal = "Abnormal"
        case normal = "Normal"
    }
}

struct LabParameter: Identifiable, Hashable {
    let id: String
    let name: String
    let value: String
    let unit: String
    let referenceRange: String
    let isNormal: Bool
}

// Vaccination Records
struct Vaccination: Identifiable, Hashable {
    let id: String
    let name: String
    let date: Date
    let dueDate: Date?
    let status: VaccinationStatus
    let provider: String
    let batchNumber: String?
    let notes: String?
    
    enum VaccinationStatus: String {
        case completed = "Completed"
        case scheduled = "Scheduled"
        case overdue = "Overdue"
        case upcoming = "Upcoming"
    }
}

// Prescriptions
struct Prescription: Identifiable, Hashable {
    let id: String
    let medications: [Medication]
    let doctorId: String
    let date: Date
    let duration: Int // in days
    let notes: String?
    let status: PrescriptionStatus
    
    enum PrescriptionStatus: String {
        case active = "Active"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
}

struct Medication: Identifiable, Hashable {
    let id: String
    let name: String
    let dosage: String
    let frequency: String
    let timing: [String]
    let instructions: String?
}

// Medical Bills & Insurance
struct MedicalBill: Identifiable, Hashable {
    let id: String
    let date: Date
    let amount: Double
    let category: BillCategory
    let status: PaymentStatus
    let insuranceClaim: InsuranceClaim?
    let itemizedCharges: [BillItem]
    let doctorId: String?
    
    enum BillCategory: String {
        case consultation = "Consultation"
        case laboratory = "Laboratory"
        case medication = "Medication"
        case procedure = "Procedure"
        case hospitalization = "Hospitalization"
    }
    
    enum PaymentStatus: String {
        case pending = "Pending"
        case paid = "Paid"
        case partiallyPaid = "Partially Paid"
        case underInsurance = "Under Insurance"
        case declined = "Declined"
    }
}

struct BillItem: Identifiable, Hashable {
    let id: String
    let description: String
    let amount: Double
    let quantity: Int
    let category: MedicalBill.BillCategory
    
    // Implementing Hashable manually
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(description)
        hasher.combine(amount)
        hasher.combine(quantity)
        hasher.combine(category)
    }
    
    static func == (lhs: BillItem, rhs: BillItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.description == rhs.description &&
        lhs.amount == rhs.amount &&
        lhs.quantity == rhs.quantity &&
        lhs.category == rhs.category
    }
}

struct InsuranceClaim: Identifiable, Hashable {
    let id: String
    let insuranceProvider: String
    let policyNumber: String
    let claimAmount: Double
    let status: ClaimStatus
    let submissionDate: Date
    let approvalDate: Date?
    let coveragePercentage: Double
    
    enum ClaimStatus: String {
        case submitted = "Submitted"
        case underReview = "Under Review"
        case approved = "Approved"
        case rejected = "Rejected"
        case partiallyApproved = "Partially Approved"
    }
} 