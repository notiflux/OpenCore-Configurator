import Foundation

struct vault: Codable {
    var Files: [String: Data]?
    var Version: Int?
    
    static func openVaultPlist() throws -> vault {
        var plist: vault = vault()
        let data = try Data(contentsOf: URL(fileURLWithPath: "\(mountedESP)/EFI/OC/vault.plist"))
        let decoder = PropertyListDecoder()
        plist = try decoder.decode(vault.self, from: data)
        
        return plist
    }
}
