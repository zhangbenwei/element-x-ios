//
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct SettingsScreenCoordinatorParameters {
    let navigationStackCoordinator: NavigationStackCoordinator
    let userNotificationController: UserNotificationControllerProtocol
    let userSession: UserSessionProtocol
    let bugReportService: BugReportServiceProtocol
}

enum SettingsScreenCoordinatorAction {
    case dismiss
    case logout
}

final class SettingsScreenCoordinator: CoordinatorProtocol {
    private let parameters: SettingsScreenCoordinatorParameters
    private var viewModel: SettingsScreenViewModelProtocol

    var callback: ((SettingsScreenCoordinatorAction) -> Void)?
    
    // MARK: - Setup
    
    init(parameters: SettingsScreenCoordinatorParameters) {
        self.parameters = parameters
        
        viewModel = SettingsScreenViewModel(withUserSession: parameters.userSession)
        viewModel.callback = { [weak self] action in
            guard let self else { return }
            
            switch action {
            case .close:
                self.callback?(.dismiss)
            case .toggleAnalytics:
                self.toggleAnalytics()
            case .reportBug:
                self.presentBugReportScreen()
            case .sessionVerification:
                self.verifySession()
            case .logout:
                self.callback?(.logout)
            }
        }
    }
    
    // MARK: - Public
    
    func toPresentable() -> AnyView {
        AnyView(SettingsScreen(context: viewModel.context))
    }
    
    // MARK: - Private
    
    private func toggleAnalytics() {
        if ServiceLocator.shared.settings.enableAnalytics {
            Analytics.shared.optOut()
        } else {
            Analytics.shared.optIn(with: parameters.userSession)
        }
    }

    private func presentBugReportScreen() {
        let params = BugReportCoordinatorParameters(bugReportService: parameters.bugReportService,
                                                    userNotificationController: parameters.userNotificationController,
                                                    screenshot: nil,
                                                    isModallyPresented: false)
        let coordinator = BugReportCoordinator(parameters: params)
        coordinator.completion = { [weak self] result in
            switch result {
            case .finish:
                self?.showSuccess(label: ElementL10n.done)
            default:
                break
            }
            
            self?.parameters.navigationStackCoordinator.pop()
        }
        
        parameters.navigationStackCoordinator.push(coordinator)
    }
    
    private func verifySession() {
        guard let sessionVerificationController = parameters.userSession.sessionVerificationController else {
            fatalError("The sessionVerificationController should aways be valid at this point")
        }
        
        let verificationParameters = SessionVerificationCoordinatorParameters(sessionVerificationControllerProxy: sessionVerificationController)
        let coordinator = SessionVerificationCoordinator(parameters: verificationParameters)
        
        coordinator.callback = { [weak self] in
            self?.parameters.navigationStackCoordinator.setSheetCoordinator(nil)
        }
        
        parameters.navigationStackCoordinator.setSheetCoordinator(coordinator) { [weak self] in
            self?.parameters.navigationStackCoordinator.setSheetCoordinator(nil)
        }
    }

    private func showSuccess(label: String) {
        parameters.userNotificationController.submitNotification(UserNotification(title: label))
    }
}