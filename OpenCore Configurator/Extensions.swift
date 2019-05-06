//
//  Extensions.swift
//  OpenCore Configurator
//
//  Created by notiflux on 19.04.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableLookup[tableView]!.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    @objc func dropDownHandler(_ sender: NSPopUpButton) {
        guard let parentRowView = sender.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { debugPrint("Failed to assign parent values"); return }
        
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: sender)]
        
        if sender.selectedItem?.title != "Other..." {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = (sender.selectedItem?.title)!
        } else {
            let customItem = NSAlert()
            customItem.addButton(withTitle: "OK")      // 1st button
            customItem.addButton(withTitle: "Cancel")  // 2nd button
            customItem.messageText = "Add a custom item"
            customItem.informativeText = ""
            
            let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            txt.stringValue = ""
            
            customItem.accessoryView = txt
            let response: NSApplication.ModalResponse = customItem.runModal()
            
            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                sender.addItem(withTitle: txt.stringValue)
                sender.selectItem(withTitle: txt.stringValue)
            }
        }
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    @objc func checkboxHandler(_ sender: NSButton) {
        guard let parentRowView = sender.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { debugPrint("Failed to assign parent values"); return }
        
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: sender)]
        
        if sender.state == NSControl.StateValue.on {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = "1"
        }
        else {
            tableLookup[parentTableView]![Int(sender.identifier!.rawValue)!][parentTableColumn.identifier.rawValue] = "0"
        }
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
            let parentCellView = textField.superview as? NSTableCellView,
            let parentRowView = parentCellView.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { print("Failed to assign parent values"); return }
        
        if textField.identifier?.rawValue == "hex", tableLookup[parentTableView]![parentTableView.row(for: parentCellView)]["property"] != "boot-args" {        // only allow 1-9,A-F for "hex"tagged fields, except if the property name is "boot-args", as that is parsed as a string
            let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "1234567890abcdefABCDEF").inverted as NSCharacterSet
            textField.stringValue =  (textField.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
            let parentCellView = textField.superview as? NSTableCellView,
            let parentRowView = parentCellView.superview as? NSTableRowView,
            let parentTableView = parentRowView.superview as? NSTableView else { print("Failed to assign parent values"); return }      // going up the superview chain until we reach the tableView. This is relatively safe as this function is only called on text fields where we set the delegate to the ViewController, but we're still wrapping this in a guard statement for good measure. TODO: do that to all other force unwraps too, atm the program will probably crash given a malformatted plist
        
        let parentTableColumn = parentTableView.tableColumns[parentTableView.column(for: parentCellView)]       // seems to be the only way to access the column of the current cell. Hacky, but it works

        tableLookup[parentTableView]![parentTableView.selectedRow][parentTableColumn.identifier.rawValue] = textField.stringValue       // update the datasource entry for the current cell
        
        if textField.identifier?.rawValue == "hex", tableLookup[parentTableView]![parentTableView.row(for: parentCellView)]["property"] != "boot-args" {
            if textField.stringValue.count % 2 != 0 {
                textField.stringValue = String(textField.stringValue.prefix(textField.stringValue.count - 1))
            }
        }
        
        self.view.window?.isDocumentEdited = true
        editedState = true
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: self.dragDropType)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
        // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                tableLookup[tableView]!.insert(tableLookup[tableView]![oldIndex + oldIndexOffset], at: row - 1)
                oldIndexOffset -= 1
            } else {
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                tableLookup[tableView]!.insert(tableLookup[tableView]![oldIndex], at: row + newIndexOffset)
                newIndexOffset += 1
            }
            tableLookup[tableView]!.remove(at: oldIndex + 1)
        }
        
        tableView.endUpdates()
        
        return true
    }
    
    func tableView(_ tableViewName: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableLookup[tableViewName]!.count > 0 {
            switch tableColumn?.identifier.rawValue {
            case "advanced":
                let cell = NSButton()
                
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))      // make the button identifier the row number for row selection on button press
                
                cell.image = NSImage.init(named: "NSActionTemplate")
                cell.isBordered = false
                cell.action = #selector(ViewController.acpiAdvanced)                // every button has the same action, button is determined via identifier
                
                return cell
                
            case "kernelAdvanced":
                let cell = NSButton()
                
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
                
                cell.image = NSImage.init(named: "NSActionTemplate")
                cell.isBordered = false
                cell.action = #selector(ViewController.kernelAdvanced)
                
                return cell
                
            case "TableSignature":
                
                let cell = NSPopUpButton()

                cell.isBordered = false
                cell.addItems(withTitles: ["DSDT", "SSDT", "", "APIC", "ASF!", "BATB", "BGRT", "BOOT", "DBG2", "DBGP", "ECDT", "FACS", "FPDT", "HPET", "MCFG", "MSDM", "RSDT", "TPM2", "UEFI", "", "Other..."])
                cell.selectItem(withTitle: "DSDT")      // otherwise new empty item is created and selected
                cell.action = #selector(dropDownHandler)
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
                
                let table = String(decoding: Data(hexString: tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!]!)!, as: UTF8.self)
                
                if table != "" {
                    if !cell.itemTitles.contains(table) {
                        cell.addItem(withTitle: table)
                    }
                    cell.selectItem(withTitle: table)
                }
                return cell
                
            case "Enabled", "All":
                let cell = NSButton()
                cell.setButtonType(.switch)     // checkbox
                cell.imagePosition = .imageOnly     // no text, -> center button
                cell.action = #selector(checkboxHandler)
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
                
                if tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? "0" == "1" {
                    cell.state = NSControl.StateValue.on
                }
                
                return cell
                
            case "MatchKernel":
                let cell = NSPopUpButton()
                
                cell.isBordered = false
                cell.addItems(withTitles: ["18.", "17.", "16.", "15.", "No", "Other..."])
                cell.selectItem(withTitle: "DSDT")      // otherwise new empty item is created and selected
                cell.action = #selector(dropDownHandler)
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
                
                let kernelVersion = tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!]!
                
                if !cell.itemTitles.contains(kernelVersion), kernelVersion != "" {
                    cell.addItem(withTitle: kernelVersion)
                }
                if kernelVersion != "" {
                    cell.selectItem(withTitle: kernelVersion)
                }
                else {
                    cell.selectItem(withTitle: "No")
                }
                return cell
                
            case "edit":
                let cell = NSButton()
                
                cell.identifier = NSUserInterfaceItemIdentifier(rawValue: String(row))
                cell.image = NSImage.init(named: "NSQuickLookTemplate")
                cell.isBordered = false
                cell.action = #selector(ViewController.deviceEdit)
                
                return cell
                
            default:
                let cell = tableViewName.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: (tableColumn?.identifier.rawValue)!), owner: nil) as? NSTableCellView
                cell?.textField?.stringValue = tableLookup[tableViewName]![row][(tableColumn?.identifier.rawValue)!] ?? ""       // string value should be whatever was written to the correspondig tableview datasource entry for that row/column
                return cell
            }
        }
        return nil
    }
}

extension Notification.Name {
    static let plistOpen = Notification.Name("plistOpen")
    static let plistSave = Notification.Name("plistSave")
    static let syncAcpiPopoverAndDict = Notification.Name("syncAcpiPopoverAndDict")
    static let syncKernelPopoverAndDict = Notification.Name("syncKernelPopoverAndDict")
}
