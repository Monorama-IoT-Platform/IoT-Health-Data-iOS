import Foundation

@MainActor
class ProjectViewModel: ObservableObject {
    private let appState: AppState
    private let projectService = ProjectService()

    @Published var projectList: [ProjectSimpleResponse] = []
    @Published var info: InfoResponse?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var registeredProjectId: Int64? {
        didSet {
            if let id = registeredProjectId {
                UserDefaults.standard.set(id, forKey: "registeredProjectId")
                appState.registeredProjectId = id // ✅ AppState 반영
            } else {
                UserDefaults.standard.removeObject(forKey: "registeredProjectId")
                appState.registeredProjectId = nil // ✅ AppState 반영
            }
        }
    }

    var isRegisted: Bool {
        registeredProjectId != nil
    }

    init(appState: AppState) {
        self.appState = appState
        
        if let savedId = UserDefaults.standard.object(forKey: "registeredProjectId") as? Int64 {
            self.registeredProjectId = savedId
            self.appState.registeredProjectId = savedId
        } else {
            self.registeredProjectId = nil
        }
    }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projectList = try await projectService.getProjectList()
        } catch {
            errorMessage = "프로젝트 목록을 가져오지 못했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func registerProject(projectId: Int64) async {
        isLoading = true
        errorMessage = nil

        do {
            let success = try await projectService.registProject(projectId: projectId)
            if success {
                self.registeredProjectId = projectId
            } else {
                errorMessage = "프로젝트 등록에 실패했습니다."
            }
        } catch {
            errorMessage = "프로젝트 등록 중 오류 발생: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func getProjectInfo(projectId: Int64) async {
        info = nil
        errorMessage = nil
        isLoading = true

        do {
            info = try await projectService.getProjectInfo(projectId: projectId)
        } catch {
            errorMessage = "프로젝트 정보를 가져오지 못했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func resetRegistration() {
        registeredProjectId = nil
    }
}

