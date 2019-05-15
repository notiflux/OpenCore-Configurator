//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

struct Configuration: Codable {
    var acpi: ACPI?
    var deviceProperties: DeviceProperties?
    var kernel: Kernel?
    var miscellaneous: Miscellaneous?
    var nvram: NVRAM?
    var platformInfo: PlatformInfo?
    var uefi: UEFI?

    private enum CodingKeys: String, CodingKey {
        case acpi = "ACPI"
        case deviceProperties = "DeviceProperties"
        case kernel = "Kernel"
        case miscellaneous = "Misc"
        case nvram = "NVRAM"
        case platformInfo = "PlatformInfo"
        case uefi = "UEFI"
    }

    enum Value: Codable {
        case string(String)
        case int(Int)
        case data(Data)
        case empty

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .int(container.decode(Int.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .string(container.decode(String.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try .data(container.decode(Data.self))
                    } catch DecodingError.typeMismatch {
                        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                    }
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .int(int):
                try container.encode(int)
            case let .string(string):
                try container.encode(string)
            case let .data(data):
                try container.encode(data)
            case .empty:
                try container.encodeNil()
            }
        }
    }
}
