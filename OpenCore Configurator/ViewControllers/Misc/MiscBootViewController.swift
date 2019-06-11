import Cocoa

class MiscBootViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var timeoutTextfield: NSTextField!
    @IBOutlet weak var timeoutStepper: NSStepper!
    @IBOutlet weak var showPicker: NSButton!
    @IBOutlet weak var resolution: NSComboBox!
    @IBOutlet weak var consoleMode: NSComboBox!
    @IBOutlet weak var OsBehavior: NSPopUpButton!
    @IBOutlet weak var UiBehavior: NSPopUpButton!
    @IBOutlet weak var hideSelf: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func timeoutStepperAction(_ sender: NSStepper) {
        timeoutTextfield.stringValue = sender.stringValue
    }
    @IBAction func timeoutTextfieldAction(_ sender: NSTextField) {
        timeoutStepper.stringValue = sender.stringValue
    }
    
}
