import Cocoa

class UEFIQuirksViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var IgnoreTextInGraphics: NSButton!
    @IBOutlet weak var IgnoreInvalidFlexRatio: NSButton!
    @IBOutlet weak var ProvideConsoleGop: NSButton!
    @IBOutlet weak var ReleaseUsbOwnership: NSButton!
    @IBOutlet weak var RequestBootVarRouting: NSButton!
    @IBOutlet weak var SanitiseClearScreen: NSButton!
    @IBOutlet weak var ExitBootServicesDelay: NSTextField!
    @IBOutlet weak var AppleBootPolicy: NSButton!
    @IBOutlet weak var ConsoleControl: NSButton!
    @IBOutlet weak var DataHub: NSButton!
    @IBOutlet weak var DeviceProperties: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
