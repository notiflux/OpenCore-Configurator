import Cocoa

class KernelQuirksViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var AppleCpuPmCfgLock: NSButton!
    @IBOutlet weak var AppleXcpmCfgLock: NSButton!
    @IBOutlet weak var ExternalDiskIcons: NSButton!
    @IBOutlet weak var ThirdPartyTrim: NSButton!
    @IBOutlet weak var XhciPortLimit: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
