import Cocoa

public var acpiCurrentTextField: NSTextField = NSTextField()

class AcpiPopoverController: NSViewController {
    
    @IBOutlet weak var Limit: NSTextField!
    @IBOutlet weak var Mask: NSTextField!
    @IBOutlet weak var OemTableId: NSTextField!
    @IBOutlet weak var ReplaceMask: NSTextField!
    @IBOutlet weak var Skip: NSTextField!
    @IBOutlet weak var TableLength: NSTextField!
    @IBOutlet weak var Count: NSTextField!
    
    let popover = NSPopover()
    
    class func loadFromNib() -> AcpiPopoverController {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AcpiPopoverController") as! AcpiPopoverController       // we need this because we're calling this function from another view controller
        vc.popover.contentViewController = vc
        return vc           // allow for access of objects from this view controller from another one
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popover.behavior = .transient           // close popup on outside click/Esc
    }

    
    func showPopover(button: NSButton) {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxX)
        Limit.stringValue = acpiLimitString
        Limit.isEditable = true             // because for some reason setting them to "editable" in the storyboard is not enough?
        
        Mask.stringValue = acpiMaskString
        Mask.isEditable = true
        
        OemTableId.stringValue = acpiOemTableIdString
        OemTableId.isEditable = true
        
        ReplaceMask.stringValue = acpiReplaceMaskString
        ReplaceMask.isEditable = true
        
        Skip.stringValue = acpiSkipString
        Skip.isEditable = true
        
        TableLength.stringValue = acpiTableLengthString
        TableLength.isEditable = true
        
        Count.stringValue = acpiCountString
        Count.isEditable = true
    }
    
    @IBAction func sendLimit(_ sender: Any) {
        acpiCurrentTextField = Limit
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendMask(_ sender: Any) {
        acpiCurrentTextField = Mask
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendOemTableId(_ sender: Any) {
        acpiCurrentTextField = OemTableId
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendReplaceMask(_ sender: Any) {
        acpiCurrentTextField = ReplaceMask
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendSkip(_ sender: Any) {
        acpiCurrentTextField = Skip
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendTableLength(_ sender: Any) {
        acpiCurrentTextField = TableLength
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
    @IBAction func sendCount(_ sender: Any) {
        acpiCurrentTextField = Count
        NotificationCenter.default.post(name: .syncAcpiPopoverAndDict, object: nil)
    }
}
