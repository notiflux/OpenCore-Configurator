//
//  KernelAddViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class KernelAddViewController: NSViewController {
    
    @IBOutlet weak var kernelAddTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        kernelAutoBtn.toolTip = "Automatically check and add entries for all KEXTs in EFI/OC/Kexts"
    }
    
    @IBAction func addKernelAddBtn(_ sender: Any) {
        addEntryToTable(table: &kernelAddTable, appendix: ["BundlePath": "", "Comment": "", "ExecutablePath": "", "PlistPath": "","MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelAddBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelAddTable)
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
}
