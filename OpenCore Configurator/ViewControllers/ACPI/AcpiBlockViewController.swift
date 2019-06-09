//
//  AcpiBlockViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class AcpiBlockViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func blockAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiBlockTable, appendix: ["Comment": "", "OemTableId": "", "TableLength": "", "TableSignature": "DSDT","Enabled": "", "All": ""])
    }
    @IBAction func remBlockAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiBlockTable)
    }
    
}
