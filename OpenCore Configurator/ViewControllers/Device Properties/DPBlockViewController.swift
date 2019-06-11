import Cocoa

class DPBlockViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var deviceBlockTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addDeviceBlockBtn(_ sender: Any) {
        //masterVC!.addEntryToTable(table: &deviceBlockTable, appendix: ["device": "", "property": ""])
    }
    @IBAction func remDeviceBlockBtn(_ sender: Any) {
        //masterVC!.removeEntryFromTable(table: &deviceBlockTable)
    }
}
