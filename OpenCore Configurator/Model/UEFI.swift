//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct UEFI: Codable {
    var connectDrivers: Bool = false
    var drivers: [String]?
    var protocols: Protocols?
    var quirks: Quirks?

    struct Protocols: Codable {
        var appleBootPolicy: Bool = false
        var consoleControl: Bool = false
        var dataHub: Bool = false
        var deviceProperties: Bool = false

        private enum CodingKeys: String, CodingKey {
            case appleBootPolicy = "AppleBootPolicy"
            case consoleControl = "ConsoleControl"
            case dataHub = "DataHub"
            case deviceProperties = "DeviceProperties"
        }
    }

    struct Quirks: Codable {
        var exitBootServicesDelay: Int = 0
        var ignoreInvalidFlexRatio: Bool = false
        var ignoreTextInGraphics: Bool = false
        var provideConsoleGOP: Bool = false
        var releaseUSBOwnership: Bool = false
        var requestBootVariableRouting: Bool = false
        var sanitiseClearScreen: Bool = false

        private enum CodingKeys: String, CodingKey {
            case exitBootServicesDelay = "ExitBootServicesDelay"
            case ignoreInvalidFlexRatio = "IgnoreInvalidFlexRatio"
            case ignoreTextInGraphics = "IgnoreTextInGraphics"
            case provideConsoleGOP = "ProvideConsoleGOP"
            case releaseUSBOwnership = "ReleaseUSBOwnership"
            case requestBootVariableRouting = "RequestBootVariableRouting"
            case sanitiseClearScreen = "SanitiseClearScreen"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case connectDrivers = "ConnectDrivers"
        case drivers = "Drivers"
        case protocols = "Protocols"
        case quirks = "Quirks"
    }
}
