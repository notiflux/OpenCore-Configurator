import Cocoa

class NvramAddViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    
    @IBOutlet weak var nvramBootTable: NSTableView!
    @IBOutlet weak var nvramVendorTable: NSTableView!
    @IBOutlet weak var nvramCustomTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addNvramBootBtn(_ sender: Any) {
        //masterVC!.addEntryToTable(table: &nvramBootTable, appendix: ["property": "", "value": ""])
    }
    @IBAction func remNvramBootBtn(_ sender: Any) {
        //masterVC!.removeEntryFromTable(table: &nvramBootTable)
    }
    @IBAction func addNvramVendorBtn(_ sender: Any) {
        //masterVC!.addEntryToTable(table: &nvramVendorTable, appendix: ["property": "", "value": ""])
    }
    @IBAction func remNvramVendorBtn(_ sender: Any) {
        //masterVC!.removeEntryFromTable(table: &nvramVendorTable)
    }
    @IBAction func addNvramCustomBtn(_ sender: Any) {
        //masterVC!.addEntryToTable(table: &nvramCustomTable, appendix: ["guid": "", "property": "", "value": ""])
    }
    @IBAction func remNvramCustomBtn(_ sender: Any) {
        //masterVC!.removeEntryFromTable(table: &nvramCustomTable)
    }
    
}
