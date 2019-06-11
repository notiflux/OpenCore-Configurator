import Foundation

extension Bundle {
    static let current = Bundle(for: BundleSentinel.self)
}

private final class BundleSentinel {}
