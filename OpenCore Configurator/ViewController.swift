import Cocoa

public let kNotification = Notification.Name("kNotification")

public var acpiLimitString: String = String()           // variables for use in acpi popovover view controller
public var acpiMaskString: String = String()
public var acpiOemTableIdString: String = String()
public var acpiReplaceMaskString: String = String()
public var acpiSkipString: String = String()
public var acpiTableLengthString: String = String()
public var acpiCountString: String = String()

public var kernelBaseString: String = String()
public var kernelCountString: String = String()
public var kernelIdentifierString: String = String()
public var kernelLimitString: String = String()
public var kernelMaskString: String = String()
public var kernelReplaceString: String = String()
public var kernelSkipString: String = String()

public var mountedESP: String = String()
public var mountedESPID: String = String()

public var tableLookup: [NSTableView: [[String: String]]] = [NSTableView: [[String: String]]]()

public var serialDict: [String: [String]] = [String: [String]]()

public var viewLookup: [Int: NSTabView] = [Int: NSTabView]()

public var currentTable: String = String()
public var currentFind: String = String()
public var currentReplace: String = String()
public var allPatchesApplied: String = String()

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
    
    @IBOutlet weak var acpiAddTable: NSTableView!
    @IBOutlet weak var acpiBlockTable: NSTableView!
    @IBOutlet weak var acpiPatchTable: NSTableView!
    
    @IBOutlet weak var deviceAddTable: NSTableView!
    @IBOutlet weak var deviceBlockTable: NSTableView!
    
    @IBOutlet weak var kernelAddTable: NSTableView!
    @IBOutlet weak var kernelBlockTable: NSTableView!
    @IBOutlet weak var kernelPatchTable: NSTableView!
    
    @IBOutlet weak var nvramBootTable: NSTableView!
    @IBOutlet weak var nvramVendorTable: NSTableView!
    @IBOutlet weak var nvramCustomTable: NSTableView!
    @IBOutlet weak var nvramBlockTable: NSTableView!
    
    @IBOutlet weak var uefiDriverTable: NSTableView!
    
    @IBOutlet weak var platformSmbiosTable: NSTableView!
    @IBOutlet weak var platformDatahubTable: NSTableView!
    @IBOutlet weak var platformGenericTable: NSTableView!
    @IBOutlet weak var platformNvramTable: NSTableView!
    
    // buttons
    @IBOutlet weak var acpiAutoBtn: NSButton!
    @IBOutlet weak var kernelAutoBtn: NSButton!
    @IBOutlet weak var platformAutoBtn: NSButton!
    @IBOutlet weak var uefiAutoBtn: NSButton!
    
    // misc boot options
    @IBOutlet weak var timeoutTextfield: NSTextField!
    @IBOutlet weak var timeoutStepper: NSStepper!
    @IBOutlet weak var showPicker: NSButton!
    @IBOutlet weak var resolution: NSComboBox!
    @IBOutlet weak var consoleMode: NSComboBox!
    @IBOutlet weak var OsBehavior: NSPopUpButton!
    @IBOutlet weak var UiBehavior: NSPopUpButton!
    @IBOutlet weak var hideSelf: NSButton!
    
    // misc debug options
    @IBOutlet weak var miscDelayText: NSTextField!
    @IBOutlet weak var miscDisplayLevelText: NSTextField!
    @IBOutlet weak var miscTargetText: NSTextField!
    @IBOutlet weak var disableWatchdog: NSButton!
    
    // misc security options
    @IBOutlet weak var miscRequireSignature: NSButton!
    @IBOutlet weak var miscRequireVault: NSButton!
    @IBOutlet weak var miscHaltlevel: NSTextField!
    @IBOutlet weak var miscExposeSensitiveData: NSTextField!
    
    // acpi quirks
    @IBOutlet weak var FadtEnableReset: NSButton!
    @IBOutlet weak var IgnoreForWindows: NSButton!
    @IBOutlet weak var NormalizeHeaders: NSButton!
    @IBOutlet weak var RebaseRegions: NSButton!
    @IBOutlet weak var ResetLogoStatus: NSButton!
    
    // device quirks
    // @IBOutlet weak var ReinstallProtocol: NSButton!
    
    // kernel quirks
    @IBOutlet weak var AppleCpuPmCfgLock: NSButton!
    @IBOutlet weak var AppleXcpmCfgLock: NSButton!
    @IBOutlet weak var ExternalDiskIcons: NSButton!
    @IBOutlet weak var ThirdPartyTrim: NSButton!
    @IBOutlet weak var XhciPortLimit: NSButton!
    
    // uefi quirks
    @IBOutlet weak var uefiConnectDrivers: NSButton!
    
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
    
    // smbios options
    @IBOutlet weak var smbiosAutomatic: NSButton!
    @IBOutlet weak var updateDatahub: NSButton!
    @IBOutlet weak var updateNvram: NSButton!
    @IBOutlet weak var updateSmbios: NSButton!
    @IBOutlet weak var smbioUpdateModePopup: NSPopUpButton!
    @IBOutlet weak var spoofVendor: NSButton!
    
    @IBOutlet weak var espPopup: NSPopUpButton!
    
    var acpiQuirks: [String: NSButton] = [String: NSButton]()
    var deviceQuirks: [String: NSButton] = [String: NSButton]()
    var kernelQuirks: [String: NSButton] = [String: NSButton]()
    var uefiQuirks: [String: NSButton] = [String: NSButton]()
    var topLevelBools: [NSButton: Bool] = [NSButton: Bool]()
    var uefiProtocols: [String: NSButton] = [String: NSButton]()

    var dragDropKernelAdd = NSPasteboard.PasteboardType(rawValue: "private.table-row.kernelAdd")
    var dragDropAcpiPatch = NSPasteboard.PasteboardType(rawValue: "private.table-row.acpiPatch")
    var dragDropKernelPatch = NSPasteboard.PasteboardType(rawValue: "private.table-row.kernelPatch")
    var dragDropAcpiAdd = NSPasteboard.PasteboardType(rawValue: "private.table-row.acpiAdd")
    var drivesDict: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetTables()   // initialize table datasources

        for table in Array(tableLookup.keys) {              // setup table delegate and datasource
            table.delegate = self as NSTableViewDelegate
            table.dataSource = self
        }
        
        kernelAddTable.registerForDraggedTypes([dragDropKernelAdd])      // allow row reordering for kexts + acpi pactches table
        acpiPatchTable.registerForDraggedTypes([dragDropAcpiPatch])
        kernelPatchTable.registerForDraggedTypes([dragDropKernelPatch])
        acpiAddTable.registerForDraggedTypes([dragDropAcpiAdd])
        
        sectionsTable.action = #selector(onItemClicked)     // on section selection
        
        viewLookup = [
            0: acpiTab,
            1: deviceTab,
            2: kernelTab,
            3: miscTab,
            4: nvramTab,
            5: platformTab,
            6: uefiTab
        ]
        
        acpiQuirks = [
            "FadtEnableReset": self.FadtEnableReset,
            "IgnoreForWindows": self.IgnoreForWindows,
            "NormalizeHeaders": self.NormalizeHeaders,
            "RebaseRegions": self.RebaseRegions,
            "ResetLogoStatus": self.ResetLogoStatus
        ]
        
        /*deviceQuirks = [
            "ReinstallProtocol": self.ReinstallProtocol
        ]*/
        
        kernelQuirks = [
            "AppleCpuPmCfgLock": self.AppleCpuPmCfgLock,
            "AppleXcpmCfgLock": self.AppleXcpmCfgLock,
            "ExternalDiskIcons": self.ExternalDiskIcons,
            "ThirdPartyTrim": self.ThirdPartyTrim,
            "XhciPortLimit": self.XhciPortLimit
        ]
        
        uefiQuirks = [
            "IgnoreTextInGraphics": self.IgnoreTextInGraphics,
            "IgnoreInvalidFlexRatio": self.IgnoreInvalidFlexRatio,
            "ProvideConsoleGop": self.ProvideConsoleGop,
            "ReleaseUsbOwnership": self.ReleaseUsbOwnership,
            "RequestBootVarRouting": self.RequestBootVarRouting,
            "SanitiseClearScreen": self.SanitiseClearScreen
        ]
        
        uefiProtocols = [
            "AppleBootPolicy": self.AppleBootPolicy,
            "ConsoleControl": self.ConsoleControl,
            "DataHub": self.DataHub,
            "DeviceProperties": self.DeviceProperties
        ]
        
        acpiAutoBtn.toolTip = "Automatically check and add entries for all ACPI tables in EFI/OC/ACPI/Custom"
        kernelAutoBtn.toolTip = "Automatically check and add entries for all KEXTs in EFI/OC/Kexts"
        platformAutoBtn.toolTip = "Select an SMBIOS preset"
        uefiAutoBtn.toolTip = "Automatically check and add entries for all UEFI drivers in EFI/OC/Drivers"
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlistOpen(_:)), name: .plistOpen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPlistSave(_:)), name: .plistSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAcpiSyncPopover(_:)), name: .syncAcpiPopoverAndDict, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKernelSyncPopover(_:)), name: .syncKernelPopoverAndDict, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteVC(_:)), name: .paste, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyAllPatches(_:)), name: .applyAllPatches, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openVaultManager(_:)), name: .manageVault, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeVaultManager(_:)), name: .closeVault, object: nil)
    }
    
    var acpiTables: NSMutableDictionary = NSMutableDictionary()
    var currentTableData: Data = Data()
    
    override func keyDown(with event: NSEvent) {
        if (event.keyCode == 49){
            if sectionsTable.selectedRow == 0, (viewLookup[sectionsTable.selectedRow]!.selectedTabViewItem?.view?.subviews[0].subviews[1].subviews[0] as? NSTableView ?? NSTableView()) == acpiPatchTable {
                if acpiPatchTable.selectedRow != -1 {
                    let iaslPath = Bundle.main.path(forAuxiliaryExecutable: "iasl62")!
                    let currentRow = tableLookup[acpiPatchTable]![acpiPatchTable.selectedRow]
                    if currentRow["Find"]! != "", currentRow["Replace"]! != "", currentRow["TableSignature"]! != "" {       // only show differ if fields aren't empty
                        currentTableData = acpiTables.value(forKey: currentRow["TableSignature"]!) as? Data ?? Data()     // get apci table for patch
                        var beforeString = ""
                        var afterString = ""
                        let temporaryDirectory = FileManager.default.temporaryDirectory
                        let beforeURL = temporaryDirectory.appendingPathComponent("\(currentRow["TableSignature"]!)_before.aml", isDirectory: false)
                        let afterURL = temporaryDirectory.appendingPathComponent("\(currentRow["TableSignature"]!)_after.aml", isDirectory: false)
                        let beforeURLDecomp = temporaryDirectory.appendingPathComponent("\(currentRow["TableSignature"]!)_before.dsl", isDirectory: false)
                        let afterURLDecomp = temporaryDirectory.appendingPathComponent("\(currentRow["TableSignature"]!)_after.dsl", isDirectory: false)

                        do {
                            try currentTableData.write(to: beforeURL) // write unpatched table to file
                            try currentTableData.replaceSubranges(
                                of: currentRow["Find"]!,
                                with: currentRow["Replace"]!,
                                skip: Int(currentRow["Skip"]!) ?? 0,
                                count: Int(currentRow["Count"]!) ?? 0,
                                limit: Int(currentRow["Limit"]!) ?? 0
                            )
                            .write(to: afterURL) // write patched table to file
                            _ = shell(launchPath: iaslPath, arguments: [beforeURL.absoluteURL.path]) // decompile with iASL
                            _ = shell(launchPath: iaslPath, arguments: [afterURL.absoluteURL.path])
                            beforeString = try String(contentsOf: beforeURLDecomp) // open decompiled file as String
                            afterString = try String(contentsOf: afterURLDecomp)
                        } catch {
                            print("failed to write table data: \(error)")
                        }

                        currentTable = currentRow["TableSignature"]!        // set global variables for use in acpiDifferController
                        currentFind = String(data: Data(hexString: currentRow["Find"]!) ?? Data(), encoding: .ascii) ?? "??"
                        currentReplace = String(data: Data(hexString: currentRow["Replace"]!) ?? Data(), encoding: .ascii) ?? "??"
                        let acpiDifferVc = acpiDifferController.loadFromNib()
                        acpiDifferVc.showPopover(bounds: view.bounds, window: view)
                        acpiDifferVc.populatePopover(before: beforeString, after: afterString)
                    }
                }
            }
        }
    }
    
    var vaultWindow: NSWindow? = nil
    
    @objc func openVaultManager(_ notification: Notification) {
        if mountedESP != "" {
            let vault = openCoreVault()
            vaultWindow = vault.showVaultManager(vaultEnabled: miscRequireVault.state.rawValue)
            view.window!.beginSheet(vaultWindow!, completionHandler: nil)
        } else {
            messageBox(message: "No EFI partition selected", info: "Please select an EFI partition from the dropdown menu.")
        }
    }
    
    @objc func closeVaultManager(_ notification: Notification) {
        if vaultWindow != nil {
            view.window!.endSheet(vaultWindow!)
        }
    }
    
    @objc func applyAllPatches(_ notification: Notification) {
        for entry in tableLookup[acpiPatchTable]! {
            if entry["TableSignature"] == currentTable {
                currentTableData = currentTableData.replaceSubranges(of: entry["Find"]!, with: entry["Replace"]!, skip: Int(entry["Skip"]!) ?? 0, count: Int(entry["Count"]!) ?? 0, limit: Int(entry["Limit"]!) ?? 0)
            }
        }

        let iaslPath = Bundle.main.path(forAuxiliaryExecutable: "iasl62")!
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let allPatchesURL = temporaryDirectory.appendingPathComponent("\(currentTable)_allPatches.aml", isDirectory: false)

        do {
            try currentTableData.write(to: allPatchesURL)
            let _ = shell(launchPath: "/bin/bash", arguments: ["-c", iaslPath, allPatchesURL.absoluteURL.path])
            allPatchesApplied = try String(contentsOf: allPatchesURL)
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        do {
            try reloadEsps()
        } catch let error {
            NSApplication.shared.presentError(error)
        }

            // I stole this from MaciASL
            // TODO: write tables to file (xxd -r -p) and show differences
        let expert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleACPIPlatformExpert"))
        acpiTables = IORegistryEntryCreateCFProperty(expert, ("ACPI Tables" as CFString), kCFAllocatorDefault, 0)?.takeRetainedValue() as! NSMutableDictionary
        
        
        let officialOcVersions = [
            "REL-001-2019-05-03"
        ]
        
        let supportedOcVersions = [
            "REL-002-2019-05-08"
        ]
        
        let currentOcVersion = (shell(launchPath: "/bin/bash", arguments: ["-c", "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version | awk '{print $2}'"]) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let alert = NSAlert()
        
        if currentOcVersion != "" {
            if !officialOcVersions.contains(currentOcVersion) {
                if supportedOcVersions.contains(currentOcVersion) {
                    alert.messageText = "You are running a prerelease version of OpenCore."
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                } else {
                    alert.messageText = "You are running a prerelease version of OpenCore."
                    alert.informativeText = "This App was not designed to work with this version. It may not contain all options or use a different format. Use at your own risk!"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            } else {
                if !officialOcVersions.contains(currentOcVersion) {
                    alert.messageText = "You're running a version of OpenCore that this app does not currently support"
                    alert.informativeText = "It may not contain all options or use a different format. Use at your own risk!\nThese versions are officially supported:"
                    for version in supportedOcVersions {
                        alert.informativeText += "\n\(version)"
                    }
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
        } else {
            alert.messageText = "Could not get OpenCore version!"
            alert.informativeText = "Make sure you are creating a configuration file for a supported version.\nThese versions are officially supported:"
            for version in supportedOcVersions {
                alert.informativeText += "\n\(version)"
            }
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
        self.view.window?.makeKeyAndOrderFront(self.view.window)
    }
    
    func reloadEsps() throws {
        let diskList = try DiskUtility.listDisks()
        let containerList = try DiskUtility.listAPFSContainers()

        // Map our list of disks that have EFI partitions and mounted non-APFS volumes
        let espsForPartitions = diskList.efiPartitions
            .compactMap { partition -> (String, String)? in
                guard
                    let disk = diskList.disk(for: partition),
                    let mainPartition = disk.mountedPartitions.first(where: { $0.isEFI == false }),
                    let efiPartition = disk.efiPartition,
                    let volumeName = mainPartition.volumeName
                else {
                    return nil
                }
                return (volumeName, efiPartition.deviceIdentifier)
            }

        // It's necessary to do a double lookup here that crosses the disk and APFS lists to retrieve the first mounted APFS volume of an APFS container partition that has an EFI sibling partition.
        let espsForVolumes = Set(diskList.disksWithAPFSContainers)
            .intersection(diskList.disksWithEFIPartitions)
            .compactMap { disk -> (String, String)? in
                guard
                    let efiPartition = disk.efiPartition,
                    let apfsContainerPartition = disk.partitions.first(where: { $0.isAPFSContainer }),
                    let apfsVolume = containerList.containerUsingPhysicalStore(for: apfsContainerPartition.diskUUID)?.volumes.first,
                    let containerDisk = diskList.disk(for: apfsVolume),
                    let mountedVolume = containerDisk.mountedAPFSVolumes.first
                else {
                    return nil
                }

                return (mountedVolume.volumeName, efiPartition.deviceIdentifier)
            }

        // Populate the drives dictionary
        drivesDict = Dictionary(uniqueKeysWithValues: espsForPartitions + espsForVolumes)

        // Reset the ESP pop-up menu
        espPopup.removeAllItems()
        espPopup.addItem(withTitle: "Select an EFI partition…")
        espPopup.menu?.addItem(NSMenuItem.separator())

        // Populate the pop-up menu
        drivesDict.keys.forEach(espPopup.addItem(withTitle:))
    }

    func resetTables() {
        tableLookup = [             // lookup table holding the datasources to the tableviews
            sectionsTable: [["section": "ACPI"],["section": "Device Properties"],["section": "Kernel"],["section": "Misc"],["section": "NVRAM"],["section": "Platform Info"],["section": "UEFI"]],
            acpiAddTable: [[String: String]](),
            acpiBlockTable: [[String: String]](),
            acpiPatchTable: [[String: String]](),
            deviceAddTable: [[String: String]](),
            deviceBlockTable: [[String: String]](),
            kernelAddTable: [[String: String]](),
            kernelBlockTable: [[String: String]](),
            kernelPatchTable: [[String: String]](),
            nvramBootTable: [[String: String]](),
            nvramVendorTable: [[String: String]](),
            nvramCustomTable: [[String: String]](),
            nvramBlockTable: [[String: String]](),
            uefiDriverTable: [[String: String]](),
            platformSmbiosTable: [["property": "BIOSVendor", "value": ""],
                                  ["property": "BIOSVersion", "value": ""],
                                  ["property": "BIOSReleaseDate", "value": ""],
                                  ["property": "SystemManufacturer", "value": ""],
                                  ["property": "SystemProductName", "value": ""],
                                  ["property": "SystemVersion", "value": ""],
                                  ["property": "SystemSerialNumber", "value": ""],
                                  ["property": "SystemUUID", "value": ""],
                                  ["property": "SystemSKUNumber", "value": ""],
                                  ["property": "SystemFamily", "value": ""],
                                  ["property": "BoardManufacturer", "value": ""],
                                  ["property": "BoardProduct", "value": ""],
                                  ["property": "BoardVersion", "value": ""],
                                  ["property": "BoardSerialNumber", "value": ""],
                                  ["property": "BoardAssetTag", "value": ""],
                                  ["property": "BoardType", "value": ""],
                                  ["property": "BoardLocationInChassis", "value": ""],
                                  ["property": "ChassisManufacturer", "value": ""],
                                  ["property": "ChassisType", "value": ""],
                                  ["property": "ChassisVersion", "value": ""],
                                  ["property": "ChassisSerialNumber", "value": ""],
                                  ["property": "ChassisAssetTag", "value": ""],
                                  ["property": "PlatformFeature", "value": ""],
                                  ["property": "FirmwareFeatures", "value": ""],
                                  ["property": "FirmwareFeaturesMask", "value": ""],
                                  ["property": "ProcessorType", "value": ""],
                                  ["property": "MemoryFormFactor", "value": ""]],
            
            platformDatahubTable: [["property": "ARTFrequency", "value": ""],
                                   ["property": "BoardProduct", "value": ""],
                                   ["property": "BoardRevision", "value": ""],
                                   ["property": "DevicePathsSupported", "value": ""],
                                   ["property": "FSBFrequency", "value": ""],
                                   ["property": "InitialTSC", "value": ""],
                                   ["property": "PlatformName", "value": ""],
                                   ["property": "SmcBranch", "value": ""],
                                   ["property": "SmcPlatform", "value": ""],
                                   ["property": "SmcRevision", "value": ""],
                                   ["property": "StartupPowerEvents", "value": ""],
                                   ["property": "SystemProductName", "value": ""],
                                   ["property": "SystemSerialNumber", "value": ""],
                                   ["property": "SystemUUID", "value": ""]],
            
            platformGenericTable: [["property": "SystemUUID", "value": ""],
                                   ["property": "MLB", "value": ""],
                                   ["property": "ROM", "value": ""],
                                   ["property": "SystemProductName", "value": ""],
                                   ["property": "SystemSerialNumber", "value": ""]],
            
            platformNvramTable: [["property": "BID", "value": ""],
                                 ["property": "MLB", "value": ""],
                                 ["property": "ROM", "value": ""],
                                 ["property": "FirmwareFeatures", "value": ""],
                                 ["property": "FirmwareFeaturesMask", "value": ""]]
        ]
    }
    
    @objc func acpiAdvanced(_ sender: NSButton) {
        let acpiVc = AcpiPopoverController.loadFromNib()        // load popover viewcontroller set up in AcpiPopoverController.swift
        
        acpiPatchTable.selectRowIndexes(IndexSet(integer: Int(sender.identifier!.rawValue)!), byExtendingSelection: false)      // select row the button belongs to for the code below to work
                                                                                                                                // TODO: rely only on button identifier, not selected row, so we can allow an empty selection like in all other tables
        
        acpiLimitString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"] ?? ""        // fill variables with contents of plist file
        acpiMaskString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"] ?? ""
        acpiOemTableIdString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["OemTableId"] ?? ""
        acpiReplaceMaskString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"] ?? ""
        acpiSkipString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"] ?? ""
        acpiTableLengthString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["TableLength"] ?? ""
        acpiCountString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Count"] ?? ""
        
        acpiVc.showPopover(button: sender)
    }
    
    @objc func kernelAdvanced(_ sender: NSButton) {
        let kernelVc = KernelPopoverController.loadFromNib()
        
        kernelPatchTable.selectRowIndexes(IndexSet(integer: Int(sender.identifier!.rawValue)!), byExtendingSelection: false)
        
        kernelBaseString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Base"] ?? ""
        kernelCountString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Count"] ?? ""
        kernelIdentifierString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Identifier"] ?? ""
        kernelLimitString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"] ?? ""
        kernelMaskString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"] ?? ""
        kernelReplaceString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"] ?? ""
        kernelSkipString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"] ?? ""
        
        kernelVc.showPopover(button: sender)
    }
    
    @objc func onAcpiSyncPopover(_ notification: Notification) {
        tableLookup[acpiPatchTable]![acpiPatchTable.selectedRow][(acpiCurrentTextField.identifier?.rawValue)!] = acpiCurrentTextField.stringValue
    }
    
    @objc func onKernelSyncPopover(_ notification: Notification) {
        tableLookup[kernelPatchTable]![kernelPatchTable.selectedRow][(kernelCurrentTextField.identifier?.rawValue)!] = kernelCurrentTextField.stringValue
    }
    
    @objc func onPasteVC(_ notification: Notification) {
        if sectionsTable.selectedRow == 0, (viewLookup[sectionsTable.selectedRow]!.selectedTabViewItem?.view?.subviews[0].subviews[1].subviews[0] as! NSTableView) == acpiPatchTable {
            let currentTable = viewLookup[sectionsTable.selectedRow]!.selectedTabViewItem?.view?.subviews[0].subviews[1].subviews[0] as! NSTableView
            let pastedDictString = NSPasteboard.general.string(forType: .string) ?? ""
            do {
                if let pastedPlist = try PropertyListSerialization.propertyList(from: pastedDictString.data(using: .utf8)!, format: .none)
                    as? NSMutableDictionary  {
                    // Successfully read property list.
                    parsePastedPlist(currentTable: currentTable, pastedPlist: pastedPlist)
                    
                } else if let pastedPlist = try PropertyListSerialization.propertyList(from: pastedDictString.data(using: .utf8)!, format: .none)
                    as? NSMutableArray {
                    for dict in pastedPlist {
                        parsePastedPlist(currentTable: currentTable, pastedPlist: dict as! NSMutableDictionary)
                    }
                } else {
                    print("not a dictionary")
                }
            } catch let error {
                print("not a plist:", error.localizedDescription)
            }
        }
    }
    
    func parsePastedPlist(currentTable: NSTableView, pastedPlist: NSMutableDictionary) {
        let tempDict: NSMutableDictionary = NSMutableDictionary()
        if (pastedPlist.allKeys as! [String]).contains("Find") {
            tempDict.addEntries(from: ["Comment": pastedPlist.value(forKey: "Comment") as? String ?? String()])
            tempDict.addEntries(from: ["Count": String(pastedPlist.value(forKey: "Count") as? Int ?? Int())])
            tempDict.addEntries(from: ["Limit": String(pastedPlist.value(forKey: "Limit") as? Int ?? Int())])
            tempDict.addEntries(from: ["Skip": String(pastedPlist.value(forKey: "Skip") as? Int ?? Int())])
            tempDict.addEntries(from: ["TableLength": String(pastedPlist.value(forKey: "TableLength") as? Int ?? Int())])
            tempDict.addEntries(from: ["Find": (pastedPlist.value(forKey: "Find") as? Data)?.hexEncodedString(options: .upperCase) ?? String()])
            tempDict.addEntries(from: ["Replace": (pastedPlist.value(forKey: "Replace") as? Data)?.hexEncodedString(options: .upperCase) ?? String()])
            tempDict.addEntries(from: ["Mask": (pastedPlist.value(forKey: "Mask") as? Data)?.hexEncodedString(options: .upperCase) ?? String()])
            tempDict.addEntries(from: ["OemTableId": (pastedPlist.value(forKey: "OemTableId") as? Data)?.hexEncodedString(options: .upperCase) ?? String()])
            tempDict.addEntries(from: ["ReplaceMask": (pastedPlist.value(forKey: "ReplaceMask") as? Data)?.hexEncodedString(options: .upperCase) ?? String()])
            tempDict.addEntries(from: ["TableSignature": String(data: pastedPlist.value(forKey: "Count") as? Data ?? Data(), encoding: .ascii) ?? String()])
        }

        if (pastedPlist.value(forKey: "Enabled") as? Bool ?? false) == true {
            tempDict.setValue("1", forKey: "Enabled")
        } else {
            tempDict.setValue("0", forKey: "Enabled")
        }
        
        if (pastedPlist.allKeys as! [String]).contains("Disabled") {
            if (pastedPlist.value(forKey: "Disabled") as? Bool ?? true) == false {
                tempDict.setValue("1", forKey: "Enabled")
            } else {
                tempDict.setValue("0", forKey: "Enabled")
            }
        }
        
        if tempDict != ["Find": ""] {
            tableLookup[currentTable]?.append(tempDict as! [String: String])
            currentTable.reloadData()
        }
    }
    
    @objc func deviceEdit(_ sender: NSButton) {
        let customItem = NSAlert()
        customItem.addButton(withTitle: "OK")      // 1st button
        customItem.addButton(withTitle: "Cancel")  // 2nd button
        customItem.messageText = "Edit value as String"
        customItem.informativeText = ""

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        
        txt.stringValue = String(decoding: Data(hexString: tableLookup[deviceAddTable]![Int(sender.identifier!.rawValue)!]["value"]!)!, as: UTF8.self)
        
        customItem.accessoryView = txt
        let response: NSApplication.ModalResponse = customItem.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            tableLookup[deviceAddTable]![Int(sender.identifier!.rawValue)!]["value"] = txt.stringValue.data(using: .ascii)?.hexEncodedString(options: .upperCase)
            deviceAddTable.reloadData()
        }
    }
    
     var acpiDict: NSMutableDictionary = NSMutableDictionary()
     var acpiQuirksDict: NSMutableDictionary = NSMutableDictionary()
     var acpiAddArray: NSMutableArray = NSMutableArray()
     var acpiBlockArray: NSMutableArray = NSMutableArray()
     var acpiPatchArray: NSMutableArray = NSMutableArray()
     var deviceDict: NSMutableDictionary = NSMutableDictionary()
     var deviceAddDict: NSMutableDictionary = NSMutableDictionary()
     var deviceBlockDict: NSMutableDictionary = NSMutableDictionary()
     var deviceQuirksDict: NSMutableDictionary = NSMutableDictionary()
     var kernelDict: NSMutableDictionary = NSMutableDictionary()
     var kernelAddArray: NSMutableArray = NSMutableArray()
     var kernelBlockArray: NSMutableArray = NSMutableArray()
     var kernelPatchArray: NSMutableArray = NSMutableArray()
     var kernelQuirksDict: NSMutableDictionary = NSMutableDictionary()
     var miscDict: NSMutableDictionary = NSMutableDictionary()
     var miscBootDict: NSMutableDictionary = NSMutableDictionary()
     var miscDebugDict: NSMutableDictionary = NSMutableDictionary()
     var miscSecurityDict: NSMutableDictionary = NSMutableDictionary()
     var nvramDict: NSMutableDictionary = NSMutableDictionary()
     var nvramAddDict: NSMutableDictionary = NSMutableDictionary()
     var nvramBlockDict: NSMutableDictionary = NSMutableDictionary()
     var uefiDict: NSMutableDictionary = NSMutableDictionary()
     var uefiDriverArray: NSMutableArray = NSMutableArray()
     var uefiConnectDriversBool: Bool = Bool()
     var uefiQuirksDict: NSMutableDictionary = NSMutableDictionary()
     var uefiProtocolsDict: NSMutableDictionary = NSMutableDictionary()
     var platformInfoDict: NSMutableDictionary = NSMutableDictionary()
     var platformSmbiosDict: NSMutableDictionary = NSMutableDictionary()
     var platformDatahubDict: NSMutableDictionary = NSMutableDictionary()
     var platformGenericDict: NSMutableDictionary = NSMutableDictionary()
     var platformNvramDict: NSMutableDictionary = NSMutableDictionary()
     var platformAutomaticBool: Bool = Bool()
     var platformUpdateDatahubBool: Bool = Bool()
     var platformUpdateNvramBool: Bool = Bool()
     var platformUpdateSmbiosBool: Bool = Bool()
     var platformUpdateSmbiosModeStr: String = String()

    @objc func onPlistOpen(_ notification: Notification) {
        resetTables()       // clear tables before adding new data to them
        
        let OHF = openHandlerFunctions()
        let plistDict = NSMutableDictionary(contentsOfFile: path)
        acpiDict = plistDict?.object(forKey: "ACPI") as? NSMutableDictionary ?? NSMutableDictionary()            // for now we're manually extracting each individual dict entry, this should be changed to doing this in a loop in the future,
        acpiQuirksDict = acpiDict.object(forKey: "Quirks") as? NSMutableDictionary ?? NSMutableDictionary()
        acpiAddArray = acpiDict.object(forKey: "Add") as? NSMutableArray ?? NSMutableArray()
        
        if acpiAddArray.count > 0 {
            for i in 0...(acpiAddArray.count - 1) {
                let tempDict = (acpiAddArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as? Bool ?? false) == true {
                    tempDict.setValue("1", forKey: "Enabled")
                } else {
                    tempDict.setValue("0", forKey: "Enabled")
                }
                acpiAddArray[i] = tempDict
            }
        }
        
        acpiBlockArray = acpiDict.object(forKey: "Block") as? NSMutableArray ?? NSMutableArray()
        
        if acpiBlockArray.count > 0 {
            for i in 0...(acpiBlockArray.count - 1) {
                let tempDict = (acpiBlockArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                tempDict.setValue(String(data: tempDict.value(forKey: "TableSignature") as? Data ?? Data(), encoding: .ascii), forKey: "TableSignature")    // since the popup button is now reading the value directly instead of decoding it, we need to decode it here manually
                acpiBlockArray[i] = tempDict
            }
        }
        
        acpiPatchArray = acpiDict.object(forKey: "Patch") as? NSMutableArray ?? NSMutableArray()
        
        if acpiPatchArray.count > 0 {                                                                       // decode all non-String data into Strings. Not using the openHander function because these tables need support
            for i in 0...(acpiPatchArray.count - 1) {                                                       // for reordering and the openHanderfunctions don't ensure the correct order
                let tempDict = (acpiPatchArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as? Bool ?? false) == true {
                    tempDict.setValue("1", forKey: "Enabled")
                } else {
                    tempDict.setValue("0", forKey: "Enabled")
                }
                tempDict.setValue(String(tempDict.value(forKey: "Count") as? Int ?? Int()), forKey: "Count")
                tempDict.setValue(String(tempDict.value(forKey: "Limit") as? Int ?? Int()), forKey: "Limit")
                tempDict.setValue(String(tempDict.value(forKey: "Skip") as? Int ?? Int()), forKey: "Skip")
                tempDict.setValue(String(tempDict.value(forKey: "TableLength") as? Int ?? Int()), forKey: "TableLength")
                tempDict.setValue((tempDict.value(forKey: "Find") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Find")
                tempDict.setValue((tempDict.value(forKey: "Replace") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Replace")
                tempDict.setValue((tempDict.value(forKey: "Mask") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Mask")
                tempDict.setValue((tempDict.value(forKey: "OemTableId") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "OemTableId")
                tempDict.setValue((tempDict.value(forKey: "ReplaceMask") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "ReplaceMask")
                tempDict.setValue(String(data: tempDict.value(forKey: "TableSignature") as? Data ?? Data(), encoding: .ascii), forKey: "TableSignature")
                acpiPatchArray[i] = tempDict
            }
        }
        
        deviceDict = plistDict?.object(forKey: "DeviceProperties") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceAddDict = deviceDict.object(forKey: "Add") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceBlockDict = deviceDict.object(forKey: "Block") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceQuirksDict = deviceDict.object(forKey: "Quirks") as? NSMutableDictionary ?? NSMutableDictionary()
        
        kernelDict = plistDict?.object(forKey: "Kernel") as? NSMutableDictionary ?? NSMutableDictionary()
        kernelAddArray = kernelDict.object(forKey: "Add") as? NSMutableArray ?? NSMutableArray()
        
        if kernelAddArray.count > 0 {
            for i in 0...(kernelAddArray.count - 1) {
                let tempDict = (kernelAddArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as? Bool ?? false) == true {
                    tempDict.setValue("1", forKey: "Enabled")
                } else {
                    tempDict.setValue("0", forKey: "Enabled")
                }
                kernelAddArray[i] = tempDict
            }
        }
        
        kernelBlockArray = kernelDict.object(forKey: "Block") as? NSMutableArray ?? NSMutableArray()
        kernelPatchArray = kernelDict.object(forKey: "Patch") as? NSMutableArray ?? NSMutableArray()
        
        if kernelPatchArray.count > 0 {
            for i in 0...(kernelPatchArray.count - 1) {
                let tempDict = (kernelPatchArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as? Bool ?? false) == true {
                    tempDict.setValue("1", forKey: "Enabled")
                } else {
                    tempDict.setValue("0", forKey: "Enabled")
                }
                tempDict.setValue(String(tempDict.value(forKey: "Count") as? Int ?? Int()), forKey: "Count")
                tempDict.setValue(String(tempDict.value(forKey: "Limit") as? Int ?? Int()), forKey: "Limit")
                tempDict.setValue(String(tempDict.value(forKey: "Skip") as? Int ?? Int()), forKey: "Skip")
                tempDict.setValue((tempDict.value(forKey: "Find") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Find")
                tempDict.setValue((tempDict.value(forKey: "Replace") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Replace")
                tempDict.setValue((tempDict.value(forKey: "Mask") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "Mask")
                tempDict.setValue((tempDict.value(forKey: "ReplaceMask") as? Data)?.hexEncodedString(options: .upperCase) ?? String(), forKey: "ReplaceMask")
                kernelPatchArray[i] = tempDict
            }
        }
        
        kernelQuirksDict = kernelDict.object(forKey: "Quirks") as? NSMutableDictionary ?? NSMutableDictionary()
        
        miscDict = plistDict?.object(forKey: "Misc") as? NSMutableDictionary ?? NSMutableDictionary()
        miscBootDict = miscDict.object(forKey: "Boot") as? NSMutableDictionary ?? NSMutableDictionary()
        miscDebugDict = miscDict.object(forKey: "Debug") as? NSMutableDictionary ?? NSMutableDictionary()
        miscSecurityDict = miscDict.object(forKey: "Security") as? NSMutableDictionary ?? NSMutableDictionary()
        
        nvramDict = plistDict?.object(forKey: "NVRAM") as? NSMutableDictionary ?? NSMutableDictionary()
        nvramAddDict = nvramDict.object(forKey: "Add") as? NSMutableDictionary ?? NSMutableDictionary()
        nvramBlockDict = nvramDict.object(forKey: "Block") as? NSMutableDictionary ?? NSMutableDictionary()
        
        uefiDict = plistDict?.object(forKey: "UEFI") as? NSMutableDictionary ?? NSMutableDictionary()
        uefiDriverArray = uefiDict.object(forKey: "Drivers") as? NSMutableArray ?? NSMutableArray()
        uefiConnectDriversBool = uefiDict.object(forKey: "ConnectDrivers") as? Bool ?? false
        uefiQuirksDict = uefiDict.object(forKey: "Quirks") as? NSMutableDictionary ?? NSMutableDictionary()
        uefiProtocolsDict = uefiDict.object(forKey: "Protocols") as? NSMutableDictionary ?? NSMutableDictionary()
        let uefiExitBootInt = uefiQuirksDict.object(forKey: "ExitBootServicesDelay") as? Int ?? Int()
        
        platformInfoDict = plistDict?.object(forKey: "PlatformInfo") as? NSMutableDictionary ?? NSMutableDictionary()
        platformSmbiosDict = platformInfoDict.object(forKey: "SMBIOS") as? NSMutableDictionary ?? NSMutableDictionary()
        platformDatahubDict = platformInfoDict.object(forKey: "DataHub") as? NSMutableDictionary ?? NSMutableDictionary()
        platformGenericDict = platformInfoDict.object(forKey: "Generic") as? NSMutableDictionary ?? NSMutableDictionary()
        platformNvramDict = platformInfoDict.object(forKey: "PlatformNVRAM") as? NSMutableDictionary ?? NSMutableDictionary()
        platformAutomaticBool = platformInfoDict.object(forKey: "Automatic") as? Bool ?? false
        platformUpdateDatahubBool = platformInfoDict.object(forKey: "UpdateDataHub") as? Bool ?? false
        platformUpdateNvramBool = platformInfoDict.object(forKey: "UpdateNVRAM") as? Bool ?? false
        platformUpdateSmbiosBool = platformInfoDict.object(forKey: "UpdateSMBIOS") as? Bool ?? false
        platformUpdateSmbiosModeStr = platformInfoDict.object(forKey: "UpdateSMBIOSMode") as? String ?? String()
        
        topLevelBools = [
            uefiConnectDrivers: uefiConnectDriversBool,
            smbiosAutomatic: platformAutomaticBool,
            updateDatahub: platformUpdateDatahubBool,
            updateNvram: platformUpdateNvramBool,
            updateSmbios: platformUpdateSmbiosBool
        ]
        
        for (key, value) in miscBootDict {      // we're not dealing with tables here so it's easier to just parse the data manually. This sucks but I don't have a better idea for this atm
            switch key as? String ?? "" {
            case "ShowPicker":
                if value as? Bool ?? false {
                    showPicker.state = .on
                }
                else {
                    showPicker.state = .off
                }
                
            case "Timeout":
                timeoutStepper.stringValue = String(value as? Int ?? Int())
                timeoutTextfield.stringValue = String(value as? Int ?? Int())
            case "ConsoleMode":
                consoleMode.stringValue = value as? String ?? ""
            case "ConsoleBehaviourOs":
                if value as? String ?? "" != "" {
                    if OsBehavior.itemTitles.contains(value as? String ?? "") {
                        OsBehavior.selectItem(withTitle: value as? String ?? "")
                    }
                } else {
                    OsBehavior.selectItem(withTitle: "Don't change")
                }
            case "ConsoleBehaviourUi":
                if value as? String ?? "" != "" {
                    if UiBehavior.itemTitles.contains(value as? String ?? "") {
                        UiBehavior.selectItem(withTitle: value as? String ?? "")
                    }
                } else {
                    UiBehavior.selectItem(withTitle: "Don't change")
                }
            case "HideSelf":
                if value as? Bool ?? false {
                    hideSelf.state = .on
                }
                else {
                    hideSelf.state = .off
                }
            case "Resolution":
                resolution.stringValue = value as? String ?? ""
            default:
                break
            }
        }
        
        for (key, value) in miscDebugDict {
            switch key as? String ?? "" {
            case "DisplayDelay":
                miscDelayText.stringValue = String(value as? Int ?? Int())
            case "DisplayLevel":
                miscDisplayLevelText.stringValue = String(value as? Int ?? Int())
            case "Target":
                miscTargetText.stringValue = String(value as? Int ?? Int())
            case "DisableWatchDog":
                if value as? Bool ?? false {
                    disableWatchdog.state = .on
                } else {
                    disableWatchdog.state = .off
                }
            default:
                break
            }
        }
        
        for (key, value) in miscSecurityDict {
            switch key as? String ?? "" {
            case "HaltLevel":
                miscHaltlevel.stringValue = String(value as? Int ?? Int())
            case "RequireSignature":
                if value as? Bool ?? false {
                    miscRequireSignature.state = .on
                }
                else {
                    miscRequireSignature.state = .off
                }
            case "RequireVault":
                if value as? Bool ?? false {
                    miscRequireVault.state = .on
                }
                else {
                    miscRequireVault.state = .off
                }
            case "ExposeSensitiveData":
                miscExposeSensitiveData.stringValue = String(value as? Int ?? Int())
            default:
                break
            }
        }
        
        for (key, value) in nvramAddDict {
            switch key as? String ?? "" {
            case "7C436110-AB2A-4BBB-A880-FE41995C9F82":
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramBootTable)
            case "4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14":
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramVendorTable)
            default:
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramCustomTable, guidString: key as? String)
            }
        }
        
        for (key, value) in nvramBlockDict {
            OHF.createNvramData(value: value as? NSMutableArray ?? NSMutableArray(), table: &nvramBlockTable, guidString: key as? String)
        }
        
        OHF.createTopLevelBools(buttonDict: &topLevelBools)
        
        if smbioUpdateModePopup.itemTitles.contains(platformUpdateSmbiosModeStr) {
            smbioUpdateModePopup.selectItem(withTitle: platformUpdateSmbiosModeStr)
        } else {
            smbioUpdateModePopup.selectItem(withTitle: "Create")
        }
        
        //OHF.createData(input: acpiAddArray, table: &acpiAddTable, predefinedKey: "acpiAdd")
        tableLookup[acpiAddTable] = acpiAddArray as? Array ?? Array()
        acpiAddTable.reloadData()
        OHF.createData(input: acpiBlockArray, table: &acpiBlockTable)
        //OHF.createData(input: acpiPatchArray, table: &acpiPatchTable)
        tableLookup[acpiPatchTable] = acpiPatchArray as? Array ?? Array()
        acpiPatchTable.reloadData()
        OHF.createQuirksData(input: acpiQuirksDict, quirksDict: acpiQuirks)
        
        OHF.createData(input: deviceAddDict, table: &deviceAddTable)
        OHF.createData(input: deviceBlockDict, table: &deviceBlockTable)
        // OHF.createQuirksData(input: deviceQuirksDict, quirksDict: deviceQuirks)          // device properties quirks don't exist anymore. leaving this here in case they come back
        
        //OHF.createData(input: kernelAddArray, table: &kernelAddTable)
        tableLookup[kernelAddTable] = kernelAddArray as? Array ?? Array()
        kernelAddTable.reloadData()
        OHF.createData(input: kernelBlockArray, table: &kernelBlockTable)
        //OHF.createData(input: kernelPatchArray, table: &kernelPatchTable)
        tableLookup[kernelPatchTable] = kernelPatchArray as? Array ?? Array()
        kernelPatchTable.reloadData()
        OHF.createQuirksData(input: kernelQuirksDict, quirksDict: kernelQuirks)
        
        OHF.createData(input: uefiDriverArray, table: &uefiDriverTable, predefinedKey: "driver")
        OHF.createQuirksData(input: uefiQuirksDict, quirksDict: uefiQuirks)
        OHF.createQuirksData(input: uefiProtocolsDict, quirksDict: uefiProtocols)
        ExitBootServicesDelay.stringValue = String(uefiExitBootInt)
        
        OHF.createData(input: platformSmbiosDict, table: &platformSmbiosTable)
        OHF.createData(input: platformDatahubDict, table: &platformDatahubTable)
        OHF.createData(input: platformGenericDict, table: &platformGenericTable)
        if platformGenericDict.value(forKey: "SpoofVendor") as? Bool ?? false {
            spoofVendor.state = .on
        } else {
            spoofVendor.state = .off
        }
        
        OHF.createData(input: platformNvramDict, table: &platformNvramTable)

        togglePlatformAutomatic()
        
        self.view.window?.title = "\((path as NSString).lastPathComponent) - OpenCore Configurator"
        self.view.window?.representedURL = URL(fileURLWithPath: path)
    }
    
    @objc func onPlistSave(_ notification: Notification) {

        let SHF = saveHandlerFunctions()
        
        SHF.saveArrayOfDictData(table: acpiAddTable, array: &acpiAddArray)
        SHF.saveArrayOfDictData(table: acpiBlockTable, array: &acpiBlockArray)
        //SHF.saveArrayOfDictData(table: acpiPatchTable, array: &acpiPatchArray)
        acpiPatchArray = (tableLookup[acpiPatchTable]! as NSArray).mutableCopy() as! NSMutableArray
        if acpiPatchArray.count > 0 {
            for i in 0...(acpiPatchArray.count - 1) {
                let tempDict = (acpiPatchArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as! String) == "1" {
                    tempDict.setValue(true, forKey: "Enabled")
                } else {
                    tempDict.setValue(false, forKey: "Enabled")
                }
                tempDict.setValue(Int(tempDict.value(forKey: "Count") as! String), forKey: "Count")
                tempDict.setValue(Int(tempDict.value(forKey: "Limit") as! String), forKey: "Limit")
                tempDict.setValue(Int(tempDict.value(forKey: "Skip") as! String), forKey: "Skip")
                tempDict.setValue(Int(tempDict.value(forKey: "TableLength") as! String), forKey: "TableLength")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Find") as! String), forKey: "Find")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Replace") as! String), forKey: "Replace")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Mask") as! String), forKey: "Mask")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "OemTableId") as! String), forKey: "OemTableId")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "ReplaceMask") as! String), forKey: "ReplaceMask")
                tempDict.setValue((tempDict.value(forKey: "TableSignature") as! String).data(using: .ascii), forKey: "TableSignature")
                tempDict.removeObject(forKey: "advanced")
                acpiPatchArray[i] = tempDict
            }
        }
        
        SHF.saveQuirksData(dict: acpiQuirks, quirksDict: &acpiQuirksDict)
        
        //SHF.saveArrayOfDictData(table: kernelAddTable, array: &kernelAddArray)
        kernelAddArray = (tableLookup[kernelAddTable]! as NSArray).mutableCopy() as! NSMutableArray
        if kernelAddArray.count > 0 {
            for i in 0...(kernelAddArray.count - 1) {
                let tempDict = (kernelAddArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as! String) == "1" {
                    tempDict.setValue(true, forKey: "Enabled")
                } else {
                    tempDict.setValue(false, forKey: "Enabled")
                }
                kernelAddArray[i] = tempDict
            }
        }
        SHF.saveArrayOfDictData(table: kernelBlockTable, array: &kernelBlockArray)
        //SHF.saveArrayOfDictData(table: kernelPatchTable, array: &kernelPatchArray)
        kernelPatchArray = (tableLookup[kernelPatchTable]! as NSArray).mutableCopy() as! NSMutableArray
        if kernelPatchArray.count > 0 {
            for i in 0...(kernelPatchArray.count - 1) {
                let tempDict = (kernelPatchArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if (tempDict.value(forKey: "Enabled") as! String) == "1" {
                    tempDict.setValue(true, forKey: "Enabled")
                } else {
                    tempDict.setValue(false, forKey: "Enabled")
                }
                tempDict.setValue(Int(tempDict.value(forKey: "Count") as! String), forKey: "Count")
                tempDict.setValue(Int(tempDict.value(forKey: "Limit") as! String), forKey: "Limit")
                tempDict.setValue(Int(tempDict.value(forKey: "Skip") as! String), forKey: "Skip")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Find") as! String), forKey: "Find")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Replace") as! String), forKey: "Replace")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "Mask") as! String), forKey: "Mask")
                tempDict.setValue(Data(hexString: tempDict.value(forKey: "ReplaceMask") as! String), forKey: "ReplaceMask")
                tempDict.removeObject(forKey: "kernelAdvanced")
                kernelPatchArray[i] = tempDict
            }
        }
        SHF.saveQuirksData(dict: kernelQuirks, quirksDict: &kernelQuirksDict)
        
        SHF.saveDeviceData(table: deviceAddTable, dict: &deviceAddDict)
        SHF.saveDeviceData(table: deviceBlockTable, dict: &deviceBlockDict)
        SHF.saveQuirksData(dict: deviceQuirks, quirksDict: &deviceQuirksDict)
        
            // only process platform dicts if they're not empty. This is not necessary because we're checking this when appending to the platform dict too, but this is cleaner because we don't do unnecessary work
        if isNotEmpty(platformGenericDict) { SHF.saveDictOfDictData(table: platformGenericTable, dict: &platformGenericDict) }
        if isNotEmpty(platformNvramDict) { SHF.saveDictOfDictData(table: platformNvramTable, dict: &platformNvramDict) }
        if isNotEmpty(platformSmbiosDict) { SHF.saveDictOfDictData(table: platformSmbiosTable, dict: &platformSmbiosDict) }
        if isNotEmpty(platformDatahubDict) { SHF.saveDictOfDictData(table: platformDatahubTable, dict: &platformDatahubDict) }
        
        SHF.saveStringData(table: uefiDriverTable, array: &uefiDriverArray)
        SHF.saveQuirksData(dict: uefiQuirks, quirksDict: &uefiQuirksDict)
        uefiQuirksDict.addEntries(from: ["ExitBootServicesDelay": Int(ExitBootServicesDelay.stringValue) ?? 0])
        SHF.saveQuirksData(dict: uefiProtocols, quirksDict: &uefiProtocolsDict)
        
        SHF.saveNvramBootData(table: nvramBootTable, dict: &nvramAddDict)       // TODO: create subdicts for GUID, handle custom table seperately
        SHF.saveNvramVendorData(table: nvramVendorTable, dict: &nvramAddDict)
        SHF.saveNvramCustomData(table: nvramCustomTable, dict: &nvramAddDict)
        clearDict = true                                                    // we split data from the same dict into 3 tables, so we don't want to clear it for each of them
        SHF.saveNvramBlockData(table: nvramBlockTable, dict: &nvramBlockDict)
        
        acpiDict.removeAllObjects()
        acpiDict.addEntries(from: ["Add": acpiAddArray])
        acpiDict.addEntries(from: ["Block": acpiBlockArray])
        acpiDict.addEntries(from: ["Patch": acpiPatchArray])
        acpiDict.addEntries(from: ["Quirks": acpiQuirksDict])
        
        kernelDict.removeAllObjects()
        kernelDict.addEntries(from: ["Add": kernelAddArray])
        kernelDict.addEntries(from: ["Block": kernelBlockArray])
        kernelDict.addEntries(from: ["Patch": kernelPatchArray])
        kernelDict.addEntries(from: ["Quirks": kernelQuirksDict])
        
        deviceDict.removeAllObjects()
        deviceDict.addEntries(from: ["Add": deviceAddDict])
        deviceDict.addEntries(from: ["Block": deviceBlockDict])
        //deviceDict.addEntries(from: ["Quirks": deviceQuirksDict])
        
        platformInfoDict.removeAllObjects()
        if smbiosAutomatic.state == .on {
            platformInfoDict.addEntries(from: ["Automatic": true])
        } else {
            platformInfoDict.addEntries(from: ["Automatic": false])
        }                                                                // only add platform dicts if they're not empty
        if isNotEmpty(platformDatahubDict) { platformInfoDict.addEntries(from: ["DataHub": platformDatahubDict]) }
        if isNotEmpty(platformGenericDict) { platformInfoDict.addEntries(from: ["Generic": platformGenericDict]) }
        if spoofVendor.state == .on {
            platformGenericDict.addEntries(from: ["SpoofVendor": true])
        } else {
            platformGenericDict.addEntries(from: ["SpoofVendor": false])
        }
        
        if isNotEmpty(platformNvramDict) { platformInfoDict.addEntries(from: ["PlatformNVRAM": platformNvramDict]) }
        if isNotEmpty(platformSmbiosDict) { platformInfoDict.addEntries(from: ["SMBIOS": platformSmbiosDict]) }
        
        // set all button values
        if updateDatahub.state == .on {
            platformInfoDict.addEntries(from: ["UpdateDataHub": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateDataHub": false])
        }
        if updateNvram.state == .on {
            platformInfoDict.addEntries(from: ["UpdateNVRAM": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateNVRAM": false])
        }
        if updateSmbios.state == .on {
            platformInfoDict.addEntries(from: ["UpdateSMBIOS": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateSMBIOS": false])
        }
        platformInfoDict.addEntries(from: ["UpdateSMBIOSMode": (smbioUpdateModePopup.selectedItem?.title)!])
        
        uefiDict.removeAllObjects()
        if uefiConnectDrivers.state == .on {
            uefiDict.addEntries(from: ["ConnectDrivers": true])
        } else {
            uefiDict.addEntries(from: ["ConnectDrivers": false])
        }
        uefiDict.addEntries(from: ["Drivers": uefiDriverArray])
        uefiDict.addEntries(from: ["Quirks": uefiQuirksDict])
        uefiDict.addEntries(from: ["Protocols": uefiProtocolsDict])
        
        nvramDict.removeAllObjects()
        nvramDict.addEntries(from: ["Add": nvramAddDict])
        nvramDict.addEntries(from: ["Block": nvramBlockDict])
        
        saveMisc()
        
        let plistDict = NSMutableDictionary()
        plistDict.addEntries(from: ["ACPI": acpiDict])
        plistDict.addEntries(from: ["Kernel": kernelDict])
        plistDict.addEntries(from: ["DeviceProperties": deviceDict])
        plistDict.addEntries(from: ["PlatformInfo": platformInfoDict])
        plistDict.addEntries(from: ["UEFI": uefiDict])
        plistDict.addEntries(from: ["NVRAM": nvramDict])
        plistDict.addEntries(from: ["Misc": miscDict])
        plistDict.write(toFile: path, atomically: true)
        
            // open the file as a string to strip newlines from <data></data> entries.
            // Idea from CorpNewt's ProperTree commit in which he fixed the same issue
        
        let plistString = shell(launchPath: "/bin/cat", arguments: [path]) ?? ""    // load plist as a string
        let plistArray = plistString.components(separatedBy: "\n")                  // split it into an array by newlines
        var entriesContainingData: [Int] = [Int]()
        var newPlistString = ""
        
        for x in 0...(plistArray.count - 1) {
            if plistArray[x].trimmingCharacters(in: .whitespacesAndNewlines) == "<data>" {      // fill array with item numbers that contain contain "<data>"
                entriesContainingData.append(x)
            }
        }
        
        for x in 0...(plistArray.count - 3) {
            if plistArray[x + 1].trimmingCharacters(in: .whitespacesAndNewlines) == "</data>" {     // some data fields are empty. In that case we only need to trim
                if entriesContainingData.contains(x) {                                              // newlines for the next line, not the next two
                    newPlistString += plistArray[x] + plistArray[x + 1].trimmingCharacters(in: .whitespacesAndNewlines) + "\n" + plistArray[x + 2] + "\n"
                    
                }
            } else {
                if entriesContainingData.contains(x) {              // here we're dealing with data fields that actually hold data, so we need to trim newlines from the next *two* lines
                    newPlistString += plistArray[x] + plistArray[x + 1].trimmingCharacters(in: .whitespacesAndNewlines) + plistArray[x + 2].trimmingCharacters(in: .whitespacesAndNewlines) + "\n"

                }
                else if !entriesContainingData.contains(x - 1), !entriesContainingData.contains(x - 2) {     // for all other lines, we just want to append them to the string
                    newPlistString += plistArray[x] + "\n"
                }
            }
        }
        
        newPlistString += plistArray[plistArray.count - 2]      // since we're only iterating over 0...(plistArray.count - 3) because we don't want a newline at EOF,
                                                                // we need to manually append it here
        newPlistString = newPlistString.replacingOccurrences(of: "\"", with: "\\\"")    // escape quotes so bash doesn't strip them (for readability: replacing " with \")
        
        let _ = shell(launchPath: "/bin/bash", arguments: ["-c", "printf \"\(newPlistString)\" > \(path)"])   // write the new plist back to path. Using printf instead of echo because echo appends a final newline
        
        self.view.window?.isDocumentEdited = false
        editedState = false
    }
    
    func isNotEmpty(_ dict: NSMutableDictionary) -> Bool {
        var isNotEmpty = false
        for entry in Array(dict.allValues) {
            let entryString = entry as? String ?? ""
            if entryString != "" {
                isNotEmpty = true
            }
        }
        return isNotEmpty
    }
    
    func saveMisc() {
        miscBootDict.removeAllObjects()
        miscBootDict.addEntries(from: ["ConsoleMode": consoleMode.stringValue])
        if OsBehavior.selectedItem?.title == "Don't change" {
            miscBootDict.addEntries(from: ["ConsoleBehaviourOs": ""])
        } else {
            miscBootDict.addEntries(from: ["ConsoleBehaviourOs": (OsBehavior.selectedItem?.title)!])
        }
        if UiBehavior.selectedItem?.title == "Don't change" {
            miscBootDict.addEntries(from: ["ConsoleBehaviourUi": ""])
        } else {
            miscBootDict.addEntries(from: ["ConsoleBehaviourUi": (UiBehavior.selectedItem?.title)!])
        }
        miscBootDict.addEntries(from: ["HideSelf": checkboxState(button: hideSelf)])
        miscBootDict.addEntries(from: ["Resolution": resolution.stringValue])
        miscBootDict.addEntries(from: ["ShowPicker": checkboxState(button: showPicker)])
        miscBootDict.addEntries(from: ["Timeout": Int(timeoutTextfield.stringValue)!])
        
        miscDebugDict.removeAllObjects()
        miscDebugDict.addEntries(from: ["DisableWatchDog": checkboxState(button: disableWatchdog)])
        miscDebugDict.addEntries(from: ["DisplayDelay": Int(miscDelayText.stringValue) ?? 0])
        miscDebugDict.addEntries(from: ["DisplayLevel": Int(miscDisplayLevelText.stringValue) ?? 0])
        miscDebugDict.addEntries(from: ["Target": Int(miscTargetText.stringValue) ?? 0])
        
        miscSecurityDict.removeAllObjects()
        miscSecurityDict.addEntries(from: ["ExposeSensitiveData": Int(miscExposeSensitiveData.stringValue) ?? 0])
        miscSecurityDict.addEntries(from: ["HaltLevel": Int(miscHaltlevel.stringValue) ?? 0])
        miscSecurityDict.addEntries(from: ["RequireSignature": checkboxState(button: miscRequireSignature)])
        miscSecurityDict.addEntries(from: ["RequireVault": checkboxState(button: miscRequireVault)])
        
        miscDict.removeAllObjects()
        miscDict.addEntries(from: ["Boot": miscBootDict])
        miscDict.addEntries(from: ["Debug": miscDebugDict])
        miscDict.addEntries(from: ["Security": miscSecurityDict])
    }
    
    func checkboxState(button: NSButton) -> Bool {
        if button.state == .on {
            return true
        } else {
            return false
        }
    }
    
    @objc private func onItemClicked() {
        switch sectionsTable.clickedRow {
        case 0:
            hideAllExcept(exc: acpiTab)
        case 1:
            hideAllExcept(exc: deviceTab)
        case 2:
            hideAllExcept(exc: kernelTab)
        case 3:
            hideAllExcept(exc: miscTab)
        case 4:
            hideAllExcept(exc: nvramTab)
        case 5:
            hideAllExcept(exc: platformTab)
        case 6:
            hideAllExcept(exc: uefiTab)
        default:
            break
        }
    }
    
    func hideAllExcept(exc: NSTabView) {
        acpiTab.isHidden = true
        deviceTab.isHidden = true
        kernelTab.isHidden = true
        miscTab.isHidden = true
        nvramTab.isHidden = true
        platformTab.isHidden = true
        uefiTab.isHidden = true
        
        exc.isHidden = false
    }
    
    func removeEntryFromTable(table: inout NSTableView) {       // for some reason this spawns simultaneous read and write access to the table view delegate. TODO: figure this out so we can re-enable exclusive memory access enforcement
        let SR = table.selectedRow
        if SR != -1 {
            table.removeRows(at: IndexSet(integer: SR), withAnimation: .effectGap)
            tableLookup[table]!.remove(at: SR)
            table.reloadData()
            if table.accessibilityRowCount() < SR {
                table.selectRowIndexes(IndexSet(integer: SR - 1), byExtendingSelection: false)
            }
            else {
                table.selectRowIndexes(IndexSet(integer: SR), byExtendingSelection: false)
            }
            
        }
    }
    
    func addEntryToTable(table: inout NSTableView, appendix: [String:String]) {
        tableLookup[table]!.append(appendix)
        table.beginUpdates()
        table.insertRows(at: IndexSet(integer: tableLookup[table]!.count - 1), withAnimation: .effectGap)
        table.endUpdates()
    }
    
    @IBAction func timeoutStepperAction(_ sender: NSStepper) {
        timeoutTextfield.stringValue = sender.stringValue
    }
    
    @IBAction func timeoutTextfieldAction(_ sender: NSTextField) {
        timeoutStepper.stringValue = sender.stringValue
    }
    
    @IBAction func addAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiAddTable, appendix: ["Path": "", "Comment": "", "Enabled": ""])
    }
    @IBAction func remAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiAddTable)
    }
    @IBAction func blockAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiBlockTable, appendix: ["Comment": "", "OemTableId": "", "TableLength": "", "TableSignature": "DSDT","Enabled": "", "All": ""])
    }
    @IBAction func remBlockAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiBlockTable)
    }
    @IBAction func addPatchAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "TableSignature": "DSDT", "Enabled": "", "advanced": "", "Limit": "", "Mask": "", "OemTableId": "", "ReplaceMask": "", "Skip": "", "TableLength": "", "Count": ""])
    }
    @IBAction func remPatchAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiPatchTable)
    }
    @IBAction func addDeviceAddBtn(_ sender: Any) {
        addEntryToTable(table: &deviceAddTable, appendix: ["device": "", "property": "", "value": "", "edit": ""])
    }
    @IBAction func remDeviceAddBtn(_ sender: Any) {
        removeEntryFromTable(table: &deviceAddTable)
    }
    @IBAction func addDeviceBlockBtn(_ sender: Any) {
        addEntryToTable(table: &deviceBlockTable, appendix: ["device": "", "property": ""])
    }
    @IBAction func remDeviceBlockBtn(_ sender: Any) {
        removeEntryFromTable(table: &deviceBlockTable)
    }
    @IBAction func addKernelAddBtn(_ sender: Any) {
        addEntryToTable(table: &kernelAddTable, appendix: ["BundlePath": "", "Comment": "", "ExecutablePath": "", "PlistPath": "","MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelAddBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelAddTable)
    }
    @IBAction func addKernelBlockBtn(_ sender: Any) {
        addEntryToTable(table: &kernelBlockTable, appendix: ["Identifier": "", "Comment": "", "MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelBlockBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelBlockTable)
    }
    @IBAction func addKernelPatchBtn(_ sender: Any) {
        addEntryToTable(table: &kernelPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "MatchKernel": "", "Enabled": "", "kernelAdvanced": "", "Base": "", "Count": "", "Identifier": "", "Limit": "", "Mask": "", "ReplaceMask": "", "Skip": ""])
    }
    @IBAction func remKernelPatchBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelPatchTable)
    }
    @IBAction func addNvramBootBtn(_ sender: Any) {
        addEntryToTable(table: &nvramBootTable, appendix: ["property": "", "value": ""])
    }
    @IBAction func remNvramBootBtn(_ sender: Any) {
        removeEntryFromTable(table: &nvramBootTable)
    }
    @IBAction func addNvramVendorBtn(_ sender: Any) {
        addEntryToTable(table: &nvramVendorTable, appendix: ["property": "", "value": ""])
    }
    @IBAction func remNvramVendorBtn(_ sender: Any) {
        removeEntryFromTable(table: &nvramVendorTable)
    }
    @IBAction func addNvramCustomBtn(_ sender: Any) {
        addEntryToTable(table: &nvramCustomTable, appendix: ["guid": "", "property": "", "value": ""])
    }
    @IBAction func remNvramCustomBtn(_ sender: Any) {
        removeEntryFromTable(table: &nvramCustomTable)
    }
    @IBAction func addNvramBlockBtn(_ sender: Any) {
        addEntryToTable(table: &nvramBlockTable, appendix: ["guid": "", "property": ""])
    }
    @IBAction func remNvramBlockBtn(_ sender: Any) {
        removeEntryFromTable(table: &nvramBlockTable)
    }
    @IBAction func addUefiDriverBtn(_ sender: Any) {
        addEntryToTable(table: &uefiDriverTable, appendix: ["driver": ""])
    }
    @IBAction func remUefiDriverBtn(_ sender: Any) {
        removeEntryFromTable(table: &uefiDriverTable)
    }
    
    func messageBox(message: String, info: String? = nil) {
        let alert = NSAlert()
        alert.messageText = message
        
        if info != nil {
            alert.informativeText = info!
        }
        
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
    
    func calcAcpiChecksum(table: URL) -> UInt8? {
        do {
            let tableData = try Data(contentsOf: table)
            
            let length: [UInt8] = Array([UInt8](tableData)[4...7])
            let u32length = UnsafePointer(length).withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
            
            if u32length != tableData.count {
                return nil
            }
            
            try tableData.forEach(addBytes)
        } catch {
            print(error)
        }
        let localChecksum = checksum
        checksum = 0
        return localChecksum
    }
    
    var checksum: UInt8 = 0
    
    func addBytes(current: UInt8) throws {
        checksum &+= current
    }
    
    @IBAction func autoAddAcpi(_ sender: Any) {
        if mountedESP != "" {
            let fileManager = FileManager.default
            let acpiUrl = URL(fileURLWithPath: "\(mountedESP)/EFI/OC/ACPI/Custom")
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: acpiUrl, includingPropertiesForKeys: nil)
                var filenames: [String] = [String]()
                for i in fileURLs {
                    if !i.lastPathComponent.hasSuffix(".aml") {
                        messageBox(message: "\(i.lastPathComponent) does not have the .aml extension.")
                        continue
                    }
                    
                    let checksum = calcAcpiChecksum(table: i)
                    if checksum != 0 {
                        if checksum != nil {
                            messageBox(message: "Invalid Checksum", info: "The checksum for \(i.lastPathComponent) is invalid.")
                        } else {
                            messageBox(message: "The length of \(i.lastPathComponent) could not be verified.")
                        }
                        continue
                    }
                    filenames.append(i.lastPathComponent)
                }
                
                for file in filenames {
                    tableLookup[acpiAddTable]!.append(["Comment": "", "Path": file, "Enabled": "1"])
                }
                acpiAddTable.reloadData()
            } catch {
                print("Error while enumerating files \(acpiUrl.path): \(error.localizedDescription)")
            }
        } else {
            espWarning()
        }
    }
    
    @IBAction func autoAddKernel(_ sender: Any) {
        if mountedESP != "" {
            let execLookup = recursiveKexts(path: "\(mountedESP)/EFI/OC/Kexts")
            for kext in Array(execLookup!.keys) {
                tableLookup[kernelAddTable]!.append(["Comment": "", "BundlePath": kext, "Enabled": "1", "ExecutablePath": "\(execLookup![kext]!)", "MatchKernel": "", "PlistPath": "Contents/Info.plist"])
            }
            tableLookup[kernelAddTable]! = tableLookup[kernelAddTable]!.sorted { $0.values[$0.keys.firstIndex(of: "BundlePath")!] < $1.values[$1.keys.firstIndex(of: "BundlePath")!] }
            kernelAddTable.reloadData()
        } else {
            espWarning()
        }
    }
    
    @IBAction func autoAddUefi(_ sender: Any) {
        if mountedESP != "" {
            let fileManager = FileManager.default
            let acpiUrl = URL(fileURLWithPath: "\(mountedESP)/EFI/OC/Drivers")
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: acpiUrl, includingPropertiesForKeys: nil)
                var filenames: [String] = [String]()
                for i in fileURLs {
                    filenames.append(i.lastPathComponent)
                }
                
                for file in filenames {
                    tableLookup[uefiDriverTable]!.append(["driver": file])
                }
                uefiDriverTable.reloadData()
            } catch {
                print("Error while enumerating files \(acpiUrl.path): \(error.localizedDescription)")
            }
        } else {
            espWarning()
        }
    }
    @IBAction func platformAutomaticAction(_ sender: NSButton) {
        togglePlatformAutomatic()
    }
    
    func togglePlatformAutomatic() {
        if smbiosAutomatic.state == .on {
            platformDatahubTable.isEnabled = false
            platformNvramTable.isEnabled = false
            platformSmbiosTable.isEnabled = false
            platformGenericTable.isEnabled = true
            spoofVendor.isEnabled = true
        } else {
            platformDatahubTable.isEnabled = true
            platformNvramTable.isEnabled = true
            platformSmbiosTable.isEnabled = true
            platformGenericTable.isEnabled = false
            spoofVendor.isEnabled = false
        }
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/Configuration.pdf")!)
    }
    
    func espWarning() {
        let alert = NSAlert()
        alert.messageText = "No EFI partition selected!"
        alert.informativeText = "Please select an EFI partition from the drop down."
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    @objc func onSmbiosSelect(_ sender: NSMenuItem) {
        tableLookup[platformGenericTable] = [["property": "SystemUUID", "value": ""],
                                              ["property": "MLB", "value": ""],
                                              ["property": "ROM", "value": ""],
                                              ["property": "SystemProductName", "value": ""],
                                              ["property": "SystemSerialNumber", "value": ""]]
        
        let mac = String((shell(launchPath: "/bin/bash", arguments: ["-c", "ifconfig en0 | grep ether"])?.dropFirst(6))!).replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").uppercased()
        
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemSerialNumber", "value": ""])!] = ["property": "SystemSerialNumber", "value": serialDict[sender.title]![0]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemProductName", "value": ""])!] = ["property": "SystemProductName", "value": sender.title]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "MLB", "value": ""])!] = ["property": "MLB", "value": serialDict[sender.title]![1]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemUUID", "value": ""])!] = ["property": "SystemUUID", "value": UUID().uuidString]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "ROM", "value": ""])!] = ["property": "ROM", "value": mac]
        platformGenericTable.reloadData()
    }
    
    @IBAction func genSmbios(_ sender: NSButton) {
        let macSerial = Bundle.main.path(forAuxiliaryExecutable: "macserial" )!
        let serialMess = shell(launchPath: macSerial, arguments: ["-a"])?.components(separatedBy: "\n")
        
        for entry in serialMess! {
            let modelArray = entry.replacingOccurrences(of: " ", with: "").components(separatedBy: "|")
            if modelArray.count == 3 {
                serialDict[modelArray[0]] = [modelArray[1], modelArray[2]]
            }
        }
        
        let menu = NSMenu()
        for model in Array(serialDict.keys).sorted(by:{$0.localizedStandardCompare($1) == .orderedAscending} ) {
            menu.addItem(withTitle: model, action: #selector(onSmbiosSelect), keyEquivalent: "")
        }
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y + 48)
        menu.popUp(positioning: menu.items.last, at: p, in: sender.superview)
    }
    
    var wasMounted = false
    
    @IBAction func mountEsp(_ sender: NSPopUpButton) {
        if sender.selectedItem!.title != "Select an EFI partition…" {
            let driveToMount = drivesDict[sender.selectedItem!.title]
            let driveIsMounted = shell(launchPath: "/bin/bash", arguments: ["-c", "diskutil info \(driveToMount!) | grep \"Mounted\" | awk '{ print $2 }'"])

            if !self.wasMounted {
                if mountedESP != "" {
                    DispatchQueue.global(qos: .background).async {
                        if mountedESPID != "" {
                            let _ = (self.shell(launchPath: "/bin/bash", arguments: ["-c", "diskutil unmount \(mountedESPID)"]))!
                        }
                    }
                }
            }
            
            if driveIsMounted == "No\n" {
                NSAppleScript(source: "do shell script \"diskutil mount /dev/\(driveToMount!)\" with administrator privileges")!.executeAndReturnError(nil)
                wasMounted = false
            } else {
                wasMounted = true
            }
            
            mountedESPID = driveToMount!
            mountedESP = (shell(launchPath: "/bin/bash", arguments: ["-c", "diskutil info \(driveToMount!) | grep \"Mount Point\" | awk '{ print $3 }'"])?.replacingOccurrences(of: "\n", with: ""))!
        } else {
            mountedESP = ""
            if !wasMounted {
                DispatchQueue.global(qos: .background).async {
                    let _ = (self.shell(launchPath: "/bin/bash", arguments: ["-c", "diskutil unmount \(mountedESPID)"]))!
                    mountedESPID = ""
                }
            }
        }
    }

    @IBAction func reloadEfiPartitions(_ sender: Any) {
        do {
            try reloadEsps()
        } catch let error {
            NSApplication.shared.presentError(error)
        }
    }
    
    func shell(launchPath: String, arguments: [String]) -> String?
    {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    }
    
    func recursiveKexts(path: String) -> [String: String]? {
        let fileManager = FileManager.default
        let kextsUrl = URL(fileURLWithPath: path)
        do {
            let fileURLs = try? fileManager.contentsOfDirectory(at: kextsUrl, includingPropertiesForKeys: nil)
            var execLookup: [String: String] =  [String: String]()
            if fileURLs != nil {
                for i in fileURLs! {
                    var kextIsDirObjcBool: ObjCBool = ObjCBool(true)
                    let _: Bool = fileManager.fileExists(atPath: "\(i.path)", isDirectory: &kextIsDirObjcBool)  // ensure the kext is a directory
                    if i.lastPathComponent.hasSuffix(".kext"), kextIsDirObjcBool.boolValue {                    // ensure it has the ".kext" suffix
                        var contentsExistObjcBool: ObjCBool = ObjCBool(true)
                        let contentsExists: Bool = fileManager.fileExists(atPath: "\(i.path)/Contents", isDirectory: &contentsExistObjcBool)    // ensure it has a "Contents" directory
                        if contentsExists, contentsExistObjcBool.boolValue{
                            if fileManager.fileExists(atPath: "\(i.path)/Contents/Info.plist") {                    // ensure it has an Info.plist
                                let execUrl = URL(fileURLWithPath: "Contents/MacOS", relativeTo: i)
                                do {
                                    let executable = try fileManager.contentsOfDirectory(at: execUrl, includingPropertiesForKeys: nil)
                                    if executable.count <= 1 {
                                        let fileType = shell(launchPath: "/usr/bin/file", arguments: ["\(i.path)/Contents/MacOS/\((executable.first?.lastPathComponent)!)"])
                                        if !fileType!.contains("Mach-O 64-bit kext bundle x86_64") {
                                            messageBox(message: "\(i.lastPathComponent)'s executable is not a kext bundle",
                                                        info: "You should either re-download the kext, contact the developer or remove it.")
                                            continue
                                        }
                                        execLookup[i.lastPathComponent] = "Contents/MacOS/\((executable.first?.lastPathComponent)!)"    // add the executable to the dict. Making sure it only contains one executable
                                    } else {
                                        messageBox(message: "\"\(i.lastPathComponent)\" contains more than one executable.",
                                                    info: "Either get a version of this kext that only has one executable or add it manually at your own risk.")
                                        continue
                                    }
                                } catch {
                                    execLookup[i.lastPathComponent] = ""
                                }
                                let recursiveLookup = recursiveKexts(path: "\(i.path)/Contents/PlugIns")
                                if recursiveLookup != nil {
                                    for recursiveKext in Array(recursiveLookup!.keys) {
                                        execLookup["\(i.lastPathComponent)/Contents/PlugIns/\(recursiveKext)"] = recursiveLookup![recursiveKext]!
                                    }
                                }
                            } else {
                                messageBox(message: "\"\(i.lastPathComponent)\" does not have an Info.plist",
                                            info: "You should either re-download the kext or contact the developer about this issue.")
                            }
                        } else {
                            messageBox(message: "\"\(i.lastPathComponent)\" is a malformed kext",
                                        info: "It does not contain a \"Contents\" directory.")
                        }
                    } else {
                        messageBox(message: "\"\(i.lastPathComponent)\" is not a kext.")
                    }
                }
                return execLookup
            }
        }
        return nil
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {     // convert data to hexadecimal string
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    init?(hexString: String) {                          // convert hexadecimal string to data
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    func replaceSubranges(of: String, with: String, skip: Int, count: Int, limit: Int) -> Data {
        var dataRangesMatching: [Range<Data.Index>?] = [Range<Data.Index>?]()
        dataRangesMatching.append(self.range(of: Data(hexString: of)!))        // add first range to array before looping over it
        
        if dataRangesMatching != [nil] {
            while true {    // find all ranges matching "of" and add them to the array
                let currentRange = self.range(of: Data(hexString: of)!, in: ((dataRangesMatching.last?!.upperBound)!..<self.count) as Range<Data.Index>)
                
                if currentRange != nil {
                    dataRangesMatching.append(currentRange)
                }
                
                else {
                    break
                }
            }
            
            var newData = self
            var skip = skip
            var count = count
            
            for range in dataRangesMatching {
                if skip > 0 {
                    skip -= 1
                    continue
                }
                
                if limit > 0 {
                    if (range?.distance(from: Data().startIndex, to: range!.upperBound))! < limit {
                        newData.replaceSubrange(range!, with: Data(hexString: with)!)
                    }
                        
                    else {
                        break
                    }
                }
                    
                else {
                    newData.replaceSubrange(range!, with: Data(hexString: with)!)
                }
                
                if count > 0 {
                    count -= 1
                    if count == 0 {
                        break
                    }
                }
            }
            return newData
        }
        return self
    }
}
