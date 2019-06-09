import Cocoa



class ViewController: NSViewController {

    // tabs
    @IBOutlet weak var acpiTab: NSTabView!
    @IBOutlet weak var deviceTab: NSTabView!
    @IBOutlet weak var kernelTab: NSTabView!
    @IBOutlet weak var miscTab: NSTabView!
    @IBOutlet weak var nvramTab: NSTabView!
    @IBOutlet weak var platformTab: NSTabView!
    @IBOutlet weak var uefiTab: NSTabView!
    
    // tables
    @IBOutlet weak var sectionsTable:NSTableView!
    // buttons
    // misc boot options
    
    
    // misc debug options
    
    
    // misc security options
    
    
    // device quirks
    // @IBOutlet weak var ReinstallProtocol: NSButton!
    
    // kernel quirks
    
    
    // uefi quirks
    
    
    
    
    
    
    // smbios options
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func timeoutStepperAction(_ sender: NSStepper) {
        timeoutTextfield.stringValue = sender.stringValue
    }
    @IBAction func timeoutTextfieldAction(_ sender: NSTextField) {
        timeoutStepper.stringValue = sender.stringValue
    }
    @IBAction func helpButtonAction(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/Configuration.pdf")!)
    }
}
