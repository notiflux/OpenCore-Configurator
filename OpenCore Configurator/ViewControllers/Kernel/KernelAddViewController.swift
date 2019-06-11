import Cocoa

class KernelAddViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var kernelAddTable: NSTableView!
    @IBOutlet weak var kernelAutoBtn: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        kernelAutoBtn.toolTip = "Automatically check and add entries for all KEXTs in EFI/OC/Kexts"
//        kernelAddTable.registerForDraggedTypes([masterVC!.dragDropKernelAdd])
    }
    
    @IBAction func addKernelAddBtn(_ sender: Any) {
        //masterVC?.addEntryToTable(table: &kernelAddTable, appendix: ["BundlePath": "", "Comment": "", "ExecutablePath": "", "PlistPath": "","MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelAddBtn(_ sender: Any) {
        //masterVC?.removeEntryFromTable(table: &kernelAddTable)
    }
    @IBAction func autoAddKernel(_ sender: Any) {
        if mountedESP != "" {
            let execLookup = masterVC?.recursiveKexts(path: "\(mountedESP)/EFI/OC/Kexts")
            for kext in Array(execLookup!.keys) {
                tableLookup[kernelAddTable]!.append(["Comment": "", "BundlePath": kext, "Enabled": "1", "ExecutablePath": "\(execLookup![kext]!)", "MatchKernel": "", "PlistPath": "Contents/Info.plist"])
            }
            tableLookup[kernelAddTable]! = tableLookup[kernelAddTable]!.sorted { $0.values[$0.keys.firstIndex(of: "BundlePath")!] < $1.values[$1.keys.firstIndex(of: "BundlePath")!] }
            kernelAddTable.reloadData()
        } else {
            masterVC?.espWarning()
        }
    }
}
