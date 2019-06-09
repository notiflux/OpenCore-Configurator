//
//  KernelBlockViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class KernelBlockViewController: NSViewController {
    
    @IBOutlet weak var kernelBlockTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addKernelBlockBtn(_ sender: Any) {
        addEntryToTable(table: &kernelBlockTable, appendix: ["Identifier": "", "Comment": "", "MatchKernel": "", "Enabled": ""])
    }
    @IBAction func remKernelBlockBtn(_ sender: Any) {
        removeEntryFromTable(table: &kernelBlockTable)
    }
}
