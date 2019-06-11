import Cocoa

class PlatformInfoGeneralViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    var acpiTabVC: ACPITabViewController?
    var acpiAddVC: AcpiAddViewContoller?
    var acpiBlockVC: AcpiBlockViewController?
    var acpiPatchVC: AcpiPatchViewController?
    var acpiQuirksVC: AcpiQuirksViewController?
    var devicePropertiesTabVC: DevicePropertiesTabViewController?
    var devicePropertiesAddVC: DPAddViewController?
    var devicePropertiesBlockVC: DPBlockViewController?
    var kernelTabVC: KernelTabViewController?
    var kernelAddVC: KernelAddViewController?
    var kernelBlockVC: KernelBlockViewController?
    var kernelPatchVC: KernelPatchViewController?
    var kernelQuirksVC: KernelQuirksViewController?
    var miscTabVC: MiscTabViewController?
    var miscBootVC: MiscBootViewController?
    var miscDebugVC: MiscDebugViewController?
    var miscSecurityVC: MiscSecurityViewController?
    var nvramTabVC: NVRAMTabViewController?
    var nvramAddVC: NvramAddViewController?
    var nvramBlockVC: NvramBlockViewController?
    var platformInfoTabVC: PlatformInfoTabViewController?
    var platformInfoGenericVC: PlatformInfoGenericViewController?
    var platformInfoDataHubVC: PlatformInfoDataHubViewController?
    var platformInfoNvramVC: PlatformInfoNvramViewController?
    var platformInfoSmbiosVC: PlatformInfoSmbiosViewController?
    var uefiTabVC: UEFITabViewController?
    var uefiDriversVC: UEFIDriversViewController?
    var uefiQuirksVC: UEFIQuirksViewController?
    var detailsVC: DetailViewController?
    
    @IBOutlet weak var smbiosAutomatic: NSButton!
    @IBOutlet weak var updateDatahub: NSButton!
    @IBOutlet weak var updateNvram: NSButton!
    @IBOutlet weak var updateSmbios: NSButton!
    @IBOutlet weak var smbioUpdateModePopup: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func togglePlatformAutomatic() {
        if smbiosAutomatic.state == .on {
            platformInfoDataHubVC!.platformDatahubTable.isEnabled = false
            platformInfoNvramVC!.platformNvramTable.isEnabled = false
            platformInfoSmbiosVC!.platformSmbiosTable.isEnabled = false
            platformInfoGenericVC!.platformGenericTable.isEnabled = true
            platformInfoGenericVC!.spoofVendor.isEnabled = true
        } else {
            platformInfoDataHubVC!.platformDatahubTable.isEnabled = true
            platformInfoNvramVC!.platformNvramTable.isEnabled = true
            platformInfoSmbiosVC!.platformSmbiosTable.isEnabled = true
            platformInfoGenericVC!.platformGenericTable.isEnabled = false
            platformInfoGenericVC!.spoofVendor.isEnabled = false
        }
    }
    
    @IBAction func platformAutomaticAction(_ sender: NSButton) {
        togglePlatformAutomatic()
    }
    
}
