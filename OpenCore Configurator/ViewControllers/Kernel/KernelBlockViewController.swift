import Cocoa

class KernelBlockViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var kernelBlockTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addKernelBlockBtn(_ sender: Any) {
        //masterVC!.addEntryToTable(table: &kernelBlockTable, appendix: ["Identifier": "", "Comment": "", "MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelBlockBtn(_ sender: Any) {
        //masterVC!.removeEntryFromTable(table: &kernelBlockTable)
    }
}
