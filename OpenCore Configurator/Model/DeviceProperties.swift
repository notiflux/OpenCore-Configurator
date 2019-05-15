//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct DeviceProperties: Codable {
    var additions: [String: [String: Configuration.Value]]?
    var blocks: [String]?

    private enum CodingKeys: String, CodingKey {
        case additions = "Add"
        case blocks = "Block"
    }
}
