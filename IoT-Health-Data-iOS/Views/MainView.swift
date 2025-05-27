import SwiftUI

struct MainView: View {
    @ObservedObject var appState: AppState
    @StateObject var viewModel: ProjectViewModel

    @State private var selectedProject: ProjectSimpleResponse?
    @State private var showProjectInfo = false

    @State private var agreePrivacyPolicy = false
    @State private var agreeTermsOfService = false
    @State private var agreeConsentOfHealthData = false
    @State private var agreeLocationDataTermsOfService = false

    @State private var selectedTab = 0
    @State private var hasSentHealthData = false

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: ProjectViewModel(appState: appState))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button("Logout") {
                        appState.logout()
                    }
                    .foregroundColor(.red)
                    .padding()
                }

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Selection")
                        .font(.headline)

                    HStack(spacing: 10) {
                        Picker("Select Project", selection: $selectedProject) {
                            Text("Please select a project.").tag(Optional<ProjectSimpleResponse>.none)
                            ForEach(viewModel.projectList) { project in
                                Text(project.projectTitle).tag(Optional(project))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                        .padding(.horizontal)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .disabled(viewModel.isRegisted)

                        if let project = selectedProject {
                            Button {
                                Task {
                                    await viewModel.getProjectInfo(projectId: project.projectId)
                                    if viewModel.info != nil {
                                        showProjectInfo = true
                                    }
                                }
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 4)
                        }
                    }

                    .sheet(isPresented: $showProjectInfo) {
                        if let info = viewModel.info {
                            VStack {
                                Picker("Tab", selection: $selectedTab) {
                                    Text("Project").tag(0)
                                    Text("Personal Info").tag(1)
                                    Text("Health Data").tag(2)
                                    Text("Air Quality Data").tag(3)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()

                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        switch selectedTab {
                                        case 0:
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(info.projectTitle).font(.title2).bold()
                                                Text("Owner: \(info.pmEmail)")
                                                Text("Reg Date: \(info.createdAt)")
                                                Text("From: \(info.startDate)")
                                                Text("To: \(info.endDate)")
                                                Text("Participants: \(info.participant)")
                                                Text("Description: \(info.description)")
                                            }
                                        case 1:
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Collected Personal Information").font(.headline)
                                                checkmarkList(info: info, keys: [
                                                    ("Email", info.email),
                                                    ("Gender", info.gender),
                                                    ("Phone Number", info.phoneNumber),
                                                    ("Date of Birth", info.dateOfBirth),
                                                    ("Blood Type", info.bloodType),
                                                    ("Height", info.height),
                                                    ("Weight", info.weight),
                                                    ("Name", info.name)
                                                ])
                                            }
                                        case 2:
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Collected Health Data").font(.headline)
                                                checkmarkList(info: info, keys: [
                                                    ("Step Count", info.stepCount),
                                                    ("Running Speed", info.runningSpeed),
                                                    ("Basal Energy Burned", info.basalEnergyBurned),
                                                    ("Active Energy Burned", info.activeEnergyBurned),
                                                    ("Sleep Analysis", info.sleepAnalysis),
                                                    ("Heart Rate", info.heartRate),
                                                    ("Oxygen Saturation", info.oxygenSaturation),
                                                    ("Blood Pressure (Systolic)", info.bloodPressureSystolic),
                                                    ("Blood Pressure (Diastolic)", info.bloodPressureDiastolic),
                                                    ("Respiratory Rate", info.respiratoryRate),
                                                    ("Body Temperature", info.bodyTemperature),
                                                    ("ECG", info.ecgData),
                                                    ("Watch Device Latitude", info.watchDeviceLatitude),
                                                    ("Watch Device Longitude", info.watchDeviceLongitude)
                                                ])
                                            }
                                        case 3:
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Collected Air Quality Data").font(.headline)
                                                checkmarkList(info: info, keys: [
                                                    ("PM2.5 Value", info.pm25Value),
                                                    ("PM2.5 Level", info.pm25Level),
                                                    ("PM10 Value", info.pm10Value),
                                                    ("PM10 Level", info.pm10Level),
                                                    ("Temperature", info.temperature),
                                                    ("Temperature Level", info.temperatureLevel),
                                                    ("Humidity", info.humidity),
                                                    ("Humidity Level", info.humidityLevel),
                                                    ("CO2 Value", info.co2Value),
                                                    ("CO2 Level", info.co2Level),
                                                    ("VOC Value", info.vocValue),
                                                    ("VOC Level", info.vocLevel),
                                                    ("Pico Device Latitude", info.picoDeviceLatitude),
                                                    ("Pico Device Longitude", info.picoDeviceLongitude)
                                                ])
                                            }
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .presentationDetents([.large])
                        } else {
                            VStack {
                                ProgressView("Loading...")
                                Button("Close") {
                                    showProjectInfo = false
                                }
                                .padding(.top)
                            }
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    agreementToggle("Privacy Policy", isOn: $agreePrivacyPolicy)
                    agreementToggle("Terms of Service", isOn: $agreeTermsOfService)
                    agreementToggle("Consent to Health Data Collection", isOn: $agreeConsentOfHealthData)
                    agreementToggle("Location Data Terms of Service", isOn: $agreeLocationDataTermsOfService)
                }
                .padding(.horizontal)

                HStack {
                    Button("Reset") {
                        selectedProject = nil
                        agreePrivacyPolicy = false
                        agreeTermsOfService = false
                        agreeConsentOfHealthData = false
                        agreeLocationDataTermsOfService = false
                    }
                    .foregroundColor(.gray)
                    .disabled(viewModel.isRegisted)

                    Spacer()

                    Button("Register") {
                        Task {
                            if let project = selectedProject {
                                await viewModel.registerProject(projectId: project.projectId)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(!canRegister || viewModel.isRegisted ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(!canRegister || viewModel.isRegisted)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
            .onAppear {
                Task {
                    await viewModel.fetchProjects()
                }

                // HealthKit 데이터 전송 로직
                if viewModel.isRegisted && !hasSentHealthData {
                    Task {
                        do {
                            let healthManager = HealthDataViewModel()
                            try await healthManager.requestAuthorization()
                            try await healthManager.fetchAndSendData()
                            hasSentHealthData = true
                        } catch {
                            print("HealthKit 처리 실패: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    var canRegister: Bool {
        selectedProject != nil &&
        agreePrivacyPolicy &&
        agreeTermsOfService &&
        agreeConsentOfHealthData &&
        agreeLocationDataTermsOfService
    }

    @ViewBuilder
    func agreementToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                Text("*")
                    .foregroundColor(.red)
                Text(title)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .disabled(selectedProject == nil)
    }

    @ViewBuilder
    func checkmarkList(info: InfoResponse, keys: [(String, Bool)]) -> some View {
        ForEach(keys, id: \.0) { label, isIncluded in
            HStack {
                Image(systemName: isIncluded ? "checkmark.square" : "square")
                    .foregroundColor(isIncluded ? .blue : .gray)
                Text(label)
            }
        }
    }
}
