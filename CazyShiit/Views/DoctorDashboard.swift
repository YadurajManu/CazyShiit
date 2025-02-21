import SwiftUI
import WebKit

struct DoctorDashboard: View {
    @StateObject private var viewModel: DoctorDashboardViewModel
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    init(doctor: Doctor) {
        _viewModel = StateObject(wrappedValue: DoctorDashboardViewModel(doctor: doctor))
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DoctorHomeView(viewModel: viewModel)
                    .tag(0)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                DoctorProfileView(viewModel: viewModel)
                    .tag(1)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            .navigationBarBackButtonHidden(true)
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if !isLoggedIn {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Doctor Home View
struct DoctorHomeView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @State private var showAvailabilitySettings = false
    @State private var showPatientsList = false
    @State private var showAnalytics = false
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Analytics Overview
                AnalyticsOverview(viewModel: viewModel)
                
                // Quick Stats Cards
                QuickStatsView(viewModel: viewModel)
                
                // Today's Schedule
                TodayScheduleView(viewModel: viewModel)
                
                // Quick Actions Grid
                QuickActionsGrid(
                    viewModel: viewModel,
                    showAvailabilitySettings: $showAvailabilitySettings,
                    showPatientsList: $showPatientsList,
                    showAnalytics: $showAnalytics
                )
                
                // Upcoming Appointments
                UpcomingAppointmentsView(viewModel: viewModel)
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Welcome, Dr. \(viewModel.doctor.name)")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showAppointmentsList) {
            DoctorAppointmentListView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAvailabilitySettings) {
            AvailabilitySettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showPatientsList) {
            PatientListView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsDetailView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showAppointmentDetails) {
            if let appointment = viewModel.selectedAppointment {
                DoctorAppointmentDetailView(viewModel: viewModel, appointment: appointment)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

// MARK: - Analytics Overview
struct AnalyticsOverview: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analytics Overview")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Show detailed analytics
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    AnalyticCard(
                        title: "Patient Growth",
                        value: "+12%",
                        trend: "↑",
                        color: .green
                    )
                    
                    AnalyticCard(
                        title: "Avg. Rating",
                        value: String(format: "%.1f", viewModel.doctor.rating),
                        trend: "↑",
                        color: .orange
                    )
                    
                    AnalyticCard(
                        title: "Completion Rate",
                        value: "\(viewModel.completionRate)%",
                        trend: "→",
                        color: .blue
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Quick Actions Grid
struct QuickActionsGrid: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    @Binding var showAvailabilitySettings: Bool
    @Binding var showPatientsList: Bool
    @Binding var showAnalytics: Bool
    @State private var showMLTest = false
    
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "Manage\nAvailability",
                    systemImage: "clock.fill",
                    color: mainColor,
                    action: { showAvailabilitySettings = true }
                )
                
                QuickActionButton(
                    title: "View\nAppointments",
                    systemImage: "calendar.badge.clock",
                    color: secondaryColor,
                    action: { viewModel.showAppointmentsList = true }
                )
                
                QuickActionButton(
                    title: "Patient\nRecords",
                    systemImage: "folder.fill",
                    color: .purple,
                    action: { showPatientsList = true }
                )
                
                QuickActionButton(
                    title: "Analytics\n& Reports",
                    systemImage: "chart.bar.fill",
                    color: .orange,
                    action: { showAnalytics = true }
                )
                
                QuickActionButton(
                    title: "Run Retina\nTest",
                    systemImage: "eye.fill",
                    color: .red,
                    action: { showMLTest = true }
                )
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showMLTest) {
            RetinaMLTestView()
        }
    }
}

// MARK: - Analytic Card
struct AnalyticCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                
                Text(trend)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
        }
        .padding()
        .frame(width: 140)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    private let secondaryColor = Color(red: 0.2, green: 0.851, blue: 0.4)
    
    var body: some View {
        HStack(spacing: 16) {
            StatsCard(
                title: "Today's Appointments",
                value: "\(viewModel.todayAppointmentsCount)",
                icon: "calendar",
                color: mainColor
            )
            
            StatsCard(
                title: "Completed",
                value: "\(viewModel.completedAppointments)",
                icon: "checkmark.circle",
                color: secondaryColor
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Today's Schedule View
struct TodayScheduleView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    private let mainColor = Color(red: 0.0, green: 0.478, blue: 0.988)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Schedule")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    viewModel.showAppointmentsList = true
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mainColor)
                }
            }
            .padding(.horizontal)
            
            if viewModel.todayAppointments.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Appointments Today",
                    message: "Your schedule is clear for today"
                )
            } else {
                ForEach(viewModel.todayAppointments, id: \.id) { appointment in
                    DoctorAppointmentRow(viewModel: viewModel, appointment: appointment)
                        .onTapGesture {
                            viewModel.selectedAppointment = appointment
                            viewModel.showAppointmentDetails = true
                        }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Upcoming Appointments View
struct UpcomingAppointmentsView: View {
    @ObservedObject var viewModel: DoctorDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Appointments")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.upcomingAppointments.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Upcoming Appointments",
                    message: "You have no scheduled appointments"
                )
            } else {
                ForEach(viewModel.upcomingAppointments.prefix(3), id: \.id) { appointment in
                    DoctorAppointmentRow(viewModel: viewModel, appointment: appointment)
                        .onTapGesture {
                            viewModel.selectedAppointment = appointment
                            viewModel.showAppointmentDetails = true
                        }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: color.opacity(0.1), radius: 15)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct RetinaMLTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var predictionResult: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .frame(height: 200)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            showCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Gallery")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if let result = predictionResult {
                        VStack(spacing: 12) {
                            Text("Analysis Result")
                                .font(.headline)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(getResultColor(result))
                                    .frame(width: 12, height: 12)
                                
                                Text(result)
                                    .font(.system(size: 18, weight: .medium))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.top)
                    }
                    
                    Button(action: {
                        analyzeImage()
                    }) {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isAnalyzing ? "Analyzing..." : "Analyze Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedImage != nil ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedImage == nil || isAnalyzing)
                    
                    if let result = predictionResult {
                        VStack(spacing: 16) {
                            Text("Recommendations")
                                .font(.headline)
                            
                            Text(getRecommendation(for: result))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Retina Disease Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $selectedImage)
            }
        }
    }
    
    private func analyzeImage() {
        guard selectedImage != nil else { return }
        isAnalyzing = true
        
        // Simulate ML analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let results = ["MILD", "MODERATE", "No diabetic retinopathy", "Proliferative DR", "SEVERE"]
            predictionResult = results.randomElement()
            isAnalyzing = false
        }
    }
    
    private func getResultColor(_ result: String) -> Color {
        switch result.lowercased() {
        case "mild":
            return .yellow
        case "moderate":
            return .orange
        case "severe":
            return .red
        case "proliferative dr":
            return .purple
        default:
            return .green
        }
    }
    
    private func getRecommendation(for result: String) -> String {
        switch result.lowercased() {
        case "mild":
            return "Regular monitoring recommended. Schedule follow-up in 6-12 months."
        case "moderate":
            return "Requires attention. Schedule follow-up within 3-6 months and consider treatment options."
        case "severe":
            return "Immediate attention required. Schedule comprehensive examination and begin treatment plan."
        case "proliferative dr":
            return "URGENT: Immediate treatment required. High risk of vision loss. Schedule treatment immediately."
        default:
            return "No signs of diabetic retinopathy detected. Continue regular annual screenings."
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
