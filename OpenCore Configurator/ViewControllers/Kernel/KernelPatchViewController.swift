import Cocoa

class KernelPatchViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var kernelPatchTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        kernelPatchTable.registerForDraggedTypes([masterVC!.dragDropKernelPatch])
    }
    
    @IBAction func addKernelPatchBtn(_ sender: Any) {
        //masterVC?.addEntryToTable(table: &kernelPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "MatchKernel": "", "Enabled": "", "kernelAdvanced": "", "Base": "", "Count": "", "Identifier": "", "Limit": "", "Mask": "", "ReplaceMask": "", "Skip": ""])
    }
    @IBAction func remKernelPatchBtn(_ sender: Any) {
        //masterVC?.removeEntryFromTable(table: &kernelPatchTable)
    }
}
