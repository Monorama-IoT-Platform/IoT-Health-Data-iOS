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

    @State private var showPrivacyPolicyModal = false
    @State private var showTermsOfServiceModal = false
    @State private var showConsentHealthDataModal = false
    @State private var showLocationDataTermsModal = false

//    @State private var selectedTab = 0
    @State private var hasSentHealthData = false
    private let healthDataSendInterval: UInt64 = 10 * 1_000_000_000
    
    @State private var selectedTab: ProjectTab = .project
    @Namespace private var animation

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: ProjectViewModel(appState: appState))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        appState.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
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
                        Menu {
                            Button("Please select a project.") {
                                selectedProject = nil
                            }

                            ForEach(viewModel.projectList) { project in
                                Button(project.projectTitle) {
                                    selectedProject = project
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedProject?.projectTitle ?? "Please select a project.")
                                    .foregroundColor(selectedProject == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)

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
                            VStack(spacing: 0) {
                                
                                topTabBar()

                                Divider()
                                
                                TabView(selection: $selectedTab) {
                                    projectInfoView(info)
                                        .tag(ProjectTab.project)

                                    personalInfoView(info)
                                        .tag(ProjectTab.personal)

                                    healthDataView(info)
                                        .tag(ProjectTab.health)

                                    airQualityDataView(info)
                                        .tag(ProjectTab.air)

                                    contributorsView()
                                        .tag(ProjectTab.contributors)
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            }
                            .background(Color(.systemBackground))
                            .presentationDetents([.large])
                            
                        } else {
                            VStack {
                                ProgressView("Loading...")
                                    .padding()
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
                
                if viewModel.isRegisted {
                    Button  (action: {
                        if let url = URL(string: "https://kibana.sssungjin.site/") {
                                    UIApplication.shared.open(url)
                            }
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "link")
                                .foregroundColor(.white)
                            Text("View data on Web")
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                    }
                    
                    // .sheet //키바나가 연동이 가능해지면 구현
                }

                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Agreement to Terms")
                        .font(.headline)
                        .padding(.bottom, 8)

                    agreementToggleWithModal(
                        title: "Privacy Policy",
                        isOn: $agreePrivacyPolicy,
                        showModal: $showPrivacyPolicyModal,
                        isToggleDisabled: viewModel.isRegisted
                    ) {
                        Text(selectedProject?.privacyPolicy ?? "")
                    }

                    agreementToggleWithModal(
                        title: "Terms of Service",
                        isOn: $agreeTermsOfService,
                        showModal: $showTermsOfServiceModal,
                        isToggleDisabled: viewModel.isRegisted
                    ) {
                        Text(selectedProject?.termsOfPolicy ?? "")
                    }

                    agreementToggleWithModal(
                        title: "Consent of Health Data",
                        isOn: $agreeConsentOfHealthData,
                        showModal: $showConsentHealthDataModal,
                        isToggleDisabled: viewModel.isRegisted
                    ) {
                        Text(selectedProject?.healthDataConsent ?? "")
                    }

                    agreementToggleWithModal(
                        title: "Location Data Terms of Service",
                        isOn: $agreeLocationDataTermsOfService,
                        showModal: $showLocationDataTermsModal,
                        isToggleDisabled: viewModel.isRegisted
                    ) {
                        Text(selectedProject?.localDataTermsOfService ?? "")
                    }
                }
                .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("Reset") {
                        selectedProject = nil
                        agreePrivacyPolicy = false
                        agreeTermsOfService = false
                        agreeConsentOfHealthData = false
                        agreeLocationDataTermsOfService = false
                    }
                    .foregroundColor(.gray)
                    .disabled(viewModel.isRegisted)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                    Button("Register") {
                        Task {
                            if let project = selectedProject {
                                await viewModel.registerProject(projectId: project.projectId)

                                if viewModel.isRegisted && !hasSentHealthData {
                                    do {
                                        let healthManager = HealthDataViewModel()
                                        try await healthManager.fetchAndSendData()
                                        hasSentHealthData = true
                                    } catch {
                                        print("HealthKit 처리 실패: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(!canRegister || viewModel.isRegisted ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .disabled(!canRegister || viewModel.isRegisted)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 20)



                Spacer()
            }
            .task {
                await viewModel.fetchProjects()
                
                if let registeredId = appState.registeredProjectId {
                    selectedProject = viewModel.projectList.first(where: { $0.projectId == registeredId })
                }

                let healthManager = HealthDataViewModel()
                
                while true {
                    guard let _ = appState.registeredProjectId else {
                        print("⏳ 등록된 프로젝트가 없어 전송 대기 중...")
                        try? await Task.sleep(nanoseconds: healthDataSendInterval)
                        continue
                    }
                    do {
                        try? await Task.sleep(nanoseconds: healthDataSendInterval)
                        try await healthManager.fetchAndSendData()
                        print("✅ 실시간 건강 데이터 전송 완료")
                    } catch {
                        print("❌ 실시간 전송 실패: \(error.localizedDescription)")
                    }
                    try? await Task.sleep(nanoseconds: healthDataSendInterval)
                }
            }
            .onChange(of: selectedProject) {
                agreePrivacyPolicy = false
                agreeTermsOfService = false
                agreeConsentOfHealthData = false
                agreeLocationDataTermsOfService = false
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
    func agreementToggleWithModal<Content: View>(
        title: String,
        isOn: Binding<Bool>,
        showModal: Binding<Bool>,
        isToggleDisabled: Bool = false,
        @ViewBuilder modalContent: @escaping () -> Content
    ) -> some View {
        HStack {
            Text("*")
                .foregroundColor(.red)
                .bold()

            Text(title)
                .fontWeight(.medium)

            Spacer()

            Button("view") {
                showModal.wrappedValue = true
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .buttonStyle(PlainButtonStyle())
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .disabled(isToggleDisabled)
        }
        .sheet(isPresented: showModal) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .padding(.bottom)

                ScrollView {
                    modalContent()
                        .padding()
                }

                Button("Close") {
                    showModal.wrappedValue = false
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }

    @ViewBuilder
    func checkmarkList(info: InfoResponse, keys: [(String, Bool)]) -> some View {
        ForEach(keys, id: \.0) { label, isIncluded in
            HStack {
                Image(systemName: isIncluded ? "checkmark.square" : "square")
                    .font(.system(size: 18))
                    .background(
                           RoundedRectangle(cornerRadius: 10)
                               .fill(Color.white)
                       )
                Text(label)
                    .font(.system(size: 18))
            }
        }
    }
    
    // MARK: - Tab Content Views
    
    @ViewBuilder
    func topTabBar() -> some View {
        HStack {
            ForEach(ProjectTab.allCases, id: \.self) { tab in
                VStack {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 80)
                        .multilineTextAlignment(.center)

                    if selectedTab == tab {
                        Capsule()
                            .foregroundColor(.black)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "underline", in: animation)
                    }
                }
                .contentShape(Rectangle()) // 빈 공간도 탭 가능하게
                .onTapGesture {
                    withAnimation {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding()
    }


    @ViewBuilder
    func projectInfoView(_ info: InfoResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(info.projectTitle)
                .font(.title2)
                .bold()
                .padding(.bottom, 8)
            
            infoRow(label: "Owner", value: info.pmEmail)
            infoRow(label: "Reg Date", value: info.createdAt)
            infoRow(label: "From", value: info.startDate)
            infoRow(label: "To", value: info.endDate)
            infoRow(label: "Participants", value: String(info.participant))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.headline)
                Text(info.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // 줄바꿈 허용
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    func personalInfoView(_ info: InfoResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collected Personal Information")
                .font(.headline)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    func healthDataView(_ info: InfoResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collected Health Data")
                .font(.headline)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    func airQualityDataView(_ info: InfoResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collected Air Quality Data")
                .font(.headline)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    func contributorsView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contributors")
                .font(.headline)
            Text("조성진 github.com/sssungjin")
            Text("김위성 github.com/kimwiseong")
            Text("이형준 github.com/01HyungJun")
            Text("한상민 github.com/SangminHann")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    @ViewBuilder
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading) // 라벨 고정 너비로 정렬
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}
