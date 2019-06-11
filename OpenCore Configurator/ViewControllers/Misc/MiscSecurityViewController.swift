import Cocoa

class MiscSecurityViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var miscRequireSignature: NSButton!
    @IBOutlet weak var miscRequireVault: NSButton!
    @IBOutlet weak var miscHaltlevel: NSTextField!
    @IBOutlet weak var miscExposeSensitiveData: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
