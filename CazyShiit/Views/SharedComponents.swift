import SwiftUI

// MARK: - Status Badges
struct AppointmentStatusBadge: View {
    let status: AppointmentStatus
    
    var statusColor: Color {
        switch status {
        case .scheduled: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )
    }
}

struct MedicalStatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status.lowercased() {
        case "completed", "normal", "active": return .green
        case "pending", "scheduled", "under review": return .blue
        case "abnormal", "overdue", "rejected", "declined": return .red
        case "upcoming", "submitted": return .orange
        case "cancelled": return .gray
        case "under insurance", "partially approved": return .purple
        case "partially paid": return .indigo
        default: return .secondary
        }
    }
    
    var body: some View {
        Text(status)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )
    }
}

// MARK: - Appointment Row
struct AppointmentRow: View {
    @ObservedObject var viewModel: PatientDashboardViewModel
    let appointment: Appointment
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Column
            VStack(spacing: 4) {
                Text(appointment.date.formatted(.dateTime.day().month()))
                    .font(.system(size: 16, weight: .semibold))
                Text(appointment.date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            // Doctor Info
            if let doctor = viewModel.getDoctor(for: appointment) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dr. \(doctor.name)")
                        .font(.system(size: 16, weight: .semibold))
                    Text(doctor.specialization.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status Badge
            AppointmentStatusBadge(status: appointment.status)
                .opacity(0.8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
} 