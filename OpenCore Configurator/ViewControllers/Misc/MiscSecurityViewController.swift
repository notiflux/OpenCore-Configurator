//
//  MiscSecurityViewController.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class MiscSecurityViewController: NSViewController {
    
    var masterVC: MasterDetailsViewController?
    
    @IBOutlet weak var miscRequireSignature: NSButton!
    @IBOutlet weak var miscRequireVault: NSButton!
    @IBOutlet weak var miscHaltlevel: NSTextField!
    @IBOutlet weak var miscExposeSensitiveData: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
