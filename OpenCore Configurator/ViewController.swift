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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func helpButtonAction(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/Configuration.pdf")!)
    }
}
