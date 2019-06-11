import Cocoa

class DPAddViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var deviceAddTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func addDeviceAddBtn(_ sender: Any) {
        NotificationCenter.default.post(name: .addTableEntry, object: sender)
        //masterVC!.addEntryToTable(table: &deviceAddTable, appendix: ["device": "", "property": "", "value": "", "edit": ""])
    }
    
    @IBAction func remDeviceAddBtn(_ sender: Any) {
        NotificationCenter.default.post(name: .removeTableEntry, object: sender)
        //masterVC!.removeEntryFromTable(table: &deviceAddTable)
    }
}
