//
//  AcpiPatchViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class AcpiPatchViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addPatchAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiPatchTable, appendix: ["Comment": "", "Find": "", "Replace": "", "TableSignature": "DSDT", "Enabled": "", "advanced": "", "Limit": "", "Mask": "", "OemTableId": "", "ReplaceMask": "", "Skip": "", "TableLength": "", "Count": ""])
    }
    @IBAction func remPatchAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiPatchTable)
    }
}
