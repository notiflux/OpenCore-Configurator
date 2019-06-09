//
//  PlatformInfoGenericViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class PlatformInfoGenericViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var platformGenericTable: NSTableView!
    @IBOutlet weak var platformAutoBtn: NSButton!
    @IBOutlet weak var spoofVendor: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        platformAutoBtn.toolTip = "Select an SMBIOS preset"
    }
    
    @objc func onSmbiosSelect(_ sender: NSMenuItem) {
        tableLookup[platformGenericTable] = [["property": "SystemUUID", "value": ""],
                                             ["property": "MLB", "value": ""],
                                             ["property": "ROM", "value": ""],
                                             ["property": "SystemProductName", "value": ""],
                                             ["property": "SystemSerialNumber", "value": ""]]
        
        let mac = String((masterVC!.shell(launchPath: "/bin/bash", arguments: ["-c", "ifconfig en0 | grep ether"])?.dropFirst(6))!).replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").uppercased()
        
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemSerialNumber", "value": ""])!] = ["property": "SystemSerialNumber", "value": serialDict[sender.title]![0]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemProductName", "value": ""])!] = ["property": "SystemProductName", "value": sender.title]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "MLB", "value": ""])!] = ["property": "MLB", "value": serialDict[sender.title]![1]]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "SystemUUID", "value": ""])!] = ["property": "SystemUUID", "value": UUID().uuidString]
        tableLookup[platformGenericTable]![tableLookup[platformGenericTable]!.firstIndex(of: ["property": "ROM", "value": ""])!] = ["property": "ROM", "value": mac]
        platformGenericTable.reloadData()
    }
    
    @IBAction func genSmbios(_ sender: NSButton) {
        let macSerial = Bundle.main.path(forAuxiliaryExecutable: "macserial" )!
        let serialMess = masterVC!.shell(launchPath: macSerial, arguments: ["-a"])?.components(separatedBy: "\n")
        
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
}
