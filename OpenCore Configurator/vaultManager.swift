import Cocoa

var dataSource: [[String: String]] = [[String: String]]()
var requireVault: Bool = false

class openCoreVault: NSViewController {
    @IBOutlet weak var vaultTable: NSTableView!
    @IBOutlet weak var vaultWarning: NSTextField!
    
    var plist: vault = vault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vaultTable.delegate = self as NSTableViewDelegate
        vaultTable.dataSource = self
        
        do {
            plist = try vault.openVaultPlist()
        } catch {
            print(error.localizedDescription)
        }
        
        if !requireVault {
            vaultWarning.stringValue = "Warning: RequireVault is disabled for this configuration file!"
        } else {
            vaultWarning.stringValue = ""
        }
        
        dataSource = checkSignatures(plist: plist)
        vaultTable.reloadData()
    }
    
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    func showVaultManager(vaultEnabled: Int) -> NSWindow {
        if vaultEnabled == 1 {
            requireVault = true
        } else {
            requireVault = false
        }
        
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "openCoreVault") as! openCoreVault
        let manager = NSWindow(contentViewController: vc)
        manager.minSize = NSSize(width: 986, height: 350)
        
        return manager
    }
    
    func checkSignatures(plist: vault) -> [[String: String]] {
        var tempDict: [[String: String]] = [[String: String]]()
        for file in plist.Files!.keys {
            var fileData: Data = Data()
            let filePath = "\(mountedESP)/EFI/OC/\(file.replacingOccurrences(of: "\\", with: "/"))"
            do {
                fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            } catch {
                print(error.localizedDescription)
            }
            
            var ok = ""
            if plist.Files![file]! == sha256(data: fileData) {
                ok = "1"
            } else {
                ok = "0"
            }
            
            tempDict.append(["file": file, "checksum": plist.Files![file]!.hexEncodedString(), "ok": ok])
            tempDict = tempDict.sorted { $0.values[$0.keys.firstIndex(of: "file")!] < $1.values[$1.keys.firstIndex(of: "file")!] }
        }
        
        return tempDict
    }
    
    @IBAction func createVault(_ sender: Any) {
        
    }
    
    @IBAction func checkVault(_ sender: Any) {
        dataSource = checkSignatures(plist: plist)
        vaultTable.reloadData()
        
        var tempArray = [String]()
        
        for entry in dataSource {
            if entry["ok"]! == "0" {
                tempArray.append(entry["file"]!.replacingOccurrences(of: "\\", with: "/"))
            }
        }
        
        if tempArray.count > 0 {
            let alert = NSAlert()
            alert.messageText = "Invalid Checksum(s) found!"
            alert.informativeText = "These files are affected:\n"
            for i in tempArray {
                alert.informativeText += "\n\(i)"
            }
            alert.informativeText += "\n\nIf you modified these files, you should update the vault. If not, they may have been corrupted and you should replace them."
            alert.beginSheetModal(for: view.window!, completionHandler: nil)
        }
    }
    
    @IBAction func deleteVault(_ sender: Any) {
        
    }
    
    @IBAction func close(_ sender: Any) {
        NotificationCenter.default.post(name: .closeVault, object: nil)
    }
}

extension openCoreVault: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
}

extension openCoreVault: NSTableViewDelegate {
    func tableView(_ tableViewName: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if dataSource.count > 0 {
            switch (tableColumn?.identifier.rawValue)! {
            case "ok":
                let cell = NSImageView()
                if dataSource[row][(tableColumn?.identifier.rawValue)!] == "1" {
                    cell.image = NSImage.init(named: "NSMenuOnStateTemplate")
                } else {
                    cell.image = NSImage.init(named: "NSStatusUnavailable")
                }
                return cell
            default:
                let cell = tableViewName.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: (tableColumn?.identifier.rawValue)!), owner: nil) as? NSTableCellView
                cell?.textField?.stringValue = dataSource[row][(tableColumn?.identifier.rawValue)!] ?? ""
                return cell
            }
        }
        return nil
    }
}
