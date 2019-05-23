//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

extension Bundle {
    static let current = Bundle(for: BundleSentinel.self)
}

private final class BundleSentinel {}
