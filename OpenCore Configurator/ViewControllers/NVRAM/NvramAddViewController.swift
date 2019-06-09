//
//  NvramAddViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class NvramAddViewController: NSViewController {
    
    
    @IBOutlet weak var nvramBootTable: NSTableView!
    @IBOutlet weak var nvramVendorTable: NSTableView!
    @IBOutlet weak var nvramCustomTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
    
}
