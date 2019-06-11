import Cocoa

class DetailViewController: NSViewController {
    @IBOutlet var detailView: NSView!
    
    var masterVC: MasterDetailsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
