//
//  MasterDetailsViewController.swift
//  test
//
//  Created by Henry Brock on 6/5/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

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

class MasterDetailsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var sectionsTable:NSTableView!
    @IBOutlet weak var espPopup: NSPopUpButton!
    @IBOutlet var masterDetailView: NSView!
    @IBOutlet var tableView: NSTableView!
    
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
    var platformInfoGeneralVC: PlatformInfoGeneralViewController?
    var platformInfoGenericVC: PlatformInfoGenericViewController?
    var platformInfoDataHubVC: PlatformInfoDataHubViewController?
    var platformInfoNvramVC: PlatformInfoNvramViewController?
    var platformInfoSmbiosVC: PlatformInfoSmbiosViewController?
    var uefiTabVC: UEFITabViewController?
    var uefiDriversVC: UEFIDriversViewController?
    var uefiQuirksVC: UEFIQuirksViewController?
    var detailsVC: DetailViewController?
    var itemsList = ["ACPI", "Device Properties", "Kernel", "Misc", "NVRAM", "Platform Info", "UEFI"]
    var wasMounted = false
    
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
        
//        resetTables()   // initialize table datasources
        
        for table in Array(tableLookup.keys) {              // setup table delegate and datasource
            table.delegate = self as NSTableViewDelegate
            table.dataSource = self
        }
        
//        sectionsTable.action = #selector(onItemClicked)     // on section selection
        
        /*deviceQuirks = [
         "ReinstallProtocol": self.ReinstallProtocol
         ]*/
        
//        kernelQuirks = [
//            "AppleCpuPmCfgLock": self.kernelQuirksVC!.AppleCpuPmCfgLock,
//            "AppleXcpmCfgLock": self.kernelQuirksVC!.AppleXcpmCfgLock,
//            "ExternalDiskIcons": self.kernelQuirksVC!.ExternalDiskIcons,
//            "ThirdPartyTrim": self.kernelQuirksVC!.ThirdPartyTrim,
//            "XhciPortLimit": self.kernelQuirksVC!.XhciPortLimit
//        ]
//
//        uefiQuirks = [
//            "IgnoreTextInGraphics": self.uefiQuirksVC!.IgnoreTextInGraphics,
//            "IgnoreInvalidFlexRatio": self.uefiQuirksVC!.IgnoreInvalidFlexRatio,
//            "ProvideConsoleGop": self.uefiQuirksVC!.ProvideConsoleGop,
//            "ReleaseUsbOwnership": self.uefiQuirksVC!.ReleaseUsbOwnership,
//            "RequestBootVarRouting": self.uefiQuirksVC!.RequestBootVarRouting,
//            "SanitiseClearScreen": self.uefiQuirksVC!.SanitiseClearScreen
//        ]
//
//        uefiProtocols = [
//            "AppleBootPolicy": self.uefiQuirksVC!.AppleBootPolicy,
//            "ConsoleControl": self.uefiQuirksVC!.ConsoleControl,
//            "DataHub": self.uefiQuirksVC!.DataHub,
//            "DeviceProperties": self.uefiQuirksVC!.DeviceProperties
//        ]
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
            if sectionsTable.selectedRow == 0, (viewLookup[sectionsTable.selectedRow]!.selectedTabViewItem?.view?.subviews[0].subviews[1].subviews[0] as? NSTableView ?? NSTableView()) == acpiPatchVC!.acpiPatchTable {
                if acpiPatchVC!.acpiPatchTable.selectedRow != -1 {
                    let iaslPath = Bundle.main.path(forAuxiliaryExecutable: "iasl62")!
                    let currentRow = tableLookup[acpiPatchVC!.acpiPatchTable]![acpiPatchVC!.acpiPatchTable.selectedRow]
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
//                        let acpiDifferVc = acpiDifferController.loadFromNib()
//                        acpiDifferVc.showPopover(bounds: view.bounds, window: view)
//                        acpiDifferVc.populatePopover(before: beforeString, after: afterString)
                    }
                }
            }
        }
    }
    
    var vaultWindow: NSWindow? = nil
    
    @objc func openVaultManager(_ notification: Notification) {
        if mountedESP != "" {
            let vault = openCoreVault()
            vaultWindow = vault.showVaultManager(vaultEnabled: miscSecurityVC!.miscRequireVault.state.rawValue)
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
        for entry in tableLookup[acpiPatchVC!.acpiPatchTable]! {
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
        
//        // Populate the drives dictionary
//        drivesDict = Dictionary(uniqueKeysWithValues: espsForPartitions + espsForVolumes)
//        
//        // Reset the ESP pop-up menu
//        espPopup.removeAllItems()
//        espPopup.addItem(withTitle: "Select an EFI partition…")
//        espPopup.menu?.addItem(NSMenuItem.separator())
//        
//        // Populate the pop-up menu
//        drivesDict.keys.forEach(espPopup.addItem(withTitle:))
    }
    
//    func resetTables() {
//        tableLookup = [             // lookup table holding the datasources to the tableviews
////            sectionsTable: [["section": "ACPI"],["section": "Device Properties"],["section": "Kernel"],["section": "Misc"],["section": "NVRAM"],["section": "Platform Info"],["section": "UEFI"]],
//            acpiAddVC!.acpiAddTable: [[String: String]](),
//            acpiBlockVC!.acpiBlockTable: [[String: String]](),
//            acpiPatchVC!.acpiPatchTable: [[String: String]](),
//            devicePropertiesAddVC!.deviceAddTable: [[String: String]](),
//            devicePropertiesBlockVC!.deviceBlockTable: [[String: String]](),
//            kernelAddVC!.kernelAddTable: [[String: String]](),
//            kernelBlockVC!.kernelBlockTable: [[String: String]](),
//            kernelPatchVC!.kernelPatchTable: [[String: String]](),
//            nvramAddVC!.nvramBootTable: [[String: String]](),
//            nvramAddVC!.nvramVendorTable: [[String: String]](),
//            nvramAddVC!.nvramCustomTable: [[String: String]](),
//            nvramBlockVC!.nvramBlockTable: [[String: String]](),
//            uefiDriversVC!.uefiDriverTable: [[String: String]](),
//            platformInfoSmbiosVC!.platformSmbiosTable: [["property": "BIOSVendor", "value": ""],
//                                  ["property": "BIOSVersion", "value": ""],
//                                  ["property": "BIOSReleaseDate", "value": ""],
//                                  ["property": "SystemManufacturer", "value": ""],
//                                  ["property": "SystemProductName", "value": ""],
//                                  ["property": "SystemVersion", "value": ""],
//                                  ["property": "SystemSerialNumber", "value": ""],
//                                  ["property": "SystemUUID", "value": ""],
//                                  ["property": "SystemSKUNumber", "value": ""],
//                                  ["property": "SystemFamily", "value": ""],
//                                  ["property": "BoardManufacturer", "value": ""],
//                                  ["property": "BoardProduct", "value": ""],
//                                  ["property": "BoardVersion", "value": ""],
//                                  ["property": "BoardSerialNumber", "value": ""],
//                                  ["property": "BoardAssetTag", "value": ""],
//                                  ["property": "BoardType", "value": ""],
//                                  ["property": "BoardLocationInChassis", "value": ""],
//                                  ["property": "ChassisManufacturer", "value": ""],
//                                  ["property": "ChassisType", "value": ""],
//                                  ["property": "ChassisVersion", "value": ""],
//                                  ["property": "ChassisSerialNumber", "value": ""],
//                                  ["property": "ChassisAssetTag", "value": ""],
//                                  ["property": "PlatformFeature", "value": ""],
//                                  ["property": "FirmwareFeatures", "value": ""],
//                                  ["property": "FirmwareFeaturesMask", "value": ""],
//                                  ["property": "ProcessorType", "value": ""],
//                                  ["property": "MemoryFormFactor", "value": ""]],
//
//            platformInfoDataHubVC!.platformDatahubTable: [["property": "ARTFrequency", "value": ""],
//                                   ["property": "BoardProduct", "value": ""],
//                                   ["property": "BoardRevision", "value": ""],
//                                   ["property": "DevicePathsSupported", "value": ""],
//                                   ["property": "FSBFrequency", "value": ""],
//                                   ["property": "InitialTSC", "value": ""],
//                                   ["property": "PlatformName", "value": ""],
//                                   ["property": "SmcBranch", "value": ""],
//                                   ["property": "SmcPlatform", "value": ""],
//                                   ["property": "SmcRevision", "value": ""],
//                                   ["property": "StartupPowerEvents", "value": ""],
//                                   ["property": "SystemProductName", "value": ""],
//                                   ["property": "SystemSerialNumber", "value": ""],
//                                   ["property": "SystemUUID", "value": ""]],
//
//            platformInfoGenericVC!.platformGenericTable: [["property": "SystemUUID", "value": ""],
//                                   ["property": "MLB", "value": ""],
//                                   ["property": "ROM", "value": ""],
//                                   ["property": "SystemProductName", "value": ""],
//                                   ["property": "SystemSerialNumber", "value": ""]],
//
//            platformInfoNvramVC!.platformNvramTable: [["property": "BID", "value": ""],
//                                 ["property": "MLB", "value": ""],
//                                 ["property": "ROM", "value": ""],
//                                 ["property": "FirmwareFeatures", "value": ""],
//                                 ["property": "FirmwareFeaturesMask", "value": ""]]
//        ]
//    }
    
    @objc func acpiAdvanced(_ sender: NSButton) {
//        let acpiVc = AcpiPopoverController.loadFromNib()        // load popover viewcontroller set up in AcpiPopoverController.swift
        
        acpiPatchVC!.acpiPatchTable.selectRowIndexes(IndexSet(integer: Int(sender.identifier!.rawValue)!), byExtendingSelection: false)      // select row the button belongs to for the code below to work
        // TODO: rely only on button identifier, not selected row, so we can allow an empty selection like in all other tables
        
        acpiLimitString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"] ?? ""        // fill variables with contents of plist file
        acpiMaskString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"] ?? ""
        acpiOemTableIdString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["OemTableId"] ?? ""
        acpiReplaceMaskString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"] ?? ""
        acpiSkipString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"] ?? ""
        acpiTableLengthString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["TableLength"] ?? ""
        acpiCountString = tableLookup[acpiPatchVC!.acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Count"] ?? ""
        
//        acpiVc.showPopover(button: sender)
    }
    
    @objc func kernelAdvanced(_ sender: NSButton) {
//        let kernelVc = KernelPopoverController.loadFromNib()
        
        kernelPatchVC!.kernelPatchTable.selectRowIndexes(IndexSet(integer: Int(sender.identifier!.rawValue)!), byExtendingSelection: false)
        
        kernelBaseString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Base"] ?? ""
        kernelCountString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Count"] ?? ""
        kernelIdentifierString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Identifier"] ?? ""
        kernelLimitString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"] ?? ""
        kernelMaskString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"] ?? ""
        kernelReplaceString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"] ?? ""
        kernelSkipString = tableLookup[kernelPatchVC!.kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"] ?? ""
        
//        kernelVc.showPopover(button: sender)
    }
    
    @objc func onAcpiSyncPopover(_ notification: Notification) {
        tableLookup[acpiPatchVC!.acpiPatchTable]![acpiPatchVC!.acpiPatchTable.selectedRow][(acpiCurrentTextField.identifier?.rawValue)!] = acpiCurrentTextField.stringValue
    }
    
    @objc func onKernelSyncPopover(_ notification: Notification) {
        tableLookup[kernelPatchVC!.kernelPatchTable]![kernelPatchVC!.kernelPatchTable.selectedRow][(kernelCurrentTextField.identifier?.rawValue)!] = kernelCurrentTextField.stringValue
    }
    
    @objc func onPasteVC(_ notification: Notification) {
        if sectionsTable.selectedRow == 0, (viewLookup[sectionsTable.selectedRow]!.selectedTabViewItem?.view?.subviews[0].subviews[1].subviews[0] as! NSTableView) == acpiPatchVC!.acpiPatchTable {
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
        
        txt.stringValue = String(decoding: Data(hexString: tableLookup[devicePropertiesAddVC!.deviceAddTable]![Int(sender.identifier!.rawValue)!]["value"]!)!, as: UTF8.self)
        
        customItem.accessoryView = txt
        let response: NSApplication.ModalResponse = customItem.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            tableLookup[devicePropertiesAddVC!.deviceAddTable]![Int(sender.identifier!.rawValue)!]["value"] = txt.stringValue.data(using: .ascii)?.hexEncodedString(options: .upperCase)
            devicePropertiesAddVC!.deviceAddTable.reloadData()
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
//        resetTables()       // clear tables before adding new data to them
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
            uefiDriversVC!.uefiConnectDrivers: uefiConnectDriversBool,
            platformInfoGeneralVC!.smbiosAutomatic: platformAutomaticBool,
            platformInfoGeneralVC!.updateDatahub: platformUpdateDatahubBool,
            platformInfoGeneralVC!.updateNvram: platformUpdateNvramBool,
            platformInfoGeneralVC!.updateSmbios: platformUpdateSmbiosBool
        ]
        for (key, value) in miscBootDict {      // we're not dealing with tables here so it's easier to just parse the data manually. This sucks but I don't have a better idea for this atm
            switch key as? String ?? "" {
            case "ShowPicker":
                if value as? Bool ?? false {
                    miscBootVC!.showPicker.state = .on
                }
                else {
                    miscBootVC!.showPicker.state = .off
                }
            case "Timeout":
                miscBootVC!.timeoutStepper.stringValue = String(value as? Int ?? Int())
                miscBootVC!.timeoutTextfield.stringValue = String(value as? Int ?? Int())
            case "ConsoleMode":
                miscBootVC!.consoleMode.stringValue = value as? String ?? ""
            case "ConsoleBehaviourOs":
                if value as? String ?? "" != "" {
                    if miscBootVC!.OsBehavior.itemTitles.contains(value as? String ?? "") {
                        miscBootVC!.OsBehavior.selectItem(withTitle: value as? String ?? "")
                    }
                } else {
                    miscBootVC!.OsBehavior.selectItem(withTitle: "Don't change")
                }
            case "ConsoleBehaviourUi":
                if value as? String ?? "" != "" {
                    if miscBootVC!.UiBehavior.itemTitles.contains(value as? String ?? "") {
                        miscBootVC!.UiBehavior.selectItem(withTitle: value as? String ?? "")
                    }
                } else {
                    miscBootVC!.UiBehavior.selectItem(withTitle: "Don't change")
                }
            case "HideSelf":
                if value as? Bool ?? false {
                    miscBootVC!.hideSelf.state = .on
                }
                else {
                    miscBootVC!.hideSelf.state = .off
                }
            case "Resolution":
                miscBootVC!.resolution.stringValue = value as? String ?? ""
            default:
                break
            }
        }
        for (key, value) in miscDebugDict {
            switch key as? String ?? "" {
            case "DisplayDelay":
                miscDebugVC!.miscDelayText.stringValue = String(value as? Int ?? Int())
            case "DisplayLevel":
                miscDebugVC!.miscDisplayLevelText.stringValue = String(value as? Int ?? Int())
            case "Target":
                miscDebugVC!.miscTargetText.stringValue = String(value as? Int ?? Int())
            case "DisableWatchDog":
                if value as? Bool ?? false {
                    miscDebugVC!.disableWatchdog.state = .on
                } else {
                    miscDebugVC!.disableWatchdog.state = .off
                }
            default:
                break
            }
        }
        for (key, value) in miscSecurityDict {
            switch key as? String ?? "" {
            case "HaltLevel":
                miscSecurityVC!.miscHaltlevel.stringValue = String(value as? Int ?? Int())
            case "RequireSignature":
                if value as? Bool ?? false {
                    miscSecurityVC!.miscRequireSignature.state = .on
                }
                else {
                    miscSecurityVC!.miscRequireSignature.state = .off
                }
            case "RequireVault":
                if value as? Bool ?? false {
                    miscSecurityVC!.miscRequireVault.state = .on
                }
                else {
                    miscSecurityVC!.miscRequireVault.state = .off
                }
            case "ExposeSensitiveData":
                miscSecurityVC!.miscExposeSensitiveData.stringValue = String(value as? Int ?? Int())
            default:
                break
            }
        }
        for (key, value) in nvramAddDict {
            switch key as? String ?? "" {
            case "7C436110-AB2A-4BBB-A880-FE41995C9F82":
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramAddVC!.nvramBootTable)
            case "4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14":
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramAddVC!.nvramVendorTable)
            default:
                OHF.createNvramData(value: value as? NSMutableDictionary ?? NSMutableDictionary(), table: &nvramAddVC!.nvramCustomTable, guidString: key as? String)
            }
        }
        for (key, value) in nvramBlockDict {
            OHF.createNvramData(value: value as? NSMutableArray ?? NSMutableArray(), table: &nvramBlockVC!.nvramBlockTable, guidString: key as? String)
        }
        OHF.createTopLevelBools(buttonDict: &topLevelBools)
        if platformInfoGeneralVC!.smbioUpdateModePopup.itemTitles.contains(platformUpdateSmbiosModeStr) {
            platformInfoGeneralVC!.smbioUpdateModePopup.selectItem(withTitle: platformUpdateSmbiosModeStr)
        } else {
            platformInfoGeneralVC!.smbioUpdateModePopup.selectItem(withTitle: "Create")
        }
        //OHF.createData(input: acpiAddArray, table: &acpiAddVC!.acpiAddTable, predefinedKey: "acpiAdd")
        tableLookup[acpiAddVC!.acpiAddTable] = acpiAddArray as? Array ?? Array()
        acpiAddVC!.acpiAddTable.reloadData()
        OHF.createData(input: acpiBlockArray, table: &acpiBlockVC!.acpiBlockTable)
        //OHF.createData(input: acpiPatchArray, table: &acpiPatchVC!.acpiPatchTable)
        tableLookup[acpiPatchVC!.acpiPatchTable] = acpiPatchArray as? Array ?? Array()
        acpiPatchVC!.acpiPatchTable.reloadData()
        OHF.createQuirksData(input: acpiQuirksDict, quirksDict: acpiQuirks)
        OHF.createData(input: deviceAddDict, table: &devicePropertiesAddVC!.deviceAddTable)
        OHF.createData(input: deviceBlockDict, table: &devicePropertiesBlockVC!.deviceBlockTable)
        // OHF.createQuirksData(input: deviceQuirksDict, quirksDict: deviceQuirks)          // device properties quirks don't exist anymore. leaving this here in case they come back
        //OHF.createData(input: kernelAddArray, table: &kernelAddTable)
        tableLookup[kernelAddVC!.kernelAddTable] = kernelAddArray as? Array ?? Array()
        kernelAddVC!.kernelAddTable.reloadData()
        OHF.createData(input: kernelBlockArray, table: &kernelBlockVC!.kernelBlockTable)
        //OHF.createData(input: kernelPatchArray, table: &kernelPatchTable)
        tableLookup[kernelPatchVC!.kernelPatchTable] = kernelPatchArray as? Array ?? Array()
        kernelPatchVC!.kernelPatchTable.reloadData()
        OHF.createQuirksData(input: kernelQuirksDict, quirksDict: kernelQuirks)
        OHF.createData(input: uefiDriverArray, table: &uefiDriversVC!.uefiDriverTable, predefinedKey: "driver")
        OHF.createQuirksData(input: uefiQuirksDict, quirksDict: uefiQuirks)
        OHF.createQuirksData(input: uefiProtocolsDict, quirksDict: uefiProtocols)
        uefiQuirksVC!.ExitBootServicesDelay.stringValue = String(uefiExitBootInt)
        OHF.createData(input: platformSmbiosDict, table: &platformInfoSmbiosVC!.platformSmbiosTable)
        OHF.createData(input: platformDatahubDict, table: &platformInfoDataHubVC!.platformDatahubTable)
        OHF.createData(input: platformGenericDict, table: &platformInfoGenericVC!.platformGenericTable)
        if platformGenericDict.value(forKey: "SpoofVendor") as? Bool ?? false {
            platformInfoGenericVC!.spoofVendor.state = .on
        } else {
            platformInfoGenericVC!.spoofVendor.state = .off
        }
        OHF.createData(input: platformNvramDict, table: &platformInfoNvramVC!.platformNvramTable)
        platformInfoGeneralVC!.togglePlatformAutomatic()
        self.view.window?.title = "\((path as NSString).lastPathComponent) - OpenCore Configurator"
        self.view.window?.representedURL = URL(fileURLWithPath: path)
    }
    
    @objc func onPlistSave(_ notification: Notification) {
        let SHF = saveHandlerFunctions()
        SHF.saveArrayOfDictData(table: acpiAddVC!.acpiAddTable, array: &acpiAddArray)
        SHF.saveArrayOfDictData(table: acpiBlockVC!.acpiBlockTable, array: &acpiBlockArray)
        //SHF.saveArrayOfDictData(table: acpiPatchVC!.acpiPatchTable, array: &acpiPatchArray)
        acpiPatchArray = (tableLookup[acpiPatchVC!.acpiPatchTable]! as NSArray).mutableCopy() as! NSMutableArray
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
        kernelAddArray = (tableLookup[kernelAddVC!.kernelAddTable]! as NSArray).mutableCopy() as! NSMutableArray
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
        SHF.saveArrayOfDictData(table: kernelBlockVC!.kernelBlockTable, array: &kernelBlockArray)
        //SHF.saveArrayOfDictData(table: kernelPatchTable, array: &kernelPatchArray)
        kernelPatchArray = (tableLookup[kernelPatchVC!.kernelPatchTable]! as NSArray).mutableCopy() as! NSMutableArray
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
        SHF.saveDeviceData(table: devicePropertiesAddVC!.deviceAddTable, dict: &deviceAddDict)
        SHF.saveDeviceData(table: devicePropertiesBlockVC!.deviceBlockTable, dict: &deviceBlockDict)
        SHF.saveQuirksData(dict: deviceQuirks, quirksDict: &deviceQuirksDict)
        // only process platform dicts if they're not empty. This is not necessary because we're checking this when appending to the platform dict too, but this is cleaner because we don't do unnecessary work
        if isNotEmpty(platformGenericDict) { SHF.saveDictOfDictData(table: platformInfoGenericVC!.platformGenericTable, dict: &platformGenericDict) }
        if isNotEmpty(platformNvramDict) { SHF.saveDictOfDictData(table: platformInfoNvramVC!.platformNvramTable, dict: &platformNvramDict) }
        if isNotEmpty(platformSmbiosDict) { SHF.saveDictOfDictData(table: platformInfoSmbiosVC!.platformSmbiosTable, dict: &platformSmbiosDict) }
        if isNotEmpty(platformDatahubDict) { SHF.saveDictOfDictData(table: platformInfoDataHubVC!.platformDatahubTable, dict: &platformDatahubDict) }
        SHF.saveStringData(table: uefiDriversVC!.uefiDriverTable, array: &uefiDriverArray)
        SHF.saveQuirksData(dict: uefiQuirks, quirksDict: &uefiQuirksDict)
        uefiQuirksDict.addEntries(from: ["ExitBootServicesDelay": Int(uefiQuirksVC!.ExitBootServicesDelay.stringValue) ?? 0])
        SHF.saveQuirksData(dict: uefiProtocols, quirksDict: &uefiProtocolsDict)
        SHF.saveNvramBootData(table: nvramAddVC!.nvramBootTable, dict: &nvramAddDict)       // TODO: create subdicts for GUID, handle custom table seperately
        SHF.saveNvramVendorData(table: nvramAddVC!.nvramVendorTable, dict: &nvramAddDict)
        SHF.saveNvramCustomData(table: nvramAddVC!.nvramCustomTable, dict: &nvramAddDict)
        clearDict = true                                                    // we split data from the same dict into 3 tables, so we don't want to clear it for each of them
        SHF.saveNvramBlockData(table: nvramBlockVC!.nvramBlockTable, dict: &nvramBlockDict)
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
        if platformInfoGeneralVC!.smbiosAutomatic.state == .on {
            platformInfoDict.addEntries(from: ["Automatic": true])
        } else {
            platformInfoDict.addEntries(from: ["Automatic": false])
        }                                                                // only add platform dicts if they're not empty
        if isNotEmpty(platformDatahubDict) { platformInfoDict.addEntries(from: ["DataHub": platformDatahubDict]) }
        if isNotEmpty(platformGenericDict) { platformInfoDict.addEntries(from: ["Generic": platformGenericDict]) }
        if platformInfoGenericVC!.spoofVendor.state == .on {
            platformGenericDict.addEntries(from: ["SpoofVendor": true])
        } else {
            platformGenericDict.addEntries(from: ["SpoofVendor": false])
        }
        if isNotEmpty(platformNvramDict) { platformInfoDict.addEntries(from: ["PlatformNVRAM": platformNvramDict]) }
        if isNotEmpty(platformSmbiosDict) { platformInfoDict.addEntries(from: ["SMBIOS": platformSmbiosDict]) }
        // set all button values
        if platformInfoGeneralVC!.updateDatahub.state == .on {
            platformInfoDict.addEntries(from: ["UpdateDataHub": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateDataHub": false])
        }
        if platformInfoGeneralVC!.updateNvram.state == .on {
            platformInfoDict.addEntries(from: ["UpdateNVRAM": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateNVRAM": false])
        }
        if platformInfoGeneralVC!.updateSmbios.state == .on {
            platformInfoDict.addEntries(from: ["UpdateSMBIOS": true])
        } else {
            platformInfoDict.addEntries(from: ["UpdateSMBIOS": false])
        }
        platformInfoDict.addEntries(from: ["UpdateSMBIOSMode": (platformInfoGeneralVC!.smbioUpdateModePopup.selectedItem?.title)!])
        uefiDict.removeAllObjects()
        if uefiDriversVC!.uefiConnectDrivers.state == .on {
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
    
    
    
    func saveMisc() {
        miscBootDict.removeAllObjects()
        miscBootDict.addEntries(from: ["ConsoleMode": miscBootVC!.consoleMode.stringValue])
        if miscBootVC!.OsBehavior.selectedItem?.title == "Don't change" {
            miscBootDict.addEntries(from: ["ConsoleBehaviourOs": ""])
        } else {
            miscBootDict.addEntries(from: ["ConsoleBehaviourOs": (miscBootVC!.OsBehavior.selectedItem?.title)!])
        }
        if miscBootVC!.UiBehavior.selectedItem?.title == "Don't change" {
            miscBootDict.addEntries(from: ["ConsoleBehaviourUi": ""])
        } else {
            miscBootDict.addEntries(from: ["ConsoleBehaviourUi": (miscBootVC!.UiBehavior.selectedItem?.title)!])
        }
        miscBootDict.addEntries(from: ["HideSelf": checkboxState(button: miscBootVC!.hideSelf)])
        miscBootDict.addEntries(from: ["Resolution": miscBootVC!.resolution.stringValue])
        miscBootDict.addEntries(from: ["ShowPicker": checkboxState(button: miscBootVC!.showPicker)])
        miscBootDict.addEntries(from: ["Timeout": Int(miscBootVC!.timeoutTextfield.stringValue)!])
        
        miscDebugDict.removeAllObjects()
        miscDebugDict.addEntries(from: ["DisableWatchDog": checkboxState(button: miscDebugVC!.disableWatchdog)])
        miscDebugDict.addEntries(from: ["DisplayDelay": Int(miscDebugVC!.miscDelayText.stringValue) ?? 0])
        miscDebugDict.addEntries(from: ["DisplayLevel": Int(miscDebugVC!.miscDisplayLevelText.stringValue) ?? 0])
        miscDebugDict.addEntries(from: ["Target": Int(miscDebugVC!.miscTargetText.stringValue) ?? 0])
        
        miscSecurityDict.removeAllObjects()
        miscSecurityDict.addEntries(from: ["ExposeSensitiveData": Int(miscSecurityVC!.miscExposeSensitiveData.stringValue) ?? 0])
        miscSecurityDict.addEntries(from: ["HaltLevel": Int(miscSecurityVC!.miscHaltlevel.stringValue) ?? 0])
        miscSecurityDict.addEntries(from: ["RequireSignature": checkboxState(button: miscSecurityVC!.miscRequireSignature)])
        miscSecurityDict.addEntries(from: ["RequireVault": checkboxState(button: miscSecurityVC!.miscRequireVault)])
        
        miscDict.removeAllObjects()
        miscDict.addEntries(from: ["Boot": miscBootDict])
        miscDict.addEntries(from: ["Debug": miscDebugDict])
        miscDict.addEntries(from: ["Security": miscSecurityDict])
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
    
    func checkboxState(button: NSButton) -> Bool {
        if button.state == .on {
            return true
        } else {
            return false
        }
    }
    
    func addEntryToTable(table: inout NSTableView, appendix: [String:String]) {
        tableLookup[table]!.append(appendix)
        table.beginUpdates()
        table.insertRows(at: IndexSet(integer: tableLookup[table]!.count - 1), withAnimation: .effectGap)
        table.endUpdates()
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
    
    func espWarning() {
        let alert = NSAlert()
        alert.messageText = "No EFI partition selected!"
        alert.informativeText = "Please select an EFI partition from the drop down."
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return itemsList.count
    }
    
    @objc func dropDownHandler(_ sender: NSPopUpButton) {
        guard let parentRowView = sender.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { debugPrint("Failed to assign parent values"); return }
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: sender)]
        if sender.selectedItem?.title != "Other..." {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = (sender.selectedItem?.title)!
        } else {
            let customItem = NSAlert()
            customItem.addButton(withTitle: "OK")      // 1st button
            customItem.addButton(withTitle: "Cancel")  // 2nd button
            customItem.messageText = "Add a custom item"
            customItem.informativeText = ""
            let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            txt.stringValue = ""
            customItem.accessoryView = txt
            let response: NSApplication.ModalResponse = customItem.runModal()
            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                sender.addItem(withTitle: txt.stringValue)
                sender.selectItem(withTitle: txt.stringValue)
            }
        }
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    @objc func checkboxHandler(_ sender: NSButton) {
        guard let parentRowView = sender.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { debugPrint("Failed to assign parent values"); return }
        
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: sender)]
        
        if sender.state == NSControl.StateValue.on {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = "1"
        }
        else {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = "0"
        }
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
            let parentCellView = textField.superview as? NSTableCellView,
            let parentRowView = parentCellView.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { print("Failed to assign parent values"); return }
        if textField.identifier?.rawValue == "hex", tableLookup[parentTableView]![parentTableView.row(for: parentCellView)]["property"] != "boot-args" {        // only allow 1-9,A-F for "hex"tagged fields, except if the property name is "boot-args", as that is parsed as a string
            let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "1234567890abcdefABCDEF").inverted as NSCharacterSet
            textField.stringValue =  (textField.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
            let parentCellView = textField.superview as? NSTableCellView,
            let parentRowView = parentCellView.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { print("Failed to assign parent values"); return }      // going up the superview chain until we reach the tableView. This is relatively safe as this function is only called on text fields where we set the delegate to the ViewController, but we're still wrapping this in a guard statement for good measure. TODO: do that to all other force unwraps too, atm the program will probably crash given a malformatted plist
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: parentCellView)]       // seems to be the only way to access the column of the current cell. Hacky, but it works
        tableLookup[parentTableView]![parentTableView.selectedRow][parentTableColumn.identifier.rawValue] = textField.stringValue       // update the datasource entry for the current cell
        if textField.identifier?.rawValue == "hex", tableLookup[parentTableView]![parentTableView.row(for: parentCellView)]["property"] != "boot-args" {
            if textField.stringValue.count % 2 != 0 {
                textField.stringValue = String(textField.stringValue.prefix(textField.stringValue.count - 1))
            }
        }
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    @objc func onTableClick(_ tableView: NSTableView) {
        if tableView.clickedRow != -1, tableView.clickedColumn != -1 {
            tableView.editColumn(tableView.clickedColumn, row: tableView.clickedRow, with: nil, select: true)
        }
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        switch tableView {
        case kernelAddVC!.kernelAddTable:
            item.setString(String(row), forType: self.dragDropKernelAdd)
        case acpiPatchVC!.acpiPatchTable:
            item.setString(String(row), forType: self.dragDropAcpiPatch)
        case kernelPatchVC!.kernelPatchTable:
            item.setString(String(row), forType: self.dragDropKernelPatch)
        case acpiAddVC!.acpiAddTable:
            item.setString(String(row), forType: self.dragDropAcpiAdd)
        default:
            break
        }
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = [Int]()
        switch tableView {
        case kernelAddVC!.kernelAddTable:
            info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
                if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropKernelAdd), let index = Int(str) {
                    oldIndexes.append(index)
                }
            }
        case acpiPatchVC!.acpiPatchTable:
            info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
                if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropAcpiPatch), let index = Int(str) {
                    oldIndexes.append(index)
                }
            }
        case kernelPatchVC!.kernelPatchTable:
            info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
                if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropKernelPatch), let index = Int(str) {
                    oldIndexes.append(index)
                }
            }
        case acpiAddVC!.acpiAddTable:
            info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
                if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropAcpiAdd), let index = Int(str) {
                    oldIndexes.append(index)
                }
            }
        default:
            break
        }
        var oldIndexOffset = 0
        var newIndexOffset = 0
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                tableLookup[tableView]!.insert(tableLookup[tableView]![oldIndex + oldIndexOffset], at: row)
                oldIndexOffset -= 1
                tableLookup[tableView]!.remove(at: oldIndex)
            } else {
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                tableLookup[tableView]!.insert(tableLookup[tableView]![oldIndex], at: row + newIndexOffset)
                newIndexOffset += 1
                tableLookup[tableView]!.remove(at: oldIndex + 1)
            }
        }
        tableView.endUpdates()
        return true
    }
    
    func tableView(_ tableViewName: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        vw.textField?.stringValue = itemsList[row]
//        if tableLookup[tableViewName]!.count > 0 {
//            switch tableColumn?.identifier.rawValue {
//            case "advanced":
//                let cell = NSButton()
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))      // make the button identifier the row number for row selection on button press
//                cell.image = NSImage.init(named: "NSActionTemplate")
//                cell.isBordered = false
//                cell.action = #selector(MasterDetailsViewController.acpiAdvanced)                // every button has the same action, button is determined via identifier
//                return cell
//            case "kernelAdvanced":
//                let cell = NSButton()
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
//                cell.image = NSImage.init(named: "NSActionTemplate")
//                cell.isBordered = false
//                cell.action = #selector(MasterDetailsViewController.kernelAdvanced)
//                return cell
//            case "TableSignature":
//                let cell = NSPopUpButton()
//                cell.isBordered = false
//                cell.addItems(withTitles: ["DSDT", "SSDT", "APIC", "ASF!", "BATB", "BGRT", "BOOT", "DBG2", "DBGP", "ECDT", "FACS", "FPDT", "HPET", "MCFG", "MSDM", "RSDT", "TPM2", "UEFI", "", "Other..."])
//                cell.selectItem(withTitle: "DSDT")      // otherwise new empty item is created and selected
//                cell.action = #selector(dropDownHandler)
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
//                let table = tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? ""
//                if !cell.itemTitles.contains(table) {
//                    cell.addItem(withTitle: table)
//                }
//                cell.selectItem(withTitle: table)
//                return cell
//            case "Enabled", "All":
//                let cell = NSButton()
//                cell.setButtonType(.switch)     // checkbox
//                cell.imagePosition = .imageOnly     // no text, -> center button
//                cell.action = #selector(checkboxHandler)
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
//                if tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? "0" == "1" {
//                    cell.state = NSControl.StateValue.on
//                }
//                return cell
//            case "MatchKernel":
//                let cell = NSPopUpButton()
//                cell.isBordered = false
//                cell.addItems(withTitles: ["18.", "17.", "16.", "15.", "No", "Other..."])
//                cell.selectItem(withTitle: "DSDT")      // otherwise new empty item is created and selected
//                cell.action = #selector(dropDownHandler)
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
//                let kernelVersion = tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? ""
//                if !cell.itemTitles.contains(kernelVersion), kernelVersion != "" {
//                    cell.addItem(withTitle: kernelVersion)
//                }
//                if kernelVersion != "" {
//                    cell.selectItem(withTitle: kernelVersion)
//                }
//                else {
//                    cell.selectItem(withTitle: "No")
//                }
//                return cell
//            case "edit":
//                let cell = NSButton()
//                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
//                cell.image = NSImage.init(named: "NSQuickLookTemplate")
//                cell.isBordered = false
//                cell.action = #selector(MasterDetailsViewController.deviceEdit)
//                return cell
//            default:
//                let cell = tableViewName.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: (tableColumn?.identifier.rawValue)!), owner: nil) as? NSTableCellView
//                cell?.textField?.stringValue = tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? ""       // string value should be whatever was written to the correspondig tableview datasource entry for that row/column
//                return cell
//            }
//        }
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow < 0 {
            guard let splitViewController = self.parent as? NSSplitViewController,
                let viewController = self.storyboard?.instantiateController(withIdentifier: "detailsVC") as? DetailViewController else {return}
            let item = NSSplitViewItem(viewController: viewController)
            splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
            splitViewController.addSplitViewItem(item)
        } else {
            if selectedRow == 0 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "acpiTabVC") as? ACPITabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 1 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "devicePropertiesTabVC") as? DevicePropertiesTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 2 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "kernelTabVC") as? KernelTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 3 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "miscTabVC") as? MiscTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 4 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "nvramTabVC") as? NVRAMTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 5 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "platformInfoTabVC") as? PlatformInfoTabViewController  else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 6 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "uefiTabVC") as? UEFITabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
        }
    }
    
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
}

extension Notification.Name {
    static let plistOpen = Notification.Name("plistOpen")
    static let plistSave = Notification.Name("plistSave")
    static let syncAcpiPopoverAndDict = Notification.Name("syncAcpiPopoverAndDict")
    static let syncKernelPopoverAndDict = Notification.Name("syncKernelPopoverAndDict")
    static let paste = Notification.Name("paste")
    static let applyAllPatches = Notification.Name("applyAllPatches")
    static let manageVault = Notification.Name("manageVault")
    static let closeVault = Notification.Name("closeVault")
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
