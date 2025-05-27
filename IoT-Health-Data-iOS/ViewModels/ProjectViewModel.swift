import Foundation

@MainActor
class ProjectViewModel: ObservableObject {
    private let appState: AppState
    private let projectService = ProjectService()

    @Published var projectList: [ProjectSimpleResponse] = []
    @Published var info: InfoResponse?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegisted = false
    @Published var registeredProjectId: Int64? = nil

    init(appState: AppState) {
        
        self.appState = appState
        isRegisted = UserDefaults.standard.bool(forKey: "isProjectRegistered")
        
        if isRegisted {
            registeredProjectId = UserDefaults.standard.object(forKey: "registeredProjectId") as? Int64
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
            isRegisted = try await projectService.registProject(projectId: projectId)
        } catch {
            errorMessage = "프로젝트 등록에 실패했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    func getProjectInfo(projectId: Int64) async {
        info = nil  // 이전 정보 초기화
        errorMessage = nil
        isLoading = true

        do {
            info = try await projectService.getProjectInfo(projectId: projectId)
        } catch {
            errorMessage = "프로젝트 정보를 가져오지 못했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
