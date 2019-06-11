import Cocoa

class AcpiBlockViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var acpiBlockTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func blockAcpiBtn(_ sender: Any) {
        //masterVC?.addEntryToTable(table: &acpiBlockTable, appendix: ["Comment": "", "OemTableId": "", "TableLength": "", "TableSignature": "DSDT","Enabled": "", "All": ""])
    }
    @IBAction func remBlockAcpiBtn(_ sender: Any) {
        //masterVC?.removeEntryFromTable(table: &acpiBlockTable)
    }
    
}
