import SwiftUI

struct HealthRecordsView: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: RecordCategory = .labResults
    @State private var searchText = ""
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    enum RecordCategory: String, CaseIterable {
        case labResults = "Lab Results"
        case vaccinations = "Vaccinations"
        case prescriptions = "Prescriptions"
        case bills = "Bills & Claims"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search records...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    
                    // Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(RecordCategory.allCases, id: \.self) { category in
                                CategoryPill(
                                    title: category.rawValue,
                                    systemImage: iconFor(category),
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                // Records Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedCategory {
                        case .labResults:
                            LabResultsSection(viewModel: viewModel)
                        case .vaccinations:
                            VaccinationsSection(viewModel: viewModel)
                        case .prescriptions:
                            PrescriptionsSection(viewModel: viewModel)
                        case .bills:
                            BillsSection(viewModel: viewModel)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Health Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func iconFor(_ category: RecordCategory) -> String {
        switch category {
        case .labResults: return "flask"
        case .vaccinations: return "cross.vial"
        case .prescriptions: return "pills"
        case .bills: return "dollarsign.circle"
        }
    }
}

// MARK: - Supporting Views

struct CategoryPill: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? mainColor : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? mainColor : Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Section Views

struct LabResultsSection: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(LabResult.LabCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue)
                        .font(.headline)
                    
                    let results = DummyDataManager.shared.getLabResults(for: viewModel.patient)
                        .filter { $0.category == category }
                    
                    if results.isEmpty {
                        EmptyStateView(
                            icon: "flask",
                            title: "No \(category.rawValue) Results",
                            message: "Your lab results will appear here"
                        )
                    } else {
                        ForEach(results) { result in
                            LabResultCard(result: result)
                        }
                    }
                }
            }
        }
    }
}

struct VaccinationsSection: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let vaccinations = DummyDataManager.shared.getVaccinations(for: viewModel.patient)
            
            if vaccinations.isEmpty {
                EmptyStateView(
                    icon: "cross.vial",
                    title: "No Vaccination Records",
                    message: "Your vaccination records will appear here"
                )
            } else {
                ForEach(vaccinations) { vaccination in
                    VaccinationCard(vaccination: vaccination)
                }
            }
        }
    }
}

struct PrescriptionsSection: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let prescriptions = DummyDataManager.shared.getPrescriptions(for: viewModel.patient)
            
            if prescriptions.isEmpty {
                EmptyStateView(
                    icon: "pills",
                    title: "No Prescriptions",
                    message: "Your prescriptions will appear here"
                )
            } else {
                ForEach(prescriptions) { prescription in
                    PrescriptionCard(prescription: prescription, viewModel: viewModel)
                }
            }
        }
    }
}

struct BillsSection: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let bills = DummyDataManager.shared.getMedicalBills(for: viewModel.patient)
            
            if bills.isEmpty {
                EmptyStateView(
                    icon: "dollarsign.circle",
                    title: "No Medical Bills",
                    message: "Your medical bills and insurance claims will appear here"
                )
            } else {
                ForEach(bills) { bill in
                    BillCard(bill: bill, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Card Views

struct LabResultCard: View {
    let result: LabResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.testName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(result.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                MedicalStatusBadge(status: result.status.rawValue)
            }
            
            if !result.results.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(result.results) { parameter in
                        ParameterRow(parameter: parameter)
                    }
                }
            }
            
            if let url = result.reportURL {
                Button(action: {
                    // Handle report download/view
                }) {
                    Label("View Report", systemImage: "doc.text")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct ParameterRow: View {
    let parameter: LabParameter
    
    var body: some View {
        HStack {
            Text(parameter.name)
                .font(.system(size: 14))
            
            Spacer()
            
            Text("\(parameter.value) \(parameter.unit)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(parameter.isNormal ? .primary : .red)
            
            Text(parameter.referenceRange)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct VaccinationCard: View {
    let vaccination: Vaccination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccination.name)
                        .font(.system(size: 16, weight: .semibold))
                    Text(vaccination.provider)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                MedicalStatusBadge(status: vaccination.status.rawValue)
            }
            
            HStack {
                Label(vaccination.date.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                
                if let dueDate = vaccination.dueDate {
                    Label(dueDate.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar.badge.clock")
                        .foregroundColor(.orange)
                }
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            
            if let notes = vaccination.notes {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct PrescriptionCard: View {
    let prescription: Prescription
    let viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let doctor = viewModel.getDoctor(byId: prescription.doctorId) {
                        Text("Dr. \(doctor.name)")
                            .font(.system(size: 16, weight: .semibold))
                        Text(doctor.specialization.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                MedicalStatusBadge(status: prescription.status.rawValue)
            }
            
            Divider()
            
            ForEach(prescription.medications) { medication in
                MedicationRow(medication: medication)
            }
            
            if let notes = prescription.notes {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(prescription.date.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "calendar")
                
                Spacer()
                
                Label("\(prescription.duration) days", systemImage: "clock")
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(medication.name)
                .font(.system(size: 16, weight: .medium))
            
            HStack {
                Text(medication.dosage)
                Text("•")
                Text(medication.frequency)
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            
            if let instructions = medication.instructions {
                Text(instructions)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                ForEach(medication.timing, id: \.self) { time in
                    Text(time)
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

struct BillCard: View {
    let bill: MedicalBill
    let viewModel: PatientDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.category.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let doctorId = bill.doctorId,
                       let doctor = viewModel.getDoctor(byId: doctorId) {
                        Text("Dr. \(doctor.name)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                MedicalStatusBadge(status: bill.status.rawValue)
            }
            
            HStack {
                Text(bill.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("₹\(bill.amount, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
            }
            
            if let claim = bill.insuranceClaim {
                InsuranceClaimView(claim: claim)
            }
            
            if !bill.itemizedCharges.isEmpty {
                DisclosureGroup("View Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(bill.itemizedCharges) { item in
                            BillItemRow(item: item)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct InsuranceClaimView: View {
    let claim: InsuranceClaim
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insurance Claim")
                .font(.system(size: 14, weight: .medium))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(claim.insuranceProvider)
                        .font(.system(size: 14))
                    Text("Policy: \(claim.policyNumber)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                MedicalStatusBadge(status: claim.status.rawValue)
            }
            
            HStack {
                Text("Claim Amount: ₹\(claim.claimAmount, specifier: "%.2f")")
                Spacer()
                Text("Coverage: \(claim.coveragePercentage, specifier: "%.0f")%")
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct BillItemRow: View {
    let item: BillItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.description)
                    .font(.system(size: 14))
                Text(item.category.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(item.amount, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .medium))
                Text("Qty: \(item.quantity)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}