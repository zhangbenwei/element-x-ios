//
// Copyright 2022-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

enum CreateRoomScreenErrorType: Error {
    case failedCreatingRoom
    case failedUploadingMedia
    case fileTooLarge
    case mediaFileError
    case unknown
}

enum CreateRoomViewModelAction {
    case openRoom(withIdentifier: String)
    case deselectUser(UserProfileProxy)
    case updateDetails(CreateRoomFlowParameters)
    case displayMediaPicker
    case displayCameraPicker
    case removeImage
}

struct CreateRoomViewState: BindableState {
    var roomName: String
    let serverName: String
    let isKnockingFeatureEnabled: Bool
    var selectedUsers: [UserProfileProxy]
    var aliasLocalPart: String
    var bindings: CreateRoomViewStateBindings
    var avatarURL: URL?
    var canCreateRoom: Bool {
        !roomName.isEmpty && aliasErrors.isEmpty
    }

    var aliasErrors: Set<CreateRoomAliasErrorState> = []
    var aliasErrorDescription: String? {
        if aliasErrors.contains(.alreadyExists) {
            return L10n.screenCreateRoomRoomAddressNotAvailableErrorDescription
        } else if aliasErrors.contains(.invalidSymbols) {
            return L10n.screenCreateRoomRoomAddressInvalidSymbolsErrorDescription
        }
        return nil
    }
}

struct CreateRoomViewStateBindings {
    var roomTopic: String
    var isRoomPrivate: Bool
    var isKnockingOnly: Bool
    var showAttachmentConfirmationDialog = false
    
    /// Information describing the currently displayed alert.
    var alertInfo: AlertInfo<CreateRoomScreenErrorType>?
}

enum CreateRoomViewAction {
    case createRoom
    case deselectUser(UserProfileProxy)
    case displayCameraPicker
    case displayMediaPicker
    case removeImage
    case updateRoomName(String)
    case updateAliasLocalPart(String)
}

enum CreateRoomAliasErrorState {
    case alreadyExists
    case invalidSymbols
}
