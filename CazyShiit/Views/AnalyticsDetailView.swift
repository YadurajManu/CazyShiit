import SwiftUI
import Charts

struct AnalyticsDetailView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        AnalyticCard(
                            title: "Total Patients",
                            value: "\(viewModel.allPatients.count)",
                            trend: "↑",
                            color: mainColor
                        )
                        
                        AnalyticCard(
                            title: "Completion Rate",
                            value: "\(viewModel.completionRate)%",
                            trend: "→",
                            color: secondaryColor
                        )
                        
                        AnalyticCard(
                            title: "Avg. Rating",
                            value: String(format: "%.1f", viewModel.doctor.rating),
                            trend: "↑",
                            color: .orange
                        )
                        
                        AnalyticCard(
                            title: "Growth Rate",
                            value: String(format: "+%.1f%%", viewModel.patientGrowthRate),
                            trend: "↑",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Monthly Appointments Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Monthly Appointments")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(viewModel.monthlyStats, id: \.month) { stat in
                                BarMark(
                                    x: .value("Month", stat.month),
                                    y: .value("Count", stat.count)
                                )
                                .foregroundStyle(mainColor.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Patient Demographics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Patient Demographics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Age Distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age Distribution")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(viewModel.patientAgeGroups, id: \.range) { group in
                                HStack {
                                    Text(group.range)
                                        .font(.system(size: 14))
                                    
                                    Spacer()
                                    
                                    Text("\(group.count)")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                        
                        // Medical Conditions Distribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Conditions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(viewModel.patientsByCondition, id: \.condition) { stat in
                                HStack {
                                    Text(stat.condition.rawValue)
                                        .font(.system(size: 14))
                                    
                                    Spacer()
                                    
                                    Text("\(stat.count)")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Appointment Status Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appointment Status")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            StatusCard(
                                title: "Completed",
                                count: viewModel.completedAppointments,
                                color: .green
                            )
                            
                            StatusCard(
                                title: "Upcoming",
                                count: viewModel.upcomingAppointmentsCount,
                                color: mainColor
                            )
                            
                            StatusCard(
                                title: "Cancelled",
                                count: viewModel.cancelledAppointments.count,
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
} 