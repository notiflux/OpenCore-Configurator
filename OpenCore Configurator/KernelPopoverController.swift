//
//  KernelPopoverController.swift
//  OpenCore Configurator
//
//  Created by notiflux on 24.04.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Cocoa

public var kernelCurrentTextField: NSTextField = NSTextField()

class KernelPopoverController: NSViewController {
    
    @IBOutlet weak var baseText: NSTextField!
    @IBOutlet weak var countText: NSTextField!
    @IBOutlet weak var identifierText: NSTextField!
    @IBOutlet weak var limitText: NSTextField!
    @IBOutlet weak var maskText: NSTextField!
    @IBOutlet weak var replaceText: NSTextField!
    @IBOutlet weak var skipText: NSTextField!
    
    let popover = NSPopover()
    
    class func loadFromNib() -> KernelPopoverController {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "KernelPopoverController") as! KernelPopoverController       // we need this because we're calling this function from another view controller
        vc.popover.contentViewController = vc
        return vc           // allow for access of objects from this view controller from another one
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popover.behavior = .transient           // close popup on outside click/Esc
    }
    
    func showPopover(button: NSButton) {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxX)
        
        baseText.stringValue = kernelBaseString
        
        countText.stringValue = kernelCountString
        
        identifierText.stringValue = kernelIdentifierString
        
        limitText.stringValue = kernelLimitString
        
        maskText.stringValue = kernelMaskString
        
        replaceText.stringValue = kernelReplaceString
        
        skipText.stringValue = kernelSkipString
    }
    @IBAction func sendBase(_ sender: Any) {
        kernelCurrentTextField = baseText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendCount(_ sender: Any) {
        kernelCurrentTextField = countText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendIdentifier(_ sender: Any) {
        kernelCurrentTextField = identifierText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendLimit(_ sender: Any) {
        kernelCurrentTextField = limitText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendMask(_ sender: Any) {
        kernelCurrentTextField = maskText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendReplace(_ sender: Any) {
        kernelCurrentTextField = replaceText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
    @IBAction func sendSkip(_ sender: Any) {
        kernelCurrentTextField = skipText
        NotificationCenter.default.post(name: .syncKernelPopoverAndDict, object: nil)
    }
}
