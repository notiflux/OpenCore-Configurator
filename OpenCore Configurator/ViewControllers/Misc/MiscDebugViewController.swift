import Cocoa

class MiscDebugViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var miscDelayText: NSTextField!
    @IBOutlet weak var miscDisplayLevelText: NSTextField!
    @IBOutlet weak var miscTargetText: NSTextField!
    @IBOutlet weak var disableWatchdog: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
