import Cocoa

class AcpiPatchViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var acpiPatchTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // allow row reordering for kexts + acpi pactches table
//        acpiPatchTable.registerForDraggedTypes([masterVC!.dragDropAcpiPatch])
    }
    
    @IBAction func addPatchAcpiBtn(_ sender: Any) {
        //masterVC?.addEntryToTable(table: &acpiPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "TableSignature": "DSDT", "Enabled": "", "advanced": "", "Limit": "", "Mask": "", "OemTableId": "", "ReplaceMask": "", "Skip": "", "TableLength": "", "Count": ""])
    }
    @IBAction func remPatchAcpiBtn(_ sender: Any) {
        //masterVC?.removeEntryFromTable(table: &acpiPatchTable)
    }
}
