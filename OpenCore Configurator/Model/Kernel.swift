//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct Kernel: Codable {
    var additions: [Addition]?
    var blocks: [Block]?
    var patches: [Patch]?
    var quirks: Quirks?

    private enum CodingKeys: String, CodingKey {
        case additions = "Add"
        case blocks = "Block"
        case patches = "Patch"
        case quirks = "Quirk"
    }

    struct Addition: Codable {
        var bundlePath: String?
        var comment: String?
        var isEnabled: Bool = false
        var executablePath: String?
        var matchKernel: String?
        var plistPath: String?

        private enum CodingKeys: String, CodingKey {
            case bundlePath = "BundlePath"
            case comment = "Comment"
            case isEnabled = "Enabled"
            case executablePath = "ExecutablePath"
            case matchKernel = "MatchKernel"
            case plistPath = "PlistPath"
        }
    }

    struct Block: Codable {
        var comment: String?
        var isEnabled: Bool
        var identifier: String?
        var matchKernel: String?

        private enum CodingKeys: String, CodingKey {
            case comment = "Comment"
            case isEnabled = "Enabled"
            case identifier = "Identifier"
            case matchKernel = "MatchKernel"
        }
    }

    struct Patch: Codable {
        var base: String?
        var comment: String?
        var count: Int?
        var isEnabled: Bool
        var find: Data?
        var identifier: Data?
        var limit: Int?
        var mask: Data?
        var matchKernel: String?
        var replace: Data?
        var replaceMask: Data?
        var skip: Int?

        private enum CodingKeys: String, CodingKey {
            case base = "Base"
            case comment = "Comment"
            case count = "Count"
            case isEnabled = "Enabled"
            case find = "Find"
            case identifier = "Identifier"
            case limit = "Limit"
            case mask = "Mask"
            case matchKernel = "MatchKernel"
            case replace = "Replace"
            case replaceMask = "ReplaceMask"
            case skip = "Skip"
        }
    }

    struct Quirks: Codable {
        var appleCpuPmCfgLock: Bool = false
        var appleXcpmCfgLock: Bool = false
        var externalDiskIcons: Bool = false
        var thirdPartyTrim: Bool = false
        var xhciPortLimit: Bool = false

        private enum CodingKeys: String, CodingKey {
            case appleCpuPmCfgLock = "AppleCpuPmCfgLock"
            case appleXcpmCfgLock = "AppleXcpmCfgLock"
            case externalDiskIcons = "ExternalDiskIcons"
            case thirdPartyTrim = "ThirdPartyTrim"
            case xhciPortLimit = "XhciPortLimit"
        }
    }
}
