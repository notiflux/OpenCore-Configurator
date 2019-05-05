//
//  ViewController.swift
//  OpenCore Configurator
//
//  Created by notiflux on 15.04.19.
//  Copyright © 2019 notiflux. All rights reserved.
//
import Cocoa

public let kNotification = Notification.Name("kNotification")

public var acpiLimitString: String = String()           // variables for use in acpi popovover view controller
public var acpiMaskString: String = String()
public var acpiOemTableIdString: String = String()
public var acpiReplaceMaskString: String = String()
public var acpiSkipString: String = String()
public var acpiTableLengthString: String = String()

public var kernelBaseString: String = String()
public var kernelCountString: String = String()
public var kernelIdentifierString: String = String()
public var kernelLimitString: String = String()
public var kernelMaskString: String = String()
public var kernelReplaceString: String = String()
public var kernelSkipString: String = String()

public var tableLookup: [NSTableView: [[String: String]]] = [NSTableView: [[String: String]]]()

public var serialDict: [String: [String]] = [String: [String]]()

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
    @IBOutlet weak var miscExposeBootPath: NSButton!
    @IBOutlet weak var miscTargetText: NSTextField!
    @IBOutlet weak var disableWatchdog: NSButton!
    
    // misc security options
    @IBOutlet weak var miscRequireSignature: NSButton!
    @IBOutlet weak var miscRequireVault: NSButton!
    @IBOutlet weak var miscHaltlevel: NSTextField!
    
    // acpi quirks
    @IBOutlet weak var FadtEnableReset: NSButton!
    @IBOutlet weak var IgnoreForWindows: NSButton!
    @IBOutlet weak var NormalizeHeaders: NSButton!
    @IBOutlet weak var RebaseRegions: NSButton!
    
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
    @IBOutlet weak var ProvideConsoleControl: NSButton!
    @IBOutlet weak var ProvideConsoleGop: NSButton!
    @IBOutlet weak var ReleaseUsbOwnership: NSButton!
    @IBOutlet weak var RequestBootVarRouting: NSButton!
    @IBOutlet weak var SanitiseClearScreen: NSButton!
    @IBOutlet weak var ExitBootServicesDelay: NSTextField!
    
    @IBOutlet weak var AppleBootPolicy: NSButton!
    @IBOutlet weak var DeviceProperties: NSButton!
    
    // smbios options
    @IBOutlet weak var smbiosAutomatic: NSButton!
    @IBOutlet weak var updateDatahub: NSButton!
    @IBOutlet weak var updateNvram: NSButton!
    @IBOutlet weak var updateSmbios: NSButton!
    @IBOutlet weak var smbioUpdateModePopup: NSPopUpButton!
    
    var acpiQuirks: [String: NSButton] = [String: NSButton]()
    var deviceQuirks: [String: NSButton] = [String: NSButton]()
    var kernelQuirks: [String: NSButton] = [String: NSButton]()
    var uefiQuirks: [String: NSButton] = [String: NSButton]()
    var topLevelBools: [NSButton: Bool] = [NSButton: Bool]()
    var uefiProtocols: [String: NSButton] = [String: NSButton]()
    
    func windowShouldClose() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetTables()   // initialize table datasources
        
        for table in Array(tableLookup.keys) {              // setup table delegate and datasource
            table.delegate = self as NSTableViewDelegate
            table.dataSource = self
        }
        
        sectionsTable.action = #selector(onItemClicked)     // on section selection
        
        acpiQuirks = [
            "FadtEnableReset": self.FadtEnableReset,
            "IgnoreForWindows": self.IgnoreForWindows,
            "NormalizeHeaders": self.NormalizeHeaders,
            "RebaseRegions": self.RebaseRegions
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
            "ProvideConsoleControl": self.ProvideConsoleControl,
            "ProvideConsoleGop": self.ProvideConsoleGop,
            "ReleaseUsbOwnership": self.ReleaseUsbOwnership,
            "RequestBootVarRouting": self.RequestBootVarRouting,
            "SanitiseClearScreen": self.SanitiseClearScreen
        ]
        
        uefiProtocols = [
            "AppleBootPolicy": self.AppleBootPolicy,
            "DeviceProperties": self.DeviceProperties
        ]
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlistOpen(_:)), name: .plistOpen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPlistSave(_:)), name: .plistSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAcpiSyncPopover(_:)), name: .syncAcpiPopoverAndDict, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKernelSyncPopover(_:)), name: .syncKernelPopoverAndDict, object: nil)
        
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
        
        acpiLimitString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"]!        // fill variables with contents of plist file
        acpiMaskString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"]!
        acpiOemTableIdString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["OemTableId"]!
        acpiReplaceMaskString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"]!
        acpiSkipString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"]!
        acpiTableLengthString = tableLookup[acpiPatchTable]![Int(sender.identifier!.rawValue)!]["TableLength"]!
        
        acpiVc.showPopover(button: sender)
    }
    
    @objc func kernelAdvanced(_ sender: NSButton) {
        let kernelVc = KernelPopoverController.loadFromNib()
        
        kernelPatchTable.selectRowIndexes(IndexSet(integer: Int(sender.identifier!.rawValue)!), byExtendingSelection: false)
        
        kernelBaseString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Base"]!
        kernelCountString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Count"]!
        kernelIdentifierString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Identifier"]!
        kernelLimitString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Limit"]!
        kernelMaskString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Mask"]!
        kernelReplaceString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["ReplaceMask"]!
        kernelSkipString = tableLookup[kernelPatchTable]![Int(sender.identifier!.rawValue)!]["Skip"]!
        
        kernelVc.showPopover(button: sender)
    }
    
    @objc func onAcpiSyncPopover(_ notification: Notification) {
        tableLookup[acpiPatchTable]![acpiPatchTable.selectedRow][(acpiCurrentTextField.identifier?.rawValue)!] = acpiCurrentTextField.stringValue
    }
    
    @objc func onKernelSyncPopover(_ notification: Notification) {
        tableLookup[kernelPatchTable]![kernelPatchTable.selectedRow][(kernelCurrentTextField.identifier?.rawValue)!] = kernelCurrentTextField.stringValue
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
        acpiBlockArray = acpiDict.object(forKey: "Block") as? NSMutableArray ?? NSMutableArray()
        acpiPatchArray = acpiDict.object(forKey: "Patch") as? NSMutableArray ?? NSMutableArray()
        
        deviceDict = plistDict?.object(forKey: "DeviceProperties") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceAddDict = deviceDict.object(forKey: "Add") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceBlockDict = deviceDict.object(forKey: "Block") as? NSMutableDictionary ?? NSMutableDictionary()
        deviceQuirksDict = deviceDict.object(forKey: "Quirks") as? NSMutableDictionary ?? NSMutableDictionary()
        
        kernelDict = plistDict?.object(forKey: "Kernel") as? NSMutableDictionary ?? NSMutableDictionary()
        kernelAddArray = kernelDict.object(forKey: "Add") as? NSMutableArray ?? NSMutableArray()
        kernelBlockArray = kernelDict.object(forKey: "Block") as? NSMutableArray ?? NSMutableArray()
        kernelPatchArray = kernelDict.object(forKey: "Patch") as? NSMutableArray ?? NSMutableArray()
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
            switch key as! String {
            case "ShowPicker":
                if value as! Bool {
                    showPicker.state = .on
                }
                else {
                    showPicker.state = .off
                }
                
            case "Timeout":
                timeoutStepper.stringValue = String(value as! Int)
                timeoutTextfield.stringValue = String(value as! Int)
            case "ConsoleMode":
                consoleMode.stringValue = value as! String
            case "ConsoleBehaviourOs":
                if value as! String != "" {
                    if OsBehavior.itemTitles.contains(value as! String) {
                        OsBehavior.selectItem(withTitle: value as! String)
                    }
                } else {
                    OsBehavior.selectItem(withTitle: "Don't change")
                }
            case "ConsoleBehaviourUi":
                if value as! String != "" {
                    print(value)
                    if UiBehavior.itemTitles.contains(value as! String) {
                        UiBehavior.selectItem(withTitle: value as! String)
                    }
                } else {
                    UiBehavior.selectItem(withTitle: "Don't change")
                }
            case "HideSelf":
                if value as! Bool {
                    hideSelf.state = .on
                }
                else {
                    hideSelf.state = .off
                }
            case "Resolution":
                resolution.stringValue = value as! String
            default:
                break
            }
        }
        
        for (key, value) in miscDebugDict {
            switch key as! String {
            case "DisplayDelay":
                miscDelayText.stringValue = String(value as! Int)
            case "DisplayLevel":
                miscDisplayLevelText.stringValue = String(value as! Int)
            case "ExposeBootPath":
                if value as! Bool {
                    miscExposeBootPath.state = .on
                }
                else {
                    miscExposeBootPath.state = .off
                }
            case "Target":
                miscTargetText.stringValue = String(value as! Int)
            case "DisableWatchDog":
                if value as! Bool {
                    disableWatchdog.state = .on
                } else {
                    disableWatchdog.state = .off
                }
            default:
                break
            }
        }
        
        for (key, value) in miscSecurityDict {
            switch key as! String {
            case "HaltLevel":
                miscHaltlevel.stringValue = String(value as! Int)
            case "RequireSignature":
                if value as! Bool {
                    miscRequireSignature.state = .on
                }
                else {
                    miscRequireSignature.state = .off
                }
            case "RequireVault":
                if value as! Bool {
                    miscRequireVault.state = .on
                }
                else {
                    miscRequireVault.state = .off
                }
            default:
                break
            }
        }
        
        for (key, value) in nvramAddDict {
            switch key as! String {
            case "7C436110-AB2A-4BBB-A880-FE41995C9F82":
                OHF.createNvramData(value: value as! NSMutableDictionary, table: &nvramBootTable)
            case "4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14":
                OHF.createNvramData(value: value as! NSMutableDictionary, table: &nvramVendorTable)
            default:
                OHF.createNvramData(value: value as! NSMutableDictionary, table: &nvramCustomTable, guidString: key as? String)
            }
        }
        
        for (key, value) in nvramBlockDict {
            OHF.createNvramData(value: value as! NSMutableArray, table: &nvramBlockTable, guidString: key as? String)
        }
        
        OHF.createTopLevelBools(buttonDict: &topLevelBools)
        
        if smbioUpdateModePopup.itemTitles.contains(platformUpdateSmbiosModeStr) {
            smbioUpdateModePopup.selectItem(withTitle: platformUpdateSmbiosModeStr)
        } else {
            smbioUpdateModePopup.selectItem(withTitle: "Auto")
        }
        
        OHF.createData(input: acpiAddArray, table: &acpiAddTable, predefinedKey: "acpiAdd")
        OHF.createData(input: acpiBlockArray, table: &acpiBlockTable)
        OHF.createData(input: acpiPatchArray, table: &acpiPatchTable)
        OHF.createQuirksData(input: acpiQuirksDict, quirksDict: acpiQuirks)
        
        OHF.createData(input: deviceAddDict, table: &deviceAddTable)
        OHF.createData(input: deviceBlockDict, table: &deviceBlockTable)
        // OHF.createQuirksData(input: deviceQuirksDict, quirksDict: deviceQuirks)          // device properties don't exist anymore. leaving this here in case they come back
        
        OHF.createData(input: kernelAddArray, table: &kernelAddTable)
        OHF.createData(input: kernelBlockArray, table: &kernelBlockTable)
        OHF.createData(input: kernelPatchArray, table: &kernelPatchTable)
        OHF.createQuirksData(input: kernelQuirksDict, quirksDict: kernelQuirks)
        
        OHF.createData(input: uefiDriverArray, table: &uefiDriverTable, predefinedKey: "driver")
        OHF.createQuirksData(input: uefiQuirksDict, quirksDict: uefiQuirks)
        OHF.createQuirksData(input: uefiProtocolsDict, quirksDict: uefiProtocols)
        ExitBootServicesDelay.stringValue = String(uefiExitBootInt)
        
        OHF.createData(input: platformSmbiosDict, table: &platformSmbiosTable)
        OHF.createData(input: platformDatahubDict, table: &platformDatahubTable)
        OHF.createData(input: platformGenericDict, table: &platformGenericTable)
        OHF.createData(input: platformNvramDict, table: &platformNvramTable)

        self.view.window?.title = "\((path as NSString).lastPathComponent) - OpenCore Configurator"
        self.view.window?.representedURL = URL(fileURLWithPath: path)
    }
    
    @objc func onPlistSave(_ notification: Notification) {

        let SHF = saveHandlerFunctions()
        
        SHF.saveArrayOfDictData(table: acpiAddTable, array: &acpiAddArray)
        SHF.saveArrayOfDictData(table: acpiBlockTable, array: &acpiBlockArray)
        SHF.saveArrayOfDictData(table: acpiPatchTable, array: &acpiPatchArray)
        SHF.saveQuirksData(dict: acpiQuirks, quirksDict: &acpiQuirksDict)
        
        SHF.saveArrayOfDictData(table: kernelAddTable, array: &kernelAddArray)
        SHF.saveArrayOfDictData(table: kernelBlockTable, array: &kernelBlockArray)
        SHF.saveArrayOfDictData(table: kernelPatchTable, array: &kernelPatchArray)
        SHF.saveQuirksData(dict: kernelQuirks, quirksDict: &kernelQuirksDict)
        
        SHF.saveDeviceData(table: deviceAddTable, dict: &deviceAddDict)
        SHF.saveDeviceData(table: deviceBlockTable, dict: &deviceBlockDict)
        SHF.saveQuirksData(dict: deviceQuirks, quirksDict: &deviceQuirksDict)
        
        SHF.saveDictOfDictData(table: platformGenericTable, dict: &platformGenericDict)
        SHF.saveDictOfDictData(table: platformNvramTable, dict: &platformNvramDict)
        SHF.saveDictOfDictData(table: platformSmbiosTable, dict: &platformSmbiosDict)
        SHF.saveDictOfDictData(table: platformDatahubTable, dict: &platformDatahubDict)
        
        SHF.saveStringData(table: uefiDriverTable, array: &uefiDriverArray)
        SHF.saveQuirksData(dict: uefiQuirks, quirksDict: &uefiQuirksDict)
        uefiQuirksDict.addEntries(from: ["ExitBootServicesDelay": Int(ExitBootServicesDelay.stringValue)!])
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
        }
        platformInfoDict.addEntries(from: ["DataHub": platformDatahubDict])
        platformInfoDict.addEntries(from: ["Generic": platformGenericDict])
        platformInfoDict.addEntries(from: ["PlatformNVRAM": platformNvramDict])
        platformInfoDict.addEntries(from: ["SMBIOS": platformSmbiosDict])
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
        
        self.view.window?.isDocumentEdited = false
        editedState = false
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
        miscDebugDict.addEntries(from: ["DisplayDelay": Int(miscDelayText.stringValue)!])
        miscDebugDict.addEntries(from: ["DisplayLevel": Int(miscDisplayLevelText.stringValue)!])
        miscDebugDict.addEntries(from: ["ExposeBootPath": checkboxState(button: miscExposeBootPath)])
        miscDebugDict.addEntries(from: ["Target": Int(miscTargetText.stringValue)!])
        
        miscSecurityDict.removeAllObjects()
        miscSecurityDict.addEntries(from: ["HaltLevel": Int(miscHaltlevel.stringValue)!])
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
        addEntryToTable(table: &acpiBlockTable, appendix: ["Comment": "", "OemTableId": "", "TableLength": "", "TableSignature": "","Enabled": "", "All": ""])
    }
    @IBAction func remBlockAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiBlockTable)
    }
    @IBAction func addPatchAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "TableSignature": "", "Enabled": "", "advanced": "", "Limit": "", "Mask": "", "OemTableId": "", "ReplaceMask": "", "Skip": "", "TableLength": ""])
    }
    @IBAction func remPatchAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiPatchTable)
    }
    @IBAction func addDeviceAddBtn(_ sender: Any) {
        addEntryToTable(table: &deviceAddTable, appendix: ["device": "", "property": "", "value": ""])
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
    
    @IBAction func autoAddAcpi(_ sender: Any) {
        let fileManager = FileManager.default
        let acpiUrl = URL(fileURLWithPath: "/Volumes/EFI/EFI/OC/ACPI/Custom")
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: acpiUrl, includingPropertiesForKeys: nil)
            var filenames: [String] = [String]()
            for i in fileURLs {
                filenames.append(i.lastPathComponent)
            }
            
            for file in filenames {
                tableLookup[acpiAddTable]!.append(["Comment": "", "Path": file, "Enabled": "1"])
            }
            acpiAddTable.reloadData()
        } catch {
            print("Error while enumerating files \(acpiUrl.path): \(error.localizedDescription)")
        }
    }
    
    @IBAction func autoAddKernel(_ sender: Any) {
        let execLookup = recursiveKexts(path: "/Volumes/EFI/EFI/OC/Kexts")
        for kext in Array(execLookup!.keys) {
            tableLookup[kernelAddTable]!.append(["Comment": "", "BundlePath": kext, "Enabled": "1", "ExecutablePath": "\(execLookup![kext]!)", "MatchKernel": "", "PlistPath": "Contents/Info.plist"])
        }
        kernelAddTable.reloadData()
    }
    
    @IBAction func genSmbios(_ sender: NSButton) {
        let macSerial = Bundle.main.url(forResource: "macserial", withExtension: "")!.path
        let serialMess = shell(launchPath: macSerial, arguments: ["-a"])?.components(separatedBy: "\n")
        
        for entry in serialMess! {
            let modelArray = entry.replacingOccurrences(of: " ", with: "").components(separatedBy: "|")
            if modelArray.count == 3 {
                serialDict[modelArray[0]] = [modelArray[1], modelArray[2]]
            }
        }
        
        let menu = NSMenu()
        for model in Array(serialDict.keys).sorted(by: <) {
            menu.addItem(withTitle: model, action: #selector(onSmbiosSelect), keyEquivalent: "")
        }
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y + 48)
        menu.popUp(positioning: menu.items.last, at: p, in: sender.superview)
    }
    
    @objc func onSmbiosSelect(_ sender: NSMenuItem) {
        tableLookup[platformGenericTable]! = [["property": "SystemUUID", "value": ""],
                                              ["property": "MLB", "value": ""],
                                              ["property": "ROM", "value": ""],
                                              ["property": "SystemProductName", "value": ""],
                                              ["property": "SystemSerialNumber", "value": ""]]
        
        let mac = String((shell(launchPath: "/bin/bash", arguments: ["-c", "ifconfig en0 | grep ether"])?.dropFirst(6))!).replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "").uppercased()
        
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemSerialNumber", "value": ""])!] = ["property": "SystemSerialNumber", "value": serialDict[sender.title]![0]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemProductName", "value": ""])!] = ["property": "SystemProductName", "value": sender.title]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "MLB", "value": ""])!] = ["property": "MLB", "value": serialDict[sender.title]![1]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemUUID", "value": ""])!] = ["property": "SystemUUID", "value": UUID().uuidString]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "ROM", "value": ""])!] = ["property": "ROM", "value": mac]
        platformGenericTable.reloadData()
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
                    if fileManager.fileExists(atPath: "\(i.path)/Contents/Info.plist") {
                        let execUrl = URL(fileURLWithPath: "Contents/MacOS", relativeTo: i)
                        do {
                            let executable = try fileManager.contentsOfDirectory(at: execUrl, includingPropertiesForKeys: nil)
                            execLookup[i.lastPathComponent] = "Contents/MacOS/\((executable.first?.lastPathComponent)!)"
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
                        let alert = NSAlert()
                        alert.messageText = "\(i.lastPathComponent) does not have an Info.plist"
                        alert.informativeText = "Re-download the kext or contact the developer about this issue."
                        alert.runModal()
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
}
