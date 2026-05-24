//
//  MenuBarItemService.swift
//  Shared
//

import Foundation
import XPC

enum MenuBarItemService {
    static let name = "com.jordanbaird.Ice.MenuBarItemService"

    /// The bundle identifier for Ice's main application.
    static let mainAppBundleIdentifier = "com.jordanbaird.Ice"

    /// The peer requirement to use when connecting to the service.
    ///
    /// Ad-hoc signed builds do not have a team identifier, which causes
    /// `isFromSameTeam()` to reject the embedded XPC service. The service
    /// also has a different signing identifier than the main application.
    static var peerRequirement: XPCPeerRequirement? {
        guard Bundle.main.hasCodeSigningTeamIdentifier else {
            return nil
        }
        return .isFromSameTeam()
    }

    /// The listener requirement to use when accepting connections.
    static var listenerRequirement: XPCPeerRequirement {
        if Bundle.main.hasCodeSigningTeamIdentifier {
            return .isFromSameTeam()
        }
        return .isFromSameTeam(andMatchesSigningIdentifier: mainAppBundleIdentifier)
    }
}

extension MenuBarItemService {
    enum Request: Codable {
        case start
        case sourcePID(WindowInfo)
    }

    enum Response: Codable {
        case start
        case sourcePID(pid_t?)
    }
}
