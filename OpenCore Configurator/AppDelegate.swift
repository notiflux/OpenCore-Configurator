//
//  AppDelegate.swift
//  OpenCore Configurator
//
//  Created by notiflux on 15.04.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Cocoa

var path = ""
var editedState = false
var windowController: NSWindowController?
var shouldExit = false

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        path = filename
        NotificationCenter.default.post(name: .plistOpen, object: nil)
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if editedState {
            let alert = NSAlert()
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            
            alert.addButton(withTitle: "Save changes and exit")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Exit without saving")
            alert.alertStyle = .warning
            alert.messageText = "Unsaved changes"
            alert.informativeText = "Do you want to save your changes?"
            
            let result = alert.runModal()
            
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                appDelegate.saveFile("")
                if shouldExit { return NSApplication.TerminateReply.terminateNow }
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                return NSApplication.TerminateReply.terminateCancel
            case NSApplication.ModalResponse.alertThirdButtonReturn:
                return NSApplication.TerminateReply.terminateNow
            default:
                break
            }
        } else { return NSApplication.TerminateReply.terminateNow }
        return NSApplication.TerminateReply.terminateCancel
    }
    
    @IBAction func newFile(_ sender: Any) {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "mainVC") as! ViewController
        let newWindow = NSWindow(contentViewController: vc)
        newWindow.makeKeyAndOrderFront(self)
        windowController = NSWindowController(window: newWindow)
        windowController?.showWindow(self)

    }
    
    @IBAction func openFile(_ sender: Any) {
        let dialog = NSOpenPanel()             // "file -> open" handler
        
        dialog.title                   = "Choose a configuration plist"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["plist"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url         // Pathname of the file
            
            if (result != nil) {
                path = result!.path         // we're posting a notification to handle the file open request in the main view controller, so we're writing the path to a public variable
                NotificationCenter.default.post(name: .plistOpen, object: nil)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func saveFile(_ sender: Any) {
        if path == "" {
            saveFileAs(sender)
        }
        else {
            NotificationCenter.default.post(name: .plistSave, object: nil)
        }
    }
    @IBAction func saveFileAs(_ sender: Any) {
        let dialog = NSSavePanel()
        
        dialog.title                   = "Choose a location to save the configuration plist"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = ["plist"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url
            
            if result != nil {
                path = result!.path
                NotificationCenter.default.post(name: .plistSave, object: nil)
                NotificationCenter.default.post(name: .plistOpen, object: nil)
                shouldExit = true
            }
        }
    }
    @IBAction func onPaste(_ sender: Any) {
        NotificationCenter.default.post(name: .paste, object: nil)
    }
}

class window: NSWindow {

    override func close() {
        if editedState {
            let alert = NSAlert()
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            
            alert.addButton(withTitle: "Save changes and close")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Close without saving")
            alert.alertStyle = .warning
            alert.messageText = "Unsaved changes"
            alert.informativeText = "Do you want to save your changes?"
            
            let result = alert.runModal()
            
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                appDelegate.saveFile("")
                if shouldExit { super.close() }
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                break
            case NSApplication.ModalResponse.alertThirdButtonReturn:
                super.close()
            default:
                break
            }
        } else { super.close() }
    }
}
