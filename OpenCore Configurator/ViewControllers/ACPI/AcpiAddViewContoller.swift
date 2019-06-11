import Cocoa

class AcpiAddViewContoller: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var acpiAddTable: NSTableView!
    @IBOutlet weak var acpiAutoBtn: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        acpiAutoBtn.toolTip = "Automatically check and add entries for all ACPI tables in EFI/OC/ACPI/Custom"
//        acpiAddTable.registerForDraggedTypes([masterVC!.dragDropAcpiAdd])
    }
    
    @IBAction func addAcpiBtn(_ sender: Any) {
        //masterVC?.addEntryToTable(table: &acpiAddTable, appendix: ["Path": "", "Comment": "", "Enabled": ""])
    }
    
    @IBAction func remAcpiBtn(_ sender: Any) {
        //masterVC?.removeEntryFromTable(table: &acpiAddTable)
    }
    
    @IBAction func autoAddAcpi(_ sender: Any) {
        if mountedESP != "" {
            let fileManager = FileManager.default
            let acpiUrl = URL(fileURLWithPath: "\(mountedESP)/EFI/OC/ACPI/Custom")
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: acpiUrl, includingPropertiesForKeys: nil)
                var filenames: [String] = [String]()
                for i in fileURLs {
                    if !i.lastPathComponent.hasSuffix(".aml") {
                        masterVC?.messageBox(message: "\(i.lastPathComponent) does not have the .aml extension.")
                        continue
                    }
                    let checksum = masterVC?.calcAcpiChecksum(table: i)
                    if checksum != 0 {
                        if checksum != nil {
                            masterVC?.messageBox(message: "Invalid Checksum", info: "The checksum for \(i.lastPathComponent) is invalid.")
                        } else {
                            masterVC?.messageBox(message: "The length of \(i.lastPathComponent) could not be verified.")
                        }
                        continue
                    }
                    filenames.append(i.lastPathComponent)
                }
                for file in filenames {
                    tableLookup[acpiAddTable]!.append(["Comment": "", "Path": file, "Enabled": "1"])
                }
                acpiAddTable.reloadData()
            } catch {
                print("Error while enumerating files \(acpiUrl.path): \(error.localizedDescription)")
            }
        } else {
            masterVC?.espWarning()
        }
    }
}
