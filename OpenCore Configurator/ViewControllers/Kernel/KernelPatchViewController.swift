//
//  KernelPatchViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class KernelPatchViewController: NSViewController {
    
    @IBOutlet weak var kernelPatchTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addKernelPatchBtn(_ sender: Any) {
        addEntryToTable(table: &kernelPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "MatchKernel": "", "Enabled": "", "kernelAdvanced": "", "Base": "", "Count": "", "Identifier": "", "Limit": "", "Mask": "", "ReplaceMask": "", "Skip": ""])
    }
    @IBAction func remKernelPatchBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelPatchTable)
    }
}
