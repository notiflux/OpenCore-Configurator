//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct Miscellaneous: Codable {
    var boot: Boot?
    var debug: Debug?
    var security: Security?

    private enum CodingKeys: String, CodingKey {
        case boot = "Boot"
        case debug = "Debug"
        case security = "Security"
    }

    struct Boot: Codable {
        var consoleMode: String?
        var consoleBehaviourOS: ConsoleBehaviour?
        var consoleBehaviourUI: String?
        var hideSelf: Bool? = false
        var resolution: String?
        var showPicker: Bool? = false
        var timeout: Int32? = 0

        enum ConsoleBehaviour: String, RawRepresentable, Codable {
            case text = "Text"
            case graphics = "Graphics"
            case forceText = "ForceText"
            case forceGraphics = "ForceGraphics"
        }

        private enum CodingKeys: String, CodingKey {
            case consoleMode = "ConsoleMode"
            case consoleBehaviourOS = "ConsoleBehaviourOS"
            case consoleBehaviourUI = "ConsoleBehaviourUI"
            case hideSelf = "HideSelf"
            case resolution = "Resolution"
            case showPicker = "ShowPicker"
            case timeout = "Timeout"
        }
    }

    struct Debug: Codable {
        var disableWatchDog: Bool? = false
        var displayDelay: Int? = 0
        var displayLevel: Int64? = 0
        var target: Int? = 0

        private enum CodingKeys: String, CodingKey {
            case disableWatchDog = "DisableWatchDog"
            case displayDelay = "DisplayDelay"
            case displayLevel = "DisplayLevel"
            case target = "Target"
        }
    }

    struct Security: Codable {
        var exposeSensitiveData: Int? = 2
        var haltLevel: Int64? = 0x8000_0000
        var requireSignature: Bool? = true
        var requireVault: Bool? = true

        private enum CodingKeys: String, CodingKey {
            case exposeSensitiveData = "ExposeSensitiveData"
            case haltLevel = "HaltLevel"
            case requireSignature = "RequireSignature"
            case requireVault = "RequireVault"
        }
    }
}
