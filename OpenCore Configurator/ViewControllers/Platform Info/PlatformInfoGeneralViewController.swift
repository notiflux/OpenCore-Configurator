//
//  PlatformInfoGeneralViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class PlatformInfoGeneralViewController: NSViewController {
    
    @IBOutlet weak var smbiosAutomatic: NSButton!
    @IBOutlet weak var updateDatahub: NSButton!
    @IBOutlet weak var updateNvram: NSButton!
    @IBOutlet weak var updateSmbios: NSButton!
    @IBOutlet weak var smbioUpdateModePopup: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func togglePlatformAutomatic() {
        if smbiosAutomatic.state == .on {
            platformDatahubTable.isEnabled = false
            platformNvramTable.isEnabled = false
            platformSmbiosTable.isEnabled = false
            platformGenericTable.isEnabled = true
            spoofVendor.isEnabled = true
        } else {
            platformDatahubTable.isEnabled = true
            platformNvramTable.isEnabled = true
            platformSmbiosTable.isEnabled = true
            platformGenericTable.isEnabled = false
            spoofVendor.isEnabled = false
        }
    }
    
    @IBAction func platformAutomaticAction(_ sender: NSButton) {
        togglePlatformAutomatic()
    }
    
}
