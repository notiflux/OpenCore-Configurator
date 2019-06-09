//
//  NvramBlockViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class NvramBlockViewController: NSViewController {
    
    @IBOutlet weak var nvramBlockTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addNvramBlockBtn(_ sender: Any) {
        addEntryToTable(table: &nvramBlockTable, appendix: ["guid": "", "property": ""])
    }
    @IBAction func remNvramBlockBtn(_ sender: Any) {
        removeEntryFromTable(table: &nvramBlockTable)
    }
}
