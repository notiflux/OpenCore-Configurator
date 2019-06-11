import Cocoa

class AcpiQuirksViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var FadtEnableReset: NSButton!
    @IBOutlet weak var IgnoreForWindows: NSButton!
    @IBOutlet weak var NormalizeHeaders: NSButton!
    @IBOutlet weak var RebaseRegions: NSButton!
    @IBOutlet weak var ResetLogoStatus: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        acpiQuirks = [
//            "FadtEnableReset": self.FadtEnableReset,
//            "IgnoreForWindows": self.IgnoreForWindows,
//            "NormalizeHeaders": self.NormalizeHeaders,
//            "RebaseRegions": self.RebaseRegions,
//            "ResetLogoStatus": self.ResetLogoStatus
//        ]
    }
    
}
