//
//  MasterDetailsViewController.swift
//  test
//
//  Created by Henry Brock on 6/5/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class MasterDetailsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var masterDetailView: NSView!
    @IBOutlet var tableView: NSTableView!
    
    var acpiTabVC: ACPITabViewController?
    var devicePropertiesTabVC: DevicePropertiesTabViewController?
    var kernelTabVC: KernelTabViewController?
    var miscTabVC: MiscTabViewController?
    var detailsVC: DetailViewController?
    var itemsList = ["ACPI", "Device Properties", "Kernel", "Misc", "NVRAM", "Platform Info", "UEFI"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addEntryToTable(table: inout NSTableView, appendix: [String:String]) {
        tableLookup[table]!.append(appendix)
        table.beginUpdates()
        table.insertRows(at: IndexSet(integer: tableLookup[table]!.count - 1), withAnimation: .effectGap)
        table.endUpdates()
    }
    
    func removeEntryFromTable(table: inout NSTableView) {       // for some reason this spawns simultaneous read and write access to the table view delegate. TODO: figure this out so we can re-enable exclusive memory access enforcement
        let SR = table.selectedRow
        if SR != -1 {
            table.removeRows(at: IndexSet(integer: SR), withAnimation: .effectGap)
            tableLookup[table]!.remove(at: SR)
            table.reloadData()
            if table.accessibilityRowCount() < SR {
                table.selectRowIndexes(IndexSet(integer: SR - 1), byExtendingSelection: false)
            }
            else {
                table.selectRowIndexes(IndexSet(integer: SR), byExtendingSelection: false)
            }
            
        }
    }
    
    func messageBox(message: String, info: String? = nil) {
        let alert = NSAlert()
        alert.messageText = message
        
        if info != nil {
            alert.informativeText = info!
        }
        
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
    
    func calcAcpiChecksum(table: URL) -> UInt8? {
        do {
            let tableData = try Data(contentsOf: table)
            
            let length: [UInt8] = Array([UInt8](tableData)[4...7])
            let u32length = UnsafePointer(length).withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
            
            if u32length != tableData.count {
                return nil
            }
            
            try tableData.forEach(addBytes)
        } catch {
            print(error)
        }
        let localChecksum = checksum
        checksum = 0
        return localChecksum
    }
    
    func espWarning() {
        let alert = NSAlert()
        alert.messageText = "No EFI partition selected!"
        alert.informativeText = "Please select an EFI partition from the drop down."
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return itemsList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        vw.textField?.stringValue = itemsList[row]
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow < 0 {
            guard let splitViewController = self.parent as? NSSplitViewController,
                let viewController = self.storyboard?.instantiateController(withIdentifier: "detailsVC") as? DetailViewController else {return}
            let item = NSSplitViewItem(viewController: viewController)
            splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
            splitViewController.addSplitViewItem(item)
        } else {
            if selectedRow == 0 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "acpiTabVC") as? ACPITabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 1 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "devicePropertiesTabVC") as? DevicePropertiesTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 2 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "kernelTabVC") as? KernelTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 3 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "miscTabVC") as? MiscTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 4 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "nvramTabVC") as? NVRAMTabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 5 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "platformInfoTabVC") as? PlatformInfoTabViewController  else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
            if selectedRow == 6 {
                guard let splitViewController = self.parent as? NSSplitViewController,
                    let viewController = self.storyboard?.instantiateController(withIdentifier: "uefiTabVC") as? UEFITabViewController else {return}
                let item = NSSplitViewItem(viewController: viewController)
                splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
                splitViewController.addSplitViewItem(item)
            }
        }
    }
}
