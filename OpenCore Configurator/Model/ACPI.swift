//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct ACPI: Codable {
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
        var comment: String?
        var isEnabled: Bool = false
        var path: String

        private enum CodingKeys: String, CodingKey {
            case comment = "Comment"
            case isEnabled = "Enabled"
            case path = "Path"
        }
    }

    struct Block: Codable {
        var blockAll: Bool? = false
        var comment: String?
        var isEnabled: Bool? = false
        var oemTableIdentifier: Data? = Data(repeating: 0, count: 8)
        var tableLength: Int? = 0
        var tableSignature: Data? = Data(repeating: 0, count: 4)

        private enum CodingKeys: String, CodingKey {
            case blockAll = "All"
            case comment = "Comment"
            case isEnabled = "Enabled"
            case oemTableIdentifier = "OemTableId"
            case tableLength = "TableLength"
            case tableSignature = "TableSignature"
        }
    }

    struct Patch: Codable {
        var comment: String?
        var count: Int? = 0
        var isEnabled: Bool? = false
        var find: Data?
        var limit: Int? = 0
        var mask: Data?
        var oemTableIdentifier: Data? = Data(repeating: 0, count: 8)
        var replace: Data?
        var replaceMask: Data?
        var skip: Int? = 0
        var tableLength: Int? = 0
        var tableSignature: Data? = Data(repeating: 0, count: 4)

        private enum CodingKeys: String, CodingKey {
            case comment = "Comment"
            case count = "Count"
            case isEnabled = "Enabled"
            case find = "Find"
            case limit = "Limit"
            case mask = "Mask"
            case oemTableIdentifier = "OemTableId"
            case replace = "Replace"
            case replaceMask = "ReplaceMask"
            case skip = "Skip"
            case tableLength = "TableLength"
            case tableSignature = "TableSignature"
        }
    }

    struct Quirks: Codable {
        var fadtEnableReset: Bool? = false
        var ignoreForWindows: Bool? = false
        var normalizeHeaders: Bool? = false
        var rebaseRegions: Bool? = false
        var resetLogoStatus: Bool? = false

        private enum CodingKeys: String, CodingKey {
            case fadtEnableReset = "FadtEnableReset"
            case ignoreForWindows = "IgnoreForWindows"
            case normalizeHeaders = "NormalizeHeaders"
            case rebaseRegions = "RebaseRegions"
            case resetLogoStatus = "ResetLogoStatus"
        }
    }
}
